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
            let component: Calendar.Component = intention.scope == .day ? .day : intention.scope == .week ? .weekOfYear : .month
            if let interval = Calendar.current.dateInterval(of: component, for: intention.date),
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
    
    /// Update an existing intention
    func update(_ intention: Intention) throws {
        intention.updatedAt = Date()
        try modelContext.save()
    }
    
    /// Delete an intention
    func delete(_ intention: Intention) throws {
        modelContext.delete(intention)
        try modelContext.save()
    }
    
    // MARK: - Query Methods
    
    /// Get intention for a specific date and scope
    func getIntention(for date: Date, scope: IntentionScope) -> Intention? {
        let calendar = Calendar.current
        
        let allScopeIntentions = getIntentions(scope: scope)

        // Filter by date range based on scope
        switch scope {
        case .day:
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            return allScopeIntentions.first { intention in
                intention.date >= startOfDay && intention.date < endOfDay
            }
            
        case .week:
            let weekStart = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
            let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!
            return allScopeIntentions.first { intention in
                intention.date >= weekStart && intention.date < weekEnd
            }
            
        case .month:
            let components = calendar.dateComponents([.year, .month], from: date)
            let monthStart = calendar.date(from: components) ?? date
            let monthEnd = calendar.date(byAdding: DateComponents(month: 1), to: monthStart)!
            return allScopeIntentions.first { intention in
                intention.date >= monthStart && intention.date < monthEnd
            }
        }
    }
    
    /// Get the current display intention based on hierarchy (day > week > month)
    func getCurrentDisplayIntention() -> Intention? {
        let today = Date()
        
        // Check day first
        if let dayIntention = getIntention(for: today, scope: .day) {
            return dayIntention
        }
        
        // Check week second
        if let weekIntention = getIntention(for: today, scope: .week) {
            return weekIntention
        }
        
        // Check month third
        if let monthIntention = getIntention(for: today, scope: .month) {
            return monthIntention
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

    var errorDescription: String? {
        switch self {
        case .alreadyExists(let scope):
            return "An intention already exists for this \(scope.rawValue). Edit it from the home screen, or choose another date."
        }
    }
}
