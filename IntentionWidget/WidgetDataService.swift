//
//  WidgetDataService.swift
//  IntentionWidget
//
//  Shared service for reading widget data from App Group
//  This file is in the widget target to avoid target membership issues
//

import Foundation

/// Service for reading intention data from App Group (widget target version)
class WidgetDataService {
    static let shared = WidgetDataService()
    
    private let appGroupIdentifier = "group.com.nathanfennel.Attunetion"
    private let intentionDataKey = "currentIntentionData"
    private let themeDataKey = "currentThemeData"
    private let frequencyKey = "defaultIntentionFrequency"
    
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
        guard let userDefaults = UserDefaults(suiteName: appGroupIdentifier),
              let data = userDefaults.data(forKey: intentionDataKey),
              let intentionData = try? JSONDecoder().decode(IntentionData.self, from: data) else {
            return nil
        }
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
}



