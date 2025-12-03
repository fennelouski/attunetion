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
        modelContext.insert(intention)
        try modelContext.save()
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
        
        // Fetch all intentions for this scope, then filter by date in memory
        // This avoids Predicate macro limitations with date comparisons
        let scopePredicate = #Predicate<Intention> { intention in
            intention.scope == scope
        }
        let descriptor = FetchDescriptor<Intention>(predicate: scopePredicate)
        let allScopeIntentions = (try? modelContext.fetch(descriptor)) ?? []
        
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
        let predicate = #Predicate<Intention> { intention in
            intention.scope == scope
        }
        
        let descriptor = FetchDescriptor<Intention>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
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

