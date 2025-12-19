//
//  WidgetDataService.swift
//  Attunetion
//
//  Created for widget data synchronization
//

import Foundation

/// Simplified intention data for widget display
struct IntentionData: Codable {
    let id: UUID
    let text: String
    let scope: String // "day", "week", "month"
    let scopeDate: Date
    let quote: String?
    let aiGenerated: Bool
    
    /// Mock data for development
    static func mock() -> IntentionData {
        IntentionData(
            id: UUID(),
            text: "Be present with family and focus on meaningful connections",
            scope: "day",
            scopeDate: Date(),
            quote: "The greatest wealth is health.",
            aiGenerated: false
        )
    }
    
    static func mockWeek() -> IntentionData {
        IntentionData(
            id: UUID(),
            text: "Focus on health and meaningful movement",
            scope: "week",
            scopeDate: Date(),
            quote: "The greatest wealth is health.",
            aiGenerated: false
        )
    }
    
    static func mockMonth() -> IntentionData {
        IntentionData(
            id: UUID(),
            text: "Cultivate gratitude and practice mindfulness daily",
            scope: "month",
            scopeDate: Date(),
            quote: "Gratitude turns what we have into enough.",
            aiGenerated: true
        )
    }
}

/// Simplified theme data for widget display
struct ThemeData: Codable {
    let backgroundColor: String // Hex color
    let textColor: String // Hex color
    let accentColor: String? // Hex color
    let fontName: String?
    
    /// Mock theme for development
    static func mock() -> ThemeData {
        ThemeData(
            backgroundColor: "#1E3A8A",
            textColor: "#FFFFFF",
            accentColor: "#60A5FA",
            fontName: nil
        )
    }
}

/// User state data for widget empty state logic
struct WidgetUserState: Codable {
    let hasSetIntentionsBefore: Bool
    let lastIntentionDate: Date?
    let daysSinceLastIntention: Int?
    let hasSetMonthlyBefore: Bool
}

/// Service for syncing intention data to App Group for widget access
/// This class is shared between main app and widget extension
class WidgetDataService {
    static let shared = WidgetDataService()
    
    private let appGroupIdentifier = "group.com.nathanfennel.Attunetion"
    private let intentionDataKey = "currentIntentionData"
    private let themeDataKey = "currentThemeData"
    private let frequencyKey = "defaultIntentionFrequency"
    private let userStateKey = "widgetUserState"
    private let widgetThemePreferenceKey = "widgetThemePreference"
    
    private init() {}
    
    /// Update widget data with intention and theme data (called from main app)
    func updateWidgetData(intentionData: IntentionData?, themeData: ThemeData?) {
        print("WidgetDataService: updateWidgetData called - intentionData: \(intentionData != nil ? "'\(intentionData!.text)'" : "nil"), themeData: \(themeData != nil ? "present" : "nil")")
        
        guard let userDefaults = UserDefaults(suiteName: appGroupIdentifier) else {
            print("WidgetDataService: ❌ Failed to access App Group UserDefaults with identifier: \(appGroupIdentifier)")
            print("WidgetDataService: Check that App Group is configured in both app and widget entitlements")
            print("WidgetDataService: App Group identifier: \(appGroupIdentifier)")
            
            // Try to diagnose the issue
            let standardDefaults = UserDefaults.standard
            print("WidgetDataService: Standard UserDefaults accessible: \(standardDefaults != nil)")
            
            return
        }
        
        print("WidgetDataService: ✅ Successfully accessed App Group UserDefaults")
        
        if let intentionData = intentionData {
            do {
                let encoded = try JSONEncoder().encode(intentionData)
                userDefaults.set(encoded, forKey: intentionDataKey)
                print("WidgetDataService: ✅ Saved intention data to UserDefaults: '\(intentionData.text)' (key: \(intentionDataKey))")
                
                // Verify it was saved
                if let verifyData = userDefaults.data(forKey: intentionDataKey) {
                    print("WidgetDataService: ✅ Verified: Data exists in UserDefaults (\(verifyData.count) bytes)")
                } else {
                    print("WidgetDataService: ❌ Warning: Data not found immediately after saving")
                }
            } catch {
                print("WidgetDataService: ❌ Failed to encode intention data: \(error)")
            }
        } else {
            userDefaults.removeObject(forKey: intentionDataKey)
            print("WidgetDataService: Removed intention data from UserDefaults")
        }
        
        if let themeData = themeData {
            do {
                let encoded = try JSONEncoder().encode(themeData)
                userDefaults.set(encoded, forKey: themeDataKey)
                print("WidgetDataService: ✅ Saved theme data to UserDefaults")
            } catch {
                print("WidgetDataService: ❌ Failed to encode theme data: \(error)")
            }
        } else {
            userDefaults.removeObject(forKey: themeDataKey)
        }
        
        // Force synchronization
        let syncResult = userDefaults.synchronize()
        print("WidgetDataService: UserDefaults synchronized: \(syncResult)")
        
        // Also try to read it back immediately to verify
        if let verifyData = userDefaults.data(forKey: intentionDataKey) {
            print("WidgetDataService: ✅ Post-sync verification: Data exists (\(verifyData.count) bytes)")
        } else if intentionData != nil {
            print("WidgetDataService: ❌ Post-sync verification: Data NOT found!")
        }
    }
    
    /// Update widget with intention frequency preference
    func updateIntentionFrequency(_ frequency: String) {
        guard let userDefaults = UserDefaults(suiteName: appGroupIdentifier) else {
            print("Failed to access App Group UserDefaults")
            return
        }
        userDefaults.set(frequency, forKey: frequencyKey)
        userDefaults.synchronize()
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
    
    /// Save user state for widget empty state logic
    func saveUserState(_ state: WidgetUserState) {
        guard let userDefaults = UserDefaults(suiteName: appGroupIdentifier) else {
            print("Failed to access App Group UserDefaults")
            return
        }
        
        if let encoded = try? JSONEncoder().encode(state) {
            userDefaults.set(encoded, forKey: userStateKey)
            userDefaults.synchronize()
        }
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
    
    /// Get default intention frequency preference
    func getDefaultIntentionFrequency() -> String {
        guard let userDefaults = UserDefaults(suiteName: appGroupIdentifier) else {
            return "monthly"
        }
        return userDefaults.string(forKey: frequencyKey) ?? "monthly"
    }
    
    /// Update widget theme preference (nil = use intention's theme)
    func updateWidgetThemePreference(_ theme: ThemeData?) {
        guard let userDefaults = UserDefaults(suiteName: appGroupIdentifier) else {
            print("Failed to access App Group UserDefaults")
            return
        }
        
        if let theme = theme {
            if let encoded = try? JSONEncoder().encode(theme) {
                userDefaults.set(encoded, forKey: widgetThemePreferenceKey)
            }
        } else {
            userDefaults.removeObject(forKey: widgetThemePreferenceKey)
        }
        userDefaults.synchronize()
    }
    
    /// Get widget theme preference (nil = use intention's theme)
    func getWidgetThemePreference() -> ThemeData? {
        guard let userDefaults = UserDefaults(suiteName: appGroupIdentifier),
              let data = userDefaults.data(forKey: widgetThemePreferenceKey),
              let theme = try? JSONDecoder().decode(ThemeData.self, from: data) else {
            return nil
        }
        return theme
    }
}

