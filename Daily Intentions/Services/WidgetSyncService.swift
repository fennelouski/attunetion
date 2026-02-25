//
//  WidgetSyncService.swift
//  Daily Intentions
//
//  Writes intention and theme data to App Group for the widget and reloads widget timelines.
//  Uses duplicate Codable types so the app can encode the same JSON the widget decodes.
//

import Foundation
import SwiftData
#if canImport(WidgetKit)
import WidgetKit
#endif

// MARK: - Widget data types (must match IntentionWidget's IntentionData, ThemeData, WidgetUserState)

private struct WidgetIntentionData: Codable {
    let id: UUID
    let text: String
    let scope: String
    let scopeDate: Date
    let quote: String?
    let aiGenerated: Bool
}

private struct WidgetThemeData: Codable {
    let backgroundColor: String
    let textColor: String
    let accentColor: String?
    let fontName: String?
    let backgroundImageURL: String?
    let attributionText: String?
    let attributionURL: String?
}

private struct WidgetUserState: Codable {
    let hasSetIntentionsBefore: Bool
    let lastIntentionDate: Date?
    let daysSinceLastIntention: Int?
    let hasSetMonthlyBefore: Bool
}

// Default theme for widget (matches WidgetTheme.ocean in widget)
private let defaultWidgetTheme = WidgetThemeData(
    backgroundColor: "#1E3A8A",
    textColor: "#FFFFFF",
    accentColor: "#60A5FA",
    fontName: nil,
    backgroundImageURL: nil,
    attributionText: nil,
    attributionURL: nil
)

// MARK: - WidgetSyncService

enum WidgetSyncService {
    private static let appGroupIdentifier = "group.com.nathanfennel.Attunetion"
    private static let intentionDataKey = "currentIntentionData"
    private static let themeDataKey = "currentThemeData"
    private static let userStateKey = "widgetUserState"

    /// Sync current intention (and theme/user state) to App Group and reload widget timelines.
    /// Call after any intention create/update/delete.
    /// - Parameters:
    ///   - modelContext: SwiftData context to fetch current intention and all intentions for user state.
    ///   - currentIntention: If non-nil and applies to "today", use this instead of refetching (avoids timing issues).
    @MainActor
    static func syncWidget(modelContext: ModelContext, currentIntention: Intention? = nil) {
        guard let userDefaults = UserDefaults(suiteName: appGroupIdentifier) else { return }

        let intention: Intention? = resolveCurrentIntention(
            modelContext: modelContext,
            currentIntention: currentIntention
        )

        // User state for widget empty state
        let allIntentions = fetchAllIntentions(modelContext: modelContext)
        let lastIntentionDate = allIntentions.max(by: { $0.date < $1.date })?.date
        let daysSinceLastIntention: Int? = {
            guard let last = lastIntentionDate else { return nil }
            return Calendar.current.dateComponents([.day], from: last, to: Date()).day ?? 0
        }()
        let userState = WidgetUserState(
            hasSetIntentionsBefore: !allIntentions.isEmpty,
            lastIntentionDate: lastIntentionDate,
            daysSinceLastIntention: daysSinceLastIntention,
            hasSetMonthlyBefore: allIntentions.contains { $0.scope == .month }
        )
        if let encoded = try? JSONEncoder().encode(userState) {
            userDefaults.set(encoded, forKey: userStateKey)
        }

        if let intention = intention {
            let data = WidgetIntentionData(
                id: intention.id,
                text: intention.text,
                scope: intention.scope.rawValue,
                scopeDate: intention.date,
                quote: intention.quote,
                aiGenerated: intention.aiGenerated
            )
            if let encoded = try? JSONEncoder().encode(data) {
                userDefaults.set(encoded, forKey: intentionDataKey)
            }
            let themeData = widgetThemeData(for: intention, modelContext: modelContext)
            if let themeEncoded = try? JSONEncoder().encode(themeData) {
                userDefaults.set(themeEncoded, forKey: themeDataKey)
            }
        } else {
            userDefaults.removeObject(forKey: intentionDataKey)
            if let themeEncoded = try? JSONEncoder().encode(defaultWidgetTheme) {
                userDefaults.set(themeEncoded, forKey: themeDataKey)
            }
        }

        #if canImport(WidgetKit) && !os(visionOS)
        WidgetCenter.shared.reloadAllTimelines()
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 200_000_000)
            WidgetCenter.shared.reloadAllTimelines()
        }
        #endif
    }

    /// Build widget theme data. Daily Intentions does not store theme per intention; use default.
    private static func widgetThemeData(for intention: Intention, modelContext: ModelContext) -> WidgetThemeData {
        return defaultWidgetTheme
    }

    // MARK: - Current intention resolution

    /// Resolve the intention to show on the widget: prefer passed-in if it applies to today, else compute from context.
    private static func resolveCurrentIntention(
        modelContext: ModelContext,
        currentIntention: Intention?
    ) -> Intention? {
        let today = Date()
        let calendar = Calendar.current

        if let provided = currentIntention, intentionAppliesToDate(provided, date: today, calendar: calendar) {
            return provided
        }
        return getCurrentDisplayIntention(modelContext: modelContext)
    }

    private static func intentionAppliesToDate(_ intention: Intention, date: Date, calendar: Calendar) -> Bool {
        switch intention.scope {
        case .day:
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            return intention.date >= startOfDay && intention.date < endOfDay
        case .week:
            let weekStart = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
            let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!
            return intention.date >= weekStart && intention.date < weekEnd
        case .month:
            let components = calendar.dateComponents([.year, .month], from: date)
            let monthStart = calendar.date(from: components) ?? date
            let monthEnd = calendar.date(byAdding: DateComponents(month: 1), to: monthStart)!
            return intention.date >= monthStart && intention.date < monthEnd
        }
    }

    private static func getCurrentDisplayIntention(modelContext: ModelContext) -> Intention? {
        let today = Date()
        if let dayIntention = getIntention(for: today, scope: .day, modelContext: modelContext) {
            return dayIntention
        }
        if let weekIntention = getIntention(for: today, scope: .week, modelContext: modelContext) {
            return weekIntention
        }
        if let monthIntention = getIntention(for: today, scope: .month, modelContext: modelContext) {
            return monthIntention
        }
        return nil
    }

    private static func getIntention(for date: Date, scope: IntentionScope, modelContext: ModelContext) -> Intention? {
        let calendar = Calendar.current
        let scopePredicate = #Predicate<Intention> { intention in
            intention.scope == scope
        }
        let descriptor = FetchDescriptor<Intention>(predicate: scopePredicate)
        let allScopeIntentions = (try? modelContext.fetch(descriptor)) ?? []

        switch scope {
        case .day:
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            return allScopeIntentions.first { $0.date >= startOfDay && $0.date < endOfDay }
        case .week:
            let weekStart = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
            let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!
            return allScopeIntentions.first { $0.date >= weekStart && $0.date < weekEnd }
        case .month:
            let components = calendar.dateComponents([.year, .month], from: date)
            let monthStart = calendar.date(from: components) ?? date
            let monthEnd = calendar.date(byAdding: DateComponents(month: 1), to: monthStart)!
            return allScopeIntentions.first { $0.date >= monthStart && $0.date < monthEnd }
        }
    }

    private static func fetchAllIntentions(modelContext: ModelContext) -> [Intention] {
        let descriptor = FetchDescriptor<Intention>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
}
