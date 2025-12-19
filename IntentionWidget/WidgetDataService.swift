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
    
    private init() {}
    
    /// Get default intention frequency from App Group (for widget)
    func getDefaultIntentionFrequency() -> String {
        guard let userDefaults = UserDefaults(suiteName: appGroupIdentifier) else {
            return "monthly" // Default fallback
        }
        return userDefaults.string(forKey: frequencyKey) ?? "monthly"
    }
    
    /// Get current intention data from App Group (for widget)
    func getCurrentIntentionData() -> IntentionData? {
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
        
        print("WidgetDataService: Successfully read intention: '\(intentionData.text)'")
        return intentionData
    }
    
    /// Get current theme data from App Group (for widget)
    func getCurrentThemeData() -> ThemeData? {
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



