//
//  IntentionRepository.swift
//  Attunetion
//
//  Created by Nathan Fennel on 12/2/25.
//

import Foundation
import SwiftData

/// Repository for managing Intention entities
@MainActor
class IntentionRepository {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - CRUD Operations
    
    /// Create a new intention
    func create(_ intention: Intention) throws {
        try create([intention])
    }

    /// Commit the whole guide together; a failed save must not leave a partial set.
    func create(_ intentions: [Intention]) throws {
        guard !intentions.isEmpty else { return }
        if modelContext.hasChanges { try modelContext.save() }
        let transaction = ModelContext(modelContext.container)
        transaction.autosaveEnabled = false
        var existing = try transaction.fetch(FetchDescriptor<Intention>())
        for intention in intentions {
            if let interval = intention.scope.interval(containing: intention.date),
               existing.contains(where: { $0.scope == intention.scope && $0.date >= interval.start && $0.date < interval.end }) {
                throw IntentionSaveError.alreadyExists(intention.scope)
            }
            existing.append(intention)
        }
        do {
            intentions.forEach { transaction.insert($0) }
            try transaction.save()
        } catch {
            transaction.rollback()
            throw error
        }
    }
    
    /// Get all intentions
    func getAll() -> [Intention] {
        let descriptor = FetchDescriptor<Intention>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    /// Commit draft values without saving or rolling back other pending edits.
    func update(
        _ intention: Intention,
        text: String,
        scope: IntentionScope,
        date: Date,
        appearance: (themeId: UUID?, font: String?)? = nil
    ) throws {
        let transaction = ModelContext(modelContext.container)
        transaction.autosaveEnabled = false
        let id = intention.id
        let descriptor = FetchDescriptor<Intention>(predicate: #Predicate<Intention> { $0.id == id })
        do {
            guard let stored = try transaction.fetch(descriptor).first else {
                throw IntentionSaveError.notFound
            }
            stored.text = text
            stored.scope = scope
            stored.date = date
            if let appearance {
                stored.themeId = appearance.themeId
                stored.customFont = appearance.font
            }
            stored.updatedAt = Date()
            try transaction.save()

            // Publish only this committed edit to the displayed object.
            intention.text = stored.text
            intention.scope = stored.scope
            intention.date = stored.date
            if appearance != nil {
                intention.themeId = stored.themeId
                intention.customFont = stored.customFont
            }
            intention.updatedAt = stored.updatedAt
        } catch {
            transaction.rollback()
            throw error
        }
    }
    
    /// Delete durably before changing the displayed context.
    func delete(_ intention: Intention) throws {
        let transaction = ModelContext(modelContext.container)
        transaction.autosaveEnabled = false
        let id = intention.id
        let descriptor = FetchDescriptor<Intention>(predicate: #Predicate<Intention> { $0.id == id })
        do {
            guard let stored = try transaction.fetch(descriptor).first else {
                throw IntentionSaveError.notFound
            }
            transaction.delete(stored)
            try transaction.save()
            modelContext.delete(intention)
        } catch {
            transaction.rollback()
            throw error
        }
    }
    
    // MARK: - Query Methods
    
    /// Get intention for a specific date and scope
    func getIntention(for date: Date, scope: IntentionScope) -> Intention? {
        let allScopeIntentions = getIntentions(scope: scope)
        guard let period = scope.interval(containing: date) else { return nil }
        return allScopeIntentions.first { $0.date >= period.start && $0.date < period.end }
    }
    
    /// Use the closest current focus, falling back through broader time spans.
    func getCurrentDisplayIntention() -> Intention? {
        let today = Date()
        
        for scope in IntentionScope.allCases {
            if let intention = getIntention(for: today, scope: scope) { return intention }
        }
        
        return nil
    }
    
    /// Search intentions by text
    func search(query: String) -> [Intention] {
        guard !query.isEmpty else { return getAll() }
        
        let predicate = #Predicate<Intention> { intention in
            intention.text.localizedStandardContains(query)
        }
        
        let descriptor = FetchDescriptor<Intention>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    /// Get intentions within a date range
    func getIntentions(from startDate: Date, to endDate: Date) -> [Intention] {
        let predicate = #Predicate<Intention> { intention in
            intention.date >= startDate && intention.date <= endDate
        }
        
        let descriptor = FetchDescriptor<Intention>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    /// Get intentions by scope
    func getIntentions(scope: IntentionScope) -> [Intention] {
        // SwiftData cannot query this persisted Codable enum reliably.
        // ponytail: linear scan preserves the store schema; add a primitive scope index if histories become large.
        return getAll().filter { $0.scope == scope }
    }
    
    /// Get intention by ID
    func getIntention(byId id: UUID) -> Intention? {
        let predicate = #Predicate<Intention> { intention in
            intention.id == id
        }
        
        let descriptor = FetchDescriptor<Intention>(predicate: predicate)
        return try? modelContext.fetch(descriptor).first
    }
}


enum IntentionSaveError: LocalizedError {
    case alreadyExists(IntentionScope)
    case notFound

    var errorDescription: String? {
        switch self {
        case .alreadyExists(let scope):
            return "An intention already exists for this \(scope.rawValue). Edit it from the home screen, or choose another date."
        case .notFound:
            return "This intention is no longer saved. Your draft has been kept."
        }
    }
}
