//
//  AttunetionSchema.swift
//  Attunetion
//
//  Versioned schema and migration plan for SwiftData (unversioned → V1 migration for existing users).
//

import Foundation
import SwiftData

// MARK: - Versioned Schema V1

enum AttunetionSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version {
        Schema.Version(1, 0, 0)
    }

    static var models: [any PersistentModel.Type] {
        [
            AttunetionSchemaV1.Intention.self,
            AttunetionSchemaV1.IntentionTheme.self,
            AttunetionSchemaV1.UserPreferences.self,
            AttunetionSchemaV1.UserProfile.self,
            AttunetionSchemaV1.IntentionFeedback.self,
        ]
    }

    @Model
    final class Intention {
        var id: UUID = UUID()
        var text: String = ""
        var scope: IntentionScope = IntentionScope.day
        var date: Date = Date()
        var createdAt: Date = Date()
        var updatedAt: Date = Date()
        var themeId: UUID?
        var themeSetAt: Date?
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
            themeSetAt: Date? = nil,
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
            self.themeSetAt = themeSetAt
            self.customFont = customFont
            self.aiGenerated = aiGenerated
            self.aiRephrased = aiRephrased
            self.quote = quote
        }
    }

    @Model
    final class IntentionTheme {
        var id: UUID = UUID()
        var name: String = ""
        var backgroundColor: String = "#FFFFFF" // Hex color string
        var textColor: String = "#000000" // Hex color string
        var accentColor: String?
        var fontName: String?
        var isPreset: Bool = false
        var isAIGenerated: Bool = false
        var createdAt: Date = Date()
        var themeDescription: String?
        var backgroundImageURL: String?
        var unsplashPhotoId: String?
        var unsplashDownloadLocation: String?
        var attributionText: String?
        var attributionURL: String?

        init(
            id: UUID = UUID(),
            name: String,
            backgroundColor: String,
            textColor: String,
            accentColor: String? = nil,
            fontName: String? = nil,
            isPreset: Bool = false,
            isAIGenerated: Bool = false,
            createdAt: Date = Date(),
            themeDescription: String? = nil,
            backgroundImageURL: String? = nil,
            unsplashPhotoId: String? = nil,
            unsplashDownloadLocation: String? = nil,
            attributionText: String? = nil,
            attributionURL: String? = nil
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
            self.themeDescription = themeDescription
            self.backgroundImageURL = backgroundImageURL
            self.unsplashPhotoId = unsplashPhotoId
            self.unsplashDownloadLocation = unsplashDownloadLocation
            self.attributionText = attributionText
            self.attributionURL = attributionURL
        }
    }

    @Model
    final class UserPreferences {
        var id: UUID = UUID()
        var onboardingCompleted: Bool = false
        var defaultThemeId: UUID?
        var appThemeId: String?
        var defaultFont: String?
        var defaultIntentionFrequency: String = "monthly" // Store as string for CloudKit compatibility (monthly/weekly/daily)
        var widgetThemeId: String?
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
            self.notificationSettingsData = Self.encodeNotificationSettings(notificationSettings)
        }
    }

    @Model
    final class UserProfile {
        var id: UUID = UUID()
        var userInfo: String = "" // Free-form text about the user
        var autoGenerateEnabled: Bool = false // Whether to auto-generate intentions
        var lastGeneratedWeekStart: Date?
        var totalGenerations: Int = 0 // Total number of generations requested
        var totalFeedbackGiven: Int = 0 // Total number of feedback submissions
        var hasAcceptedTerms: Bool = false // Whether user has accepted ToS and EULA for suggestion features
        var termsAcceptedDate: Date?
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

    @Model
    final class IntentionFeedback {
        var id: UUID = UUID()
        var intentionId: UUID = UUID()
        var isApproved: Bool = false // true for approve, false for disapprove
        var feedbackText: String?
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
}

// MARK: - Migration Plan

enum AttunetionMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [AttunetionSchemaV1.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}
