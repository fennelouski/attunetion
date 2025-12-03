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

/// Service for syncing intention data to App Group for widget access
/// This class is shared between main app and widget extension
class WidgetDataService {
    static let shared = WidgetDataService()
    
    private let appGroupIdentifier = "group.com.nathanfennel.Attunetion"
    private let intentionDataKey = "currentIntentionData"
    private let themeDataKey = "currentThemeData"
    
    private init() {}
    
    /// Update widget data with intention and theme data (called from main app)
    func updateWidgetData(intentionData: IntentionData?, themeData: ThemeData?) {
        guard let userDefaults = UserDefaults(suiteName: appGroupIdentifier) else {
            print("Failed to access App Group UserDefaults")
            return
        }
        
        if let intentionData = intentionData {
            if let encoded = try? JSONEncoder().encode(intentionData) {
                userDefaults.set(encoded, forKey: intentionDataKey)
            }
        } else {
            userDefaults.removeObject(forKey: intentionDataKey)
        }
        
        if let themeData = themeData {
            if let encoded = try? JSONEncoder().encode(themeData) {
                userDefaults.set(encoded, forKey: themeDataKey)
            }
        } else {
            userDefaults.removeObject(forKey: themeDataKey)
        }
        
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
}

