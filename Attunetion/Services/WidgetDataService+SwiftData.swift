//
//  WidgetDataService+SwiftData.swift
//  Attunetion
//
//  Extension for updating widget data from SwiftData models
//

import Foundation
import SwiftData

extension WidgetDataService {
    /// Update widget data from current intention and theme using SwiftData (main app only)
    @MainActor
    func updateWidgetDataFromSwiftData(modelContext: ModelContext, currentIntention: Intention? = nil) {
        print("WidgetDataService: updateWidgetDataFromSwiftData called, currentIntention provided: \(currentIntention != nil)")
        
        let repository = IntentionRepository(modelContext: modelContext)
        let themeRepository = ThemeRepository(modelContext: modelContext)
        
        // Get all intentions to determine user state
        let allIntentions = repository.getAll()
        let hasSetIntentionsBefore = !allIntentions.isEmpty
        
        // Get last intention date
        let lastIntentionDate = allIntentions.max(by: { $0.date < $1.date })?.date
        
        // Check if user has set monthly intention before
        let hasSetMonthlyBefore = allIntentions.contains { $0.scope == .month }
        
        // Calculate days since last intention
        let daysSinceLastIntention: Int? = {
            guard let lastDate = lastIntentionDate else { return nil }
            let calendar = Calendar.current
            let days = calendar.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
            return days
        }()
        
        // Get widget theme preference
        let prefsRepo = UserPreferencesRepository(modelContext: modelContext)
        let prefs = prefsRepo.getPreferences()
        let widgetThemePreference = prefs?.widgetThemeId
        
        // Get app theme for fallback
        let appThemeId = prefs?.appThemeId
        let appTheme: AppTheme? = {
            if let themeIdString = appThemeId,
               let themeId = UUID(uuidString: themeIdString),
               let theme = AppTheme.presetThemes.first(where: { $0.id == themeId }) {
                return theme
            }
            return AppTheme.defaultTheme
        }()
        
        // Always save user state (needed for empty state logic)
        let userState = WidgetUserState(
            hasSetIntentionsBefore: hasSetIntentionsBefore,
            lastIntentionDate: lastIntentionDate,
            daysSinceLastIntention: daysSinceLastIntention,
            hasSetMonthlyBefore: hasSetMonthlyBefore
        )
        saveUserState(userState)

        func snapshotTheme(for intention: Intention) -> ThemeData? {
            switch widgetThemePreference {
            case "ocean": return WidgetTheme.ocean
            case "sunset": return WidgetTheme.sunset
            case "forest": return WidgetTheme.forest
            case "minimal": return WidgetTheme.minimal
            case "midnight": return WidgetTheme.midnight
            case "use_intention":
                if let id = intention.themeId, let theme = themeRepository.getTheme(byId: id) {
                    return ThemeData(backgroundColor: theme.backgroundColor, textColor: theme.textColor,
                                     accentColor: theme.accentColor, fontName: theme.fontName)
                }
            default: break
            }
            guard let theme = appTheme else { return nil }
            return ThemeData(backgroundColor: theme.lightBackground.hex ?? "#FAF9F6",
                             textColor: theme.lightPrimaryText.hex ?? "#1A1A1A",
                             accentColor: theme.lightAccent.hex, fontName: nil)
        }
        // Retain current and scheduled future focuses, not merely the one chosen today.
        let now = Date()
        saveWidgetRecords(allIntentions.filter { ($0.scope.interval(containing: $0.date)?.end ?? .distantPast) > now }.map { item in
            let theme = snapshotTheme(for: item)
            return IntentionWidgetRecord(id: item.id, text: item.text, scope: item.scope.rawValue,
                scopeDate: item.date, quote: item.quote, aiGenerated: item.aiGenerated,
                backgroundColor: theme?.backgroundColor, textColor: theme?.textColor,
                accentColor: theme?.accentColor, fontName: theme?.fontName)
        })
        
        // Get current intention - use provided one if it's actually current, otherwise query
        let intention: Intention? = {
            if let provided = currentIntention {
                if provided.scope.isCurrent(provided.date) { return provided }
            }
            // Fall back to querying
            return repository.getCurrentDisplayIntention()
        }()
        
        if let intention = intention {
            let intentionData = IntentionData(
                id: intention.id,
                text: intention.text,
                scope: intention.scope.rawValue,
                scopeDate: intention.date,
                quote: intention.quote,
                aiGenerated: intention.aiGenerated
            )
            
            // Get theme: prefer intention's theme when set (consistent with list/detail), then preference or app theme
            var themeData: ThemeData? = nil
            
            // 1. Use intention's theme when the intention has one
            if let themeId = intention.themeId,
               let theme = themeRepository.getTheme(byId: themeId) {
                themeData = ThemeData(
                    backgroundColor: theme.backgroundColor,
                    textColor: theme.textColor,
                    accentColor: theme.accentColor,
                    fontName: theme.fontName
                )
            }

            // 2. No intention theme - use widget preference or app theme
            if themeData == nil {
                if let preference = widgetThemePreference {
                    switch preference {
                    case "ocean":
                        themeData = WidgetTheme.ocean
                    case "sunset":
                        themeData = WidgetTheme.sunset
                    case "forest":
                        themeData = WidgetTheme.forest
                    case "minimal":
                        themeData = WidgetTheme.minimal
                    case "midnight":
                        themeData = WidgetTheme.midnight
                    case "use_intention":
                        break // already tried intention theme above
                    default:
                        break
                    }
                }
                if themeData == nil, let appTheme = appTheme {
                    themeData = ThemeData(
                        backgroundColor: appTheme.lightBackground.hex ?? "#FAF9F6",
                        textColor: appTheme.lightPrimaryText.hex ?? "#1A1A1A",
                        accentColor: appTheme.lightAccent.hex,
                        fontName: nil
                    )
                }
            }
            
            print("WidgetDataService: Calling updateWidgetData with intention and theme")
            updateWidgetData(intentionData: intentionData, themeData: themeData)
            print("WidgetDataService: ✅ Completed widget data update")
        } else {
            print("WidgetDataService: ❌ No current intention found - checking all intentions...")
            let allIntentions = repository.getAll()
            print("WidgetDataService: Total intentions in database: \(allIntentions.count)")
            // No current intention - use widget theme preference
            var themeData: ThemeData? = nil
            if let preference = widgetThemePreference {
                switch preference {
                case "ocean":
                    themeData = WidgetTheme.ocean
                case "sunset":
                    themeData = WidgetTheme.sunset
                case "forest":
                    themeData = WidgetTheme.forest
                case "minimal":
                    themeData = WidgetTheme.minimal
                case "midnight":
                    themeData = WidgetTheme.midnight
                case "use_intention":
                    // No intention, so no theme to use
                    break
                default:
                    break
                }
            } else {
                // No widget theme preference set - use app theme
                if let appTheme = appTheme {
                    themeData = ThemeData(
                        backgroundColor: appTheme.lightBackground.hex ?? "#FAF9F6",
                        textColor: appTheme.lightPrimaryText.hex ?? "#1A1A1A",
                        accentColor: appTheme.lightAccent.hex,
                        fontName: nil
                    )
                }
            }
            
            updateWidgetData(intentionData: nil, themeData: themeData)
        }
    }
}
