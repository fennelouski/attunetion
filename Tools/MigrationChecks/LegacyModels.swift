// Frozen unversioned model definitions from remote afa1a117 for synthetic-store migration checks.
//
//  Intention.swift
//  Attunetion
//
//  Created by Nathan Fennel on 12/2/25.
//

import Foundation
import SwiftData

/// Model representing a user's intention for a specific time period
@Model
final class Intention {
    var id: UUID = UUID()
    var text: String = ""
    var scope: IntentionScope = IntentionScope.day
    var date: Date = Date()
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var themeId: UUID?
    var customFont: String?
    var aiGenerated: Bool = false
    var aiRephrased: Bool = false
    var quote: String?

    init(
        id: UUID = UUID(),
        text: String,
        scope: IntentionScope,
        date: Date,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        themeId: UUID? = nil,
        customFont: String? = nil,
        aiGenerated: Bool = false,
        aiRephrased: Bool = false,
        quote: String? = nil
    ) {
        self.id = id
        self.text = text
        self.scope = scope
        self.date = date
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.themeId = themeId
        self.customFont = customFont
        self.aiGenerated = aiGenerated
        self.aiRephrased = aiRephrased
        self.quote = quote
    }
}

//
//  IntentionTheme.swift
//  Attunetion
//
//  Created by Nathan Fennel on 12/2/25.
//

import Foundation
import SwiftData
import SwiftUI

/// Model representing a visual theme for intentions
@Model
final class IntentionTheme {
    var id: UUID = UUID()
    var name: String = ""
    var backgroundColor: String = "#FFFFFF" // Hex color string
    var textColor: String = "#000000" // Hex color string
    var accentColor: String? // Hex color string, optional
    var fontName: String?
    var isPreset: Bool = false
    var isAIGenerated: Bool = false
    var createdAt: Date = Date()

    init(
        id: UUID = UUID(),
        name: String,
        backgroundColor: String,
        textColor: String,
        accentColor: String? = nil,
        fontName: String? = nil,
        isPreset: Bool = false,
        isAIGenerated: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.accentColor = accentColor
        self.fontName = fontName
        self.isPreset = isPreset
        self.isAIGenerated = isAIGenerated
        self.createdAt = createdAt
    }
}

// MARK: - SwiftUI Color Conversion

extension IntentionTheme {
    /// Convert hex string to SwiftUI Color
    static func color(from hex: String) -> Color {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return Color.gray
        }
        return Color(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    /// Get SwiftUI Color for background
    var backgroundColorValue: Color {
        Self.color(from: backgroundColor)
    }

    /// Get SwiftUI Color for text
    var textColorValue: Color {
        Self.color(from: textColor)
    }

    /// Get SwiftUI Color for accent (or background if not set)
    var accentColorValue: Color {
        if let accentColor = accentColor {
            return Self.color(from: accentColor)
        }
        return backgroundColorValue
    }
}

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
    var id: UUID = UUID()
    var onboardingCompleted: Bool = false
    var defaultThemeId: UUID?
    var appThemeId: String? // App-wide UI theme ID (stored as string for CloudKit compatibility)
    var defaultFont: String?
    var defaultIntentionFrequency: String = "monthly" // Store as string for CloudKit compatibility (monthly/weekly/daily)
    var widgetThemeId: String? // Widget appearance theme ID (nil = use intention's theme)

    // Store NotificationSettings as JSON string for CloudKit compatibility
    @Attribute(.externalStorage) var notificationSettingsData: Data?

    init(
        id: UUID = UUID(),
        onboardingCompleted: Bool = false,
        defaultThemeId: UUID? = nil,
        appThemeId: String? = nil,
        defaultFont: String? = nil,
        defaultIntentionFrequency: IntentionFrequency = .monthly,
        widgetThemeId: String? = nil,
        notificationSettings: NotificationSettings = NotificationSettings()
    ) {
        self.id = id
        self.onboardingCompleted = onboardingCompleted
        self.defaultThemeId = defaultThemeId
        self.appThemeId = appThemeId
        self.defaultFont = defaultFont
        self.defaultIntentionFrequency = defaultIntentionFrequency.rawValue
        self.widgetThemeId = widgetThemeId
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

//
//  UserProfile.swift
//  Attunetion
//
//  Created by Nathan Fennel on 12/2/25.
//

import Foundation
import SwiftData

/// Model representing user profile information for AI-generated intentions
@Model
final class UserProfile {
    var id: UUID = UUID()
    var userInfo: String = "" // Free-form text about the user
    var autoGenerateEnabled: Bool = false // Whether to auto-generate intentions
    var lastGeneratedWeekStart: Date? // Start date of last generated week
    var totalGenerations: Int = 0 // Total number of generations requested
    var totalFeedbackGiven: Int = 0 // Total number of feedback submissions
    var hasAcceptedTerms: Bool = false // Whether user has accepted ToS and EULA for suggestion features
    var termsAcceptedDate: Date? // Date when terms were accepted
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    init(
        id: UUID = UUID(),
        userInfo: String = "",
        autoGenerateEnabled: Bool = false,
        lastGeneratedWeekStart: Date? = nil,
        totalGenerations: Int = 0,
        totalFeedbackGiven: Int = 0,
        hasAcceptedTerms: Bool = false,
        termsAcceptedDate: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userInfo = userInfo
        self.autoGenerateEnabled = autoGenerateEnabled
        self.lastGeneratedWeekStart = lastGeneratedWeekStart
        self.totalGenerations = totalGenerations
        self.totalFeedbackGiven = totalFeedbackGiven
        self.hasAcceptedTerms = hasAcceptedTerms
        self.termsAcceptedDate = termsAcceptedDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

//
//  IntentionFeedback.swift
//  Attunetion
//
//  Created by Nathan Fennel on 12/2/25.
//

import Foundation
import SwiftData

/// Model representing user feedback on a suggested intention
@Model
final class IntentionFeedback {
    var id: UUID = UUID()
    var intentionId: UUID = UUID()
    var isApproved: Bool = false // true for approve, false for disapprove
    var feedbackText: String? // Optional feedback text (max 100 chars)
    var createdAt: Date = Date()

    init(
        id: UUID = UUID(),
        intentionId: UUID,
        isApproved: Bool,
        feedbackText: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.intentionId = intentionId
        self.isApproved = isApproved
        self.feedbackText = feedbackText
        self.createdAt = createdAt
    }
}
