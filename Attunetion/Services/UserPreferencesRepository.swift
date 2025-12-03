//
//  UserPreferencesRepository.swift
//  Attunetion
//
//  Created by Nathan Fennel on 12/2/25.
//

import Foundation
import SwiftData

/// Repository for managing UserPreferences (singleton pattern)
@MainActor
class UserPreferencesRepository {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Singleton Management
    
    /// Get or create the single UserPreferences instance
    func getOrCreatePreferences() -> UserPreferences {
        if let existing = getPreferences() {
            // Sync frequency to widget
            WidgetDataService.shared.updateIntentionFrequency(existing.intentionFrequency.rawValue)
            return existing
        }
        
        let newPreferences = UserPreferences()
        do {
            try create(newPreferences)
            // Sync frequency to widget
            WidgetDataService.shared.updateIntentionFrequency(newPreferences.intentionFrequency.rawValue)
        } catch {
            print("Failed to create UserPreferences: \(error)")
        }
        return newPreferences
    }
    
    /// Get the current preferences (returns nil if none exist)
    func getPreferences() -> UserPreferences? {
        let descriptor = FetchDescriptor<UserPreferences>()
        return try? modelContext.fetch(descriptor).first
    }
    
    // MARK: - CRUD Operations
    
    /// Create preferences (should only be called once)
    func create(_ preferences: UserPreferences) throws {
        // Ensure only one instance exists
        if getPreferences() != nil {
            throw UserPreferencesError.alreadyExists
        }
        
        modelContext.insert(preferences)
        try modelContext.save()
    }
    
    /// Update preferences
    func update(_ preferences: UserPreferences) throws {
        try modelContext.save()
    }
    
    /// Delete preferences (use with caution)
    func delete(_ preferences: UserPreferences) throws {
        modelContext.delete(preferences)
        try modelContext.save()
    }
    
    // MARK: - Convenience Methods
    
    /// Mark onboarding as completed
    func markOnboardingCompleted() throws {
        let preferences = getOrCreatePreferences()
        preferences.onboardingCompleted = true
        try update(preferences)
    }
    
    /// Set default theme
    func setDefaultTheme(_ themeId: UUID?) throws {
        let preferences = getOrCreatePreferences()
        preferences.defaultThemeId = themeId
        try update(preferences)
    }
    
    /// Set default font
    func setDefaultFont(_ fontName: String?) throws {
        let preferences = getOrCreatePreferences()
        preferences.defaultFont = fontName
        try update(preferences)
    }
    
    /// Save preferences (convenience method)
    func savePreferences(_ preferences: UserPreferences) {
        do {
            try update(preferences)
        } catch {
            print("Failed to save preferences: \(error)")
        }
    }
    
    /// Update notification settings
    func updateNotificationSettings(_ settings: NotificationSettings) throws {
        let preferences = getOrCreatePreferences()
        preferences.notificationSettings = settings
        try update(preferences)
    }
}

/// Errors for UserPreferences operations
enum UserPreferencesError: Error {
    case alreadyExists
    case notFound
}

