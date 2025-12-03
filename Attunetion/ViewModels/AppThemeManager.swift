//
//  AppThemeManager.swift
//  Attunetion
//
//  Created for app-wide theme management
//

import SwiftUI
import SwiftData
import Combine

/// Environment object to manage app-wide theme
class AppThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme
    
    var userPreferencesRepository: UserPreferencesRepository?
    private var modelContext: ModelContext?
    
    init(modelContext: ModelContext? = nil) {
        // Initialize with default theme
        self.currentTheme = .defaultTheme
        self.modelContext = modelContext
        
        // Try to load saved theme preference
        if let context = modelContext {
            self.userPreferencesRepository = UserPreferencesRepository(modelContext: context)
            loadThemePreference()
            
            // Observe CloudKit changes for theme sync
            observeCloudKitChanges(context: context)
        } else {
            self.userPreferencesRepository = nil
        }
    }
    
    /// Observe CloudKit changes to reload theme when synced from another device
    /// Note: SwiftData with CloudKit automatically syncs changes. This is a placeholder
    /// for future implementation if we need to detect sync events specifically.
    private func observeCloudKitChanges(context: ModelContext) {
        // SwiftData with CloudKit handles sync automatically
        // If we need to detect sync events, we can observe ModelContext changes
        // For now, theme will reload on app launch and when explicitly changed
    }
    
    /// Load theme preference from UserPreferences
    @MainActor
    func loadThemePreference() {
        guard let repo = userPreferencesRepository,
              let prefs = repo.getPreferences(),
              let themeIdString = prefs.appThemeId,
              let themeId = UUID(uuidString: themeIdString) else {
            return
        }
        
        // Find theme by ID in preset themes
        if let theme = AppTheme.presetThemes.first(where: { $0.id == themeId }),
           theme.id != currentTheme.id {
            // Only update if theme actually changed (prevents unnecessary UI updates)
            self.currentTheme = theme
        }
    }
    
    /// Set current theme and save preference
    @MainActor
    func setTheme(_ theme: AppTheme) {
        self.currentTheme = theme
        saveThemePreference()
    }
    
    /// Save theme preference to UserPreferences
    private func saveThemePreference() {
        guard let repo = userPreferencesRepository else { return }
        
        let prefs = repo.getPreferences() ?? UserPreferences()
        prefs.appThemeId = currentTheme.id.uuidString
        repo.savePreferences(prefs)
    }
    
    /// Get color for current color scheme
    func backgroundColor(for colorScheme: ColorScheme) -> ThemeColor {
        colorScheme == .dark ? currentTheme.darkBackground : currentTheme.lightBackground
    }
    
    func primaryTextColor(for colorScheme: ColorScheme) -> ThemeColor {
        colorScheme == .dark ? currentTheme.darkPrimaryText : currentTheme.lightPrimaryText
    }
    
    func secondaryTextColor(for colorScheme: ColorScheme) -> ThemeColor {
        colorScheme == .dark ? currentTheme.darkSecondaryText : currentTheme.lightSecondaryText
    }
    
    func accentColor(for colorScheme: ColorScheme) -> ThemeColor {
        colorScheme == .dark ? currentTheme.darkAccent : currentTheme.lightAccent
    }
    
    func buttonBackgroundColor(for colorScheme: ColorScheme) -> ThemeColor {
        colorScheme == .dark ? currentTheme.darkButtonBackground : currentTheme.lightButtonBackground
    }
    
    func buttonTextColor(for colorScheme: ColorScheme) -> ThemeColor {
        colorScheme == .dark ? currentTheme.darkButtonText : currentTheme.lightButtonText
    }
    
    func secondaryButtonBackgroundColor(for colorScheme: ColorScheme) -> ThemeColor {
        colorScheme == .dark ? currentTheme.darkSecondaryButtonBackground : currentTheme.lightSecondaryButtonBackground
    }
    
    func secondaryButtonTextColor(for colorScheme: ColorScheme) -> ThemeColor {
        colorScheme == .dark ? currentTheme.darkSecondaryButtonText : currentTheme.lightSecondaryButtonText
    }
}

