//
//  IntentionsViewModel.swift
//  Attunetion
//
//  Created by Nathan Fennel on 12/2/25.
//

import Foundation
import SwiftUI
import SwiftData
#if canImport(WidgetKit)
import WidgetKit
#endif

/// Sort order for intentions
enum SortOrder: String, CaseIterable {
    case newestFirst = "Newest First"
    case oldestFirst = "Oldest First"
    case byScope = "By Scope"
    
    var localizedName: String {
        switch self {
        case .newestFirst:
            return String(localized: "Newest First")
        case .oldestFirst:
            return String(localized: "Oldest First")
        case .byScope:
            return String(localized: "By Scope")
        }
    }
}

@Observable
@MainActor
class IntentionsViewModel {
    private var repository: IntentionRepository
    private var themeRepository: ThemeRepository
    private let modelContext: ModelContext
    
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
        self.modelContext = modelContext
        self.repository = IntentionRepository(modelContext: modelContext)
        self.themeRepository = ThemeRepository(modelContext: modelContext)
        loadIntentions()
    }
    
    /// Load intentions from repository based on current filters
    func loadIntentions() {
        // Reset selectedScope if it's no longer available (before applying filters)
        if let selectedScope = selectedScope, let availableScopes = availableScopes {
            if !availableScopes.contains(selectedScope) {
                self.selectedScope = nil
                // Return early - didSet will call loadIntentions() again
                return
            }
        }
        
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
    
    /// Get available scopes based on existing intentions
    /// Returns nil if there are no intentions or only one scope type (filter not needed)
    var availableScopes: [IntentionScope]? {
        let allIntentions = repository.getAll()
        guard !allIntentions.isEmpty else { return nil }
        
        let uniqueScopes = Set(allIntentions.map { $0.scope })
        guard uniqueScopes.count > 1 else { return nil }
        
        // Return scopes sorted in order: day, week, month
        let scopeOrder: [IntentionScope] = [.day, .week, .month]
        return scopeOrder.filter { uniqueScopes.contains($0) }
    }
    
    // MARK: - CRUD Operations
    
    func addIntention(_ intention: Intention) throws {
        try repository.create(intention)
        loadIntentions()
        syncWidgetData()
    }
    
    func updateIntention(_ intention: Intention) throws {
        try repository.update(intention)
        loadIntentions()
        syncWidgetData()
    }
    
    func deleteIntention(_ intention: Intention) throws {
        try repository.delete(intention)
        loadIntentions()
        syncWidgetData()
    }
    
    /// Sync widget data after changes
    private func syncWidgetData() {
        WidgetDataService.shared.updateWidgetDataFromSwiftData(modelContext: modelContext)
        // Reload widget timelines (WidgetCenter not available on visionOS)
        #if canImport(WidgetKit) && !os(visionOS)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
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
