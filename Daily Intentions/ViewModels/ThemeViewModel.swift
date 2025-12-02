//
//  ThemeViewModel.swift
//  Daily Intentions
//
//  Created by Nathan Fennel on 12/2/25.
//

import Foundation
import SwiftUI

@Observable
class ThemeViewModel {
    var presetThemes: [PresetTheme] = PresetThemes.all
    var selectedTheme: PresetTheme? = nil
    
    /// Get theme by ID
    func getTheme(byId id: UUID) -> PresetTheme? {
        presetThemes.first { $0.id == id }
    }
    
    /// Generate AI theme (mock for now)
    func generateAITheme(for intentionText: String) async throws -> PresetTheme {
        // Simulate API call delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Mock AI theme generation - in real implementation, this would call the backend
        // For now, randomly select a theme based on text content
        let themes = PresetThemes.all
        let hash = abs(intentionText.hashValue)
        let selectedIndex = hash % themes.count
        return themes[selectedIndex]
    }
}

