//
//  UserPreferences.swift
//  Daily Intentions
//
//  Created by Nathan Fennel on 12/2/25.
//

import Foundation
import SwiftData

/// Notification settings configuration
struct NotificationSettings: Codable {
    var dailyEnabled: Bool
    var dailyTime: Date?
    var weeklyEnabled: Bool
    var weeklyTime: Date?
    var weeklyDay: Int // 0-6 for Sun-Sat
    var monthlyEnabled: Bool
    var monthlyTime: Date?
    var monthlyDay: Int // 1-31
    
    init(
        dailyEnabled: Bool = false,
        dailyTime: Date? = nil,
        weeklyEnabled: Bool = false,
        weeklyTime: Date? = nil,
        weeklyDay: Int = 0,
        monthlyEnabled: Bool = false,
        monthlyTime: Date? = nil,
        monthlyDay: Int = 1
    ) {
        self.dailyEnabled = dailyEnabled
        self.dailyTime = dailyTime
        self.weeklyEnabled = weeklyEnabled
        self.weeklyTime = weeklyTime
        self.weeklyDay = weeklyDay
        self.monthlyEnabled = monthlyEnabled
        self.monthlyTime = monthlyTime
        self.monthlyDay = monthlyDay
    }
}

/// Model representing user preferences (singleton - should only have one instance)
@Model
final class UserPreferences {
    var id: UUID
    var onboardingCompleted: Bool
    var defaultThemeId: UUID?
    var defaultFont: String?
    
    // Store NotificationSettings as JSON string for CloudKit compatibility
    @Attribute(.externalStorage) var notificationSettingsData: Data?
    
    init(
        id: UUID = UUID(),
        onboardingCompleted: Bool = false,
        defaultThemeId: UUID? = nil,
        defaultFont: String? = nil,
        notificationSettings: NotificationSettings = NotificationSettings()
    ) {
        self.id = id
        self.onboardingCompleted = onboardingCompleted
        self.defaultThemeId = defaultThemeId
        self.defaultFont = defaultFont
        self.notificationSettingsData = try? JSONEncoder().encode(notificationSettings)
    }
    
    /// Convenience property to get/set notification settings
    var notificationSettings: NotificationSettings {
        get {
            guard let data = notificationSettingsData,
                  let settings = try? JSONDecoder().decode(NotificationSettings.self, from: data) else {
                return NotificationSettings()
            }
            return settings
        }
        set {
            notificationSettingsData = try? JSONEncoder().encode(newValue)
        }
    }
}

