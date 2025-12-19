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
        
        // Get current intention - use provided one if it's actually current, otherwise query
        let intention: Intention? = {
            if let provided = currentIntention {
                // Verify the provided intention is actually current (matches today)
                let calendar = Calendar.current
                let today = Date()
                
                switch provided.scope {
                case .day:
                    let startOfDay = calendar.startOfDay(for: today)
                    let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
                    if provided.date >= startOfDay && provided.date < endOfDay {
                        return provided
                    }
                case .week:
                    let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
                    let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!
                    if provided.date >= weekStart && provided.date < weekEnd {
                        return provided
                    }
                case .month:
                    let components = calendar.dateComponents([.year, .month], from: today)
                    let monthStart = calendar.date(from: components) ?? today
                    let monthEnd = calendar.date(byAdding: DateComponents(month: 1), to: monthStart)!
                    if provided.date >= monthStart && provided.date < monthEnd {
                        return provided
                    }
                }
            }
            // Fall back to querying
            return repository.getCurrentDisplayIntention()
        }()
        
        if let intention = intention {
            print("WidgetDataService: ✅ Found current intention: '\(intention.text)' (scope: \(intention.scope.rawValue), date: \(intention.date))")
            let intentionData = IntentionData(
                id: intention.id,
                text: intention.text,
                scope: intention.scope.rawValue,
                scopeDate: intention.date,
                quote: intention.quote,
                aiGenerated: intention.aiGenerated
            )
            print("WidgetDataService: Created IntentionData object: id=\(intentionData.id), text='\(intentionData.text)', scope=\(intentionData.scope)")
            
            // Get theme based on preference
            var themeData: ThemeData? = nil
            
            // Check if user wants to use a preset widget theme
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
                    // Use intention's theme
                    if let themeId = intention.themeId,
                       let theme = themeRepository.getTheme(byId: themeId) {
                        themeData = ThemeData(
                            backgroundColor: theme.backgroundColor,
                            textColor: theme.textColor,
                            accentColor: theme.accentColor,
                            fontName: theme.fontName
                        )
                    }
                default:
                    // Fall back to intention's theme
                    if let themeId = intention.themeId,
                       let theme = themeRepository.getTheme(byId: themeId) {
                        themeData = ThemeData(
                            backgroundColor: theme.backgroundColor,
                            textColor: theme.textColor,
                            accentColor: theme.accentColor,
                            fontName: theme.fontName
                        )
                    }
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
                } else {
                    // Fall back to intention's theme if no app theme
                    if let themeId = intention.themeId,
                       let theme = themeRepository.getTheme(byId: themeId) {
                        themeData = ThemeData(
                            backgroundColor: theme.backgroundColor,
                            textColor: theme.textColor,
                            accentColor: theme.accentColor,
                            fontName: theme.fontName
                        )
                    }
                }
            }
            
            print("WidgetDataService: Calling updateWidgetData with intention and theme")
            updateWidgetData(intentionData: intentionData, themeData: themeData)
            print("WidgetDataService: ✅ Completed widget data update")
        } else {
            print("WidgetDataService: ❌ No current intention found - checking all intentions...")
            let allIntentions = repository.getAll()
            print("WidgetDataService: Total intentions in database: \(allIntentions.count)")
            for (index, intent) in allIntentions.prefix(5).enumerated() {
                print("WidgetDataService:   [\(index)] '\(intent.text)' - scope: \(intent.scope.rawValue), date: \(intent.date)")
            }
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



