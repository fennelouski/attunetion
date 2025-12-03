//
//  UserPreferences.swift
//  Attunetion
//
//  Created by Nathan Fennel on 12/2/25.
//

import Foundation
import SwiftData

/// Types of notifications users can receive
enum NotificationType: String, Codable, CaseIterable {
    case reminderToAdd = "reminder_to_add"
    case reminderOfIntention = "reminder_of_intention"
    case encouragement = "encouragement"
    case timeOfDay = "time_of_day"
    
    var displayName: String {
        switch self {
        case .reminderToAdd:
            return String(localized: "Remind me to add an intention")
        case .reminderOfIntention:
            return String(localized: "Show me my current intention")
        case .encouragement:
            return String(localized: "Send encouragement")
        case .timeOfDay:
            return String(localized: "Time-based reminders")
        }
    }
    
    var description: String {
        switch self {
        case .reminderToAdd:
            return String(localized: "Get reminded when it's time to set a new intention")
        case .reminderOfIntention:
            return String(localized: "See your current intention throughout the day")
        case .encouragement:
            return String(localized: "Receive uplifting messages to stay motivated")
        case .timeOfDay:
            return String(localized: "Reminders at specific times you choose")
        }
    }
}

/// Frequency level for notifications (maps to actual frequency)
enum NotificationFrequency: Int, Codable, CaseIterable {
    case oncePerMonth = 0      // ~1 per month
    case twicePerMonth = 1      // ~2 per month
    case oncePerWeek = 2        // ~1 per week
    case twicePerWeek = 3       // ~2 per week
    case everyOtherDay = 4      // ~3-4 per week
    case daily = 5              // ~1 per day
    case twiceDaily = 6         // ~2 per day
    
    var displayName: String {
        switch self {
        case .oncePerMonth:
            return String(localized: "Once a month")
        case .twicePerMonth:
            return String(localized: "Twice a month")
        case .oncePerWeek:
            return String(localized: "Once a week")
        case .twicePerWeek:
            return String(localized: "Twice a week")
        case .everyOtherDay:
            return String(localized: "Every other day")
        case .daily:
            return String(localized: "Once a day")
        case .twiceDaily:
            return String(localized: "Twice a day")
        }
    }
    
    var description: String {
        switch self {
        case .oncePerMonth:
            return String(localized: "Just a gentle monthly reminder")
        case .twicePerMonth:
            return String(localized: "A couple reminders each month")
        case .oncePerWeek:
            return String(localized: "Weekly check-ins")
        case .twicePerWeek:
            return String(localized: "A few times each week")
        case .everyOtherDay:
            return String(localized: "Regular reminders")
        case .daily:
            return String(localized: "Daily reminders")
        case .twiceDaily:
            return String(localized: "Morning and evening reminders")
        }
    }
}

/// Time range for blackout periods
nonisolated struct BlackoutTime: Codable {
    var startHour: Int  // 0-23
    var startMinute: Int  // 0-59
    var endHour: Int  // 0-23
    var endMinute: Int  // 0-59
    
    init(startHour: Int = 22, startMinute: Int = 0, endHour: Int = 8, endMinute: Int = 0) {
        self.startHour = startHour
        self.startMinute = startMinute
        self.endHour = endHour
        self.endMinute = endMinute
    }
}

/// Notification settings configuration
nonisolated struct NotificationSettings: Codable {
    // Frequency control
    var frequency: NotificationFrequency
    
    // Notification types enabled
    var enabledTypes: Set<NotificationType>
    
    // Preferred times (for time-based notifications)
    var morningTime: Date?
    var eveningTime: Date?
    
    // Blackout settings
    var blackoutEnabled: Bool
    var blackoutTime: BlackoutTime
    var blackoutDays: Set<Int> // 0-6 for Sun-Sat
    
    // Legacy fields (for backward compatibility)
    var dailyEnabled: Bool
    var dailyTime: Date?
    var weeklyEnabled: Bool
    var weeklyTime: Date?
    var weeklyDay: Int
    var monthlyEnabled: Bool
    var monthlyTime: Date?
    var monthlyDay: Int
    
    init(
        frequency: NotificationFrequency = .daily,
        enabledTypes: Set<NotificationType> = [.reminderToAdd],
        morningTime: Date? = nil,
        eveningTime: Date? = nil,
        blackoutEnabled: Bool = true,
        blackoutTime: BlackoutTime = BlackoutTime(),
        blackoutDays: Set<Int> = [],
        dailyEnabled: Bool = false,
        dailyTime: Date? = nil,
        weeklyEnabled: Bool = false,
        weeklyTime: Date? = nil,
        weeklyDay: Int = 0,
        monthlyEnabled: Bool = false,
        monthlyTime: Date? = nil,
        monthlyDay: Int = 1
    ) {
        self.frequency = frequency
        self.enabledTypes = enabledTypes
        self.morningTime = morningTime
        self.eveningTime = eveningTime
        self.blackoutEnabled = blackoutEnabled
        self.blackoutTime = blackoutTime
        self.blackoutDays = blackoutDays
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

/// Frequency for setting intentions
enum IntentionFrequency: String, Codable, CaseIterable {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    
    var displayName: String {
        switch self {
        case .daily:
            return String(localized: "Daily")
        case .weekly:
            return String(localized: "Weekly")
        case .monthly:
            return String(localized: "Monthly")
        }
    }
    
    var description: String {
        switch self {
        case .daily:
            return String(localized: "Set a new intention each day")
        case .weekly:
            return String(localized: "Set a new intention each week")
        case .monthly:
            return String(localized: "Set a new intention each month")
        }
    }
    
    var placeholderText: String {
        switch self {
        case .daily:
            return String(localized: "Set your intention for today")
        case .weekly:
            return String(localized: "Set your intention for this week")
        case .monthly:
            return String(localized: "Set your intention for this month")
        }
    }
}

/// Model representing user preferences (singleton - should only have one instance)
@Model
final class UserPreferences {
    var id: UUID
    var onboardingCompleted: Bool
    var defaultThemeId: UUID?
    var appThemeId: String? // App-wide UI theme ID (stored as string for CloudKit compatibility)
    var defaultFont: String?
    var defaultIntentionFrequency: String // Store as string for CloudKit compatibility (monthly/weekly/daily)
    
    // Store NotificationSettings as JSON string for CloudKit compatibility
    @Attribute(.externalStorage) var notificationSettingsData: Data?
    
    init(
        id: UUID = UUID(),
        onboardingCompleted: Bool = false,
        defaultThemeId: UUID? = nil,
        appThemeId: String? = nil,
        defaultFont: String? = nil,
        defaultIntentionFrequency: IntentionFrequency = .monthly,
        notificationSettings: NotificationSettings = NotificationSettings()
    ) {
        self.id = id
        self.onboardingCompleted = onboardingCompleted
        self.defaultThemeId = defaultThemeId
        self.appThemeId = appThemeId
        self.defaultFont = defaultFont
        self.defaultIntentionFrequency = defaultIntentionFrequency.rawValue
        // Encode synchronously - NotificationSettings is a plain struct, so encoding is safe
        self.notificationSettingsData = Self.encodeNotificationSettings(notificationSettings)
    }
    
    /// Convenience property to get/set intention frequency
    var intentionFrequency: IntentionFrequency {
        get {
            IntentionFrequency(rawValue: defaultIntentionFrequency) ?? .monthly
        }
        set {
            defaultIntentionFrequency = newValue.rawValue
        }
    }
    
    /// Convenience property to get/set notification settings
    var notificationSettings: NotificationSettings {
        get {
            guard let data = notificationSettingsData else {
                return NotificationSettings()
            }
            return Self.decodeNotificationSettings(from: data)
        }
        set {
            notificationSettingsData = Self.encodeNotificationSettings(newValue)
        }
    }
    
    /// Nonisolated helper to decode NotificationSettings
    nonisolated private static func decodeNotificationSettings(from data: Data) -> NotificationSettings {
        guard let settings = try? JSONDecoder().decode(NotificationSettings.self, from: data) else {
            return NotificationSettings()
        }
        return settings
    }
    
    /// Nonisolated helper to encode NotificationSettings
    nonisolated private static func encodeNotificationSettings(_ settings: NotificationSettings) -> Data? {
        return try? JSONEncoder().encode(settings)
    }
}

