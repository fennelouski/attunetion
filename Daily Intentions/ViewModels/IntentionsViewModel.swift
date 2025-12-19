//
//  IntentionsViewModel.swift
//  Daily Intentions
//
//  Created by Nathan Fennel on 12/19/25.
//

import Foundation
import SwiftUI
import SwiftData

@Observable
@MainActor
class IntentionsViewModel {
    private let modelContext: ModelContext

    var intentions: [Intention] = []

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadIntentions()
    }

    /// Load all intentions
    func loadIntentions() {
        do {
            let descriptor = FetchDescriptor<Intention>(
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            intentions = try modelContext.fetch(descriptor)
        } catch {
            print("Error loading intentions: \(error)")
            intentions = []
        }
    }

    /// Add a new intention
    func addIntention(_ intention: Intention) throws {
        modelContext.insert(intention)
        try modelContext.save()
        loadIntentions()
    }

    /// Update an existing intention
    func updateIntention(_ intention: Intention) throws {
        try modelContext.save()
        loadIntentions()
    }

    /// Delete an intention
    func deleteIntention(_ intention: Intention) throws {
        modelContext.delete(intention)
        try modelContext.save()
        loadIntentions()
    }

    /// Check if an intention already exists for a given date and scope
    func intentionExists(for date: Date, scope: IntentionScope) -> Bool {
        let calendar = Calendar.current

        // For day scope, check if date is the same day
        if scope == .day {
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

            do {
                let descriptor = FetchDescriptor<Intention>(
                    predicate: #Predicate<Intention> { intention in
                        intention.scope == scope &&
                        intention.date >= startOfDay &&
                        intention.date < endOfDay
                    }
                )
                let existing = try modelContext.fetch(descriptor)
                return !existing.isEmpty
            } catch {
                return false
            }
        } else {
            // For week/month scope, check exact date match
            do {
                let descriptor = FetchDescriptor<Intention>(
                    predicate: #Predicate<Intention> { intention in
                        intention.scope == scope && intention.date == date
                    }
                )
                let existing = try modelContext.fetch(descriptor)
                return !existing.isEmpty
            } catch {
                return false
            }
        }
    }
}
