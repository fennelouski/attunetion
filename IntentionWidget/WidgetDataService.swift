//
//  WidgetDataService.swift
//  IntentionWidget
//
//  Shared service for reading widget data from App Group
//  This file is in the widget target to avoid target membership issues
//

import Foundation

/// User state data for widget empty state logic
struct WidgetUserState: Codable {
    let hasSetIntentionsBefore: Bool
    let lastIntentionDate: Date?
    let daysSinceLastIntention: Int?
    let hasSetMonthlyBefore: Bool
}

/// Service for reading intention data from App Group (widget target version)
class WidgetDataService {
    static let shared = WidgetDataService()
    
    private let appGroupIdentifier = "group.com.nathanfennel.Attunetion"
    private let intentionDataKey = "currentIntentionData"
    private let themeDataKey = "currentThemeData"
    private let frequencyKey = "defaultIntentionFrequency"
    private let userStateKey = "widgetUserState"
    private let recordsKey = "widgetIntentionRecordsV1"
    
    private init() {}

    func widgetRecords() -> [IntentionWidgetRecord]? {
        guard let defaults = UserDefaults(suiteName: appGroupIdentifier),
              let data = defaults.data(forKey: recordsKey) else { return nil }
        return try? JSONDecoder().decode([IntentionWidgetRecord].self, from: data)
    }

    func nextBoundary(after date: Date) -> Date {
        if let records = widgetRecords() { return IntentionWidgetRecord.nextBoundary(in: records, after: date) }
        return WidgetRefreshSchedule.nextRefreshDate(scope: getCurrentIntentionData()?.scope, after: date)
    }
    
    /// Get default intention frequency from App Group (for widget)
    func getDefaultIntentionFrequency() -> String {
        guard let userDefaults = UserDefaults(suiteName: appGroupIdentifier) else {
            return "monthly" // Default fallback
        }
        return userDefaults.string(forKey: frequencyKey) ?? "monthly"
    }
    
    /// Get current intention data from App Group (for widget)
    func getCurrentIntentionData() -> IntentionData? {
        if let records = widgetRecords() {
            guard let record = IntentionWidgetRecord.current(from: records, at: Date()) else { return nil }
            return IntentionData(id: record.id, text: record.text, scope: record.scope,
                                 scopeDate: record.scopeDate, quote: record.quote, aiGenerated: record.aiGenerated)
        }
        guard let userDefaults = UserDefaults(suiteName: appGroupIdentifier) else {
            print("WidgetDataService: Failed to access App Group UserDefaults")
            return nil
        }
        
        guard let data = userDefaults.data(forKey: intentionDataKey) else {
            print("WidgetDataService: No data found for key '\(intentionDataKey)'")
            return nil
        }
        
        guard let intentionData = try? JSONDecoder().decode(IntentionData.self, from: data) else {
            print("WidgetDataService: Failed to decode intention data")
            return nil
        }
        
        guard let scope = IntentionScope(rawValue: intentionData.scope), scope.isCurrent(intentionData.scopeDate) else { return nil }
        return intentionData
    }
    
    /// Get current theme data from App Group (for widget)
    func getCurrentThemeData() -> ThemeData? {
        if let records = widgetRecords(), let record = IntentionWidgetRecord.current(from: records, at: Date()),
           let background = record.backgroundColor, let text = record.textColor {
            return ThemeData(backgroundColor: background, textColor: text, accentColor: record.accentColor, fontName: record.fontName)
        }
        guard let userDefaults = UserDefaults(suiteName: appGroupIdentifier),
              let data = userDefaults.data(forKey: themeDataKey),
              let themeData = try? JSONDecoder().decode(ThemeData.self, from: data) else {
            return nil
        }
        return themeData
    }
    
    /// Get user state for widget empty state logic
    func getUserState() -> WidgetUserState? {
        guard let userDefaults = UserDefaults(suiteName: appGroupIdentifier),
              let data = userDefaults.data(forKey: userStateKey),
              let userState = try? JSONDecoder().decode(WidgetUserState.self, from: data) else {
            return nil
        }
        return userState
    }
}


