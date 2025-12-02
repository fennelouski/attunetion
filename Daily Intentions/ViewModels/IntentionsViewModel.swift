//
//  IntentionsViewModel.swift
//  Daily Intentions
//
//  Created by Nathan Fennel on 12/2/25.
//

import Foundation
import SwiftUI
import SwiftData

/// Sort order for intentions
enum SortOrder: String, CaseIterable {
    case newestFirst = "Newest First"
    case oldestFirst = "Oldest First"
    case byScope = "By Scope"
}

@Observable
@MainActor
class IntentionsViewModel {
    private var repository: IntentionRepository
    private var themeRepository: ThemeRepository
    
    var intentions: [Intention] = []
    var searchQuery: String = "" {
        didSet {
            loadIntentions()
        }
    }
    var selectedScope: IntentionScope? = nil {
        didSet {
            loadIntentions()
        }
    }
    var sortOrder: SortOrder = .newestFirst {
        didSet {
            loadIntentions()
        }
    }
    
    init(modelContext: ModelContext) {
        self.repository = IntentionRepository(modelContext: modelContext)
        self.themeRepository = ThemeRepository(modelContext: modelContext)
        loadIntentions()
    }
    
    /// Load intentions from repository based on current filters
    func loadIntentions() {
        if !searchQuery.isEmpty {
            intentions = repository.search(query: searchQuery)
        } else {
            intentions = repository.getAll()
        }
        
        // Apply scope filter if selected
        if let selectedScope = selectedScope {
            intentions = intentions.filter { $0.scope == selectedScope }
        }
        
        // Apply sorting
        switch sortOrder {
        case .newestFirst:
            intentions = intentions.sorted { $0.date > $1.date }
        case .oldestFirst:
            intentions = intentions.sorted { $0.date < $1.date }
        case .byScope:
            intentions = intentions.sorted { first, second in
                let scopeOrder: [IntentionScope] = [.day, .week, .month]
                let firstIndex = scopeOrder.firstIndex(of: first.scope) ?? 0
                let secondIndex = scopeOrder.firstIndex(of: second.scope) ?? 0
                if firstIndex == secondIndex {
                    return first.date > second.date
                }
                return firstIndex < secondIndex
            }
        }
    }
    
    /// Filtered and sorted intentions based on current filters
    var filteredIntentions: [Intention] {
        return intentions
    }
    
    /// Get the current active intention based on hierarchy (day > week > month)
    var currentIntention: Intention? {
        return repository.getCurrentDisplayIntention()
    }
    
    /// Get all intentions except the current one
    var pastAndFutureIntentions: [Intention] {
        guard let current = currentIntention else {
            return filteredIntentions
        }
        return filteredIntentions.filter { $0.id != current.id }
    }
    
    // MARK: - CRUD Operations
    
    func addIntention(_ intention: Intention) throws {
        try repository.create(intention)
        loadIntentions()
    }
    
    func updateIntention(_ intention: Intention) throws {
        try repository.update(intention)
        loadIntentions()
    }
    
    func deleteIntention(_ intention: Intention) throws {
        try repository.delete(intention)
        loadIntentions()
    }
    
    func deleteIntention(at indexSet: IndexSet, from list: [Intention]) throws {
        for index in indexSet {
            let intention = list[index]
            try deleteIntention(intention)
        }
    }
    
    /// Check if an intention already exists for a given date and scope
    func intentionExists(for date: Date, scope: IntentionScope) -> Bool {
        return repository.getIntention(for: date, scope: scope) != nil
    }
    
    /// Get theme for an intention
    func getTheme(for intention: Intention) -> IntentionTheme? {
        guard let themeId = intention.themeId else { return nil }
        return themeRepository.getTheme(byId: themeId)
    }
}
