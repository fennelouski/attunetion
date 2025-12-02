//
//  ThemeRepository.swift
//  Daily Intentions
//
//  Created by Nathan Fennel on 12/2/25.
//

import Foundation
import SwiftData

/// Repository for managing IntentionTheme entities
@MainActor
class ThemeRepository {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - CRUD Operations
    
    /// Create a new theme
    func create(_ theme: IntentionTheme) throws {
        modelContext.insert(theme)
        try modelContext.save()
    }
    
    /// Get all themes
    func getAll() -> [IntentionTheme] {
        let descriptor = FetchDescriptor<IntentionTheme>(
            sortBy: [
                SortDescriptor(\.isPreset, order: .reverse),
                SortDescriptor(\.createdAt, order: .reverse)
            ]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    /// Get preset themes only
    func getPresetThemes() -> [IntentionTheme] {
        let predicate = #Predicate<IntentionTheme> { theme in
            theme.isPreset == true
        }
        
        let descriptor = FetchDescriptor<IntentionTheme>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    /// Get custom themes only
    func getCustomThemes() -> [IntentionTheme] {
        let predicate = #Predicate<IntentionTheme> { theme in
            theme.isPreset == false
        }
        
        let descriptor = FetchDescriptor<IntentionTheme>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    /// Get AI-generated themes
    func getAIGeneratedThemes() -> [IntentionTheme] {
        let predicate = #Predicate<IntentionTheme> { theme in
            theme.isAIGenerated == true
        }
        
        let descriptor = FetchDescriptor<IntentionTheme>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    /// Get theme by ID
    func getTheme(byId id: UUID) -> IntentionTheme? {
        let predicate = #Predicate<IntentionTheme> { theme in
            theme.id == id
        }
        
        let descriptor = FetchDescriptor<IntentionTheme>(predicate: predicate)
        return try? modelContext.fetch(descriptor).first
    }
    
    /// Update an existing theme
    func update(_ theme: IntentionTheme) throws {
        try modelContext.save()
    }
    
    /// Delete a theme
    func delete(_ theme: IntentionTheme) throws {
        modelContext.delete(theme)
        try modelContext.save()
    }
    
    /// Check if a preset theme exists (by name)
    func presetThemeExists(name: String) -> Bool {
        let predicate = #Predicate<IntentionTheme> { theme in
            theme.isPreset == true && theme.name == name
        }
        
        let descriptor = FetchDescriptor<IntentionTheme>(predicate: predicate)
        return (try? modelContext.fetch(descriptor).isEmpty == false) ?? false
    }
}

