//
//  PresetThemes.swift
//  Attunetion
//
//  Created by Nathan Fennel on 12/2/25.
//

import Foundation
import SwiftData

/// Preset themes for the Attunetion app
enum PresetThemes {
    /// Get all preset theme definitions
    static func getAll() -> [IntentionTheme] {
        return [
            createSerene(),
            createVibrant(),
            createMinimal(),
            createSunset(),
            createOcean()
        ]
    }
    
    /// Serene - Calm and peaceful theme
    private static func createSerene() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            name: "Serene",
            backgroundColor: "#F5F7FA",
            textColor: "#2C3E50",
            accentColor: "#A8D5BA",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0)
        )
    }
    
    /// Vibrant - Energetic and bold theme
    private static func createVibrant() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
            name: "Vibrant",
            backgroundColor: "#FF6B6B",
            textColor: "#FFFFFF",
            accentColor: "#FFE66D",
            fontName: "SF Pro Display",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0)
        )
    }
    
    /// Minimal - Clean and simple theme
    private static func createMinimal() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
            name: "Minimal",
            backgroundColor: "#FFFFFF",
            textColor: "#000000",
            accentColor: "#808080",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0)
        )
    }
    
    /// Sunset - Warm and cozy theme
    private static func createSunset() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
            name: "Sunset",
            backgroundColor: "#FF8C69",
            textColor: "#FFFFFF",
            accentColor: "#FFD700",
            fontName: "SF Pro Display",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0)
        )
    }
    
    /// Ocean - Cool and refreshing theme
    private static func createOcean() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
            name: "Ocean",
            backgroundColor: "#4A90E2",
            textColor: "#FFFFFF",
            accentColor: "#87CEEB",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0)
        )
    }
    
    /// Helper function to populate preset themes in the database
    /// This should be called during app initialization or onboarding
    static func populatePresetThemes(in repository: ThemeRepository) throws {
        let existingThemes = repository.getPresetThemes()
        let existingThemeNames = Set(existingThemes.map { $0.name })
        
        // Only add themes that don't already exist
        for theme in PresetThemes.getAll() {
            if !existingThemeNames.contains(theme.name) {
                try repository.create(theme)
            }
        }
    }
}



