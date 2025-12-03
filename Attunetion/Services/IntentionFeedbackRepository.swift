//
//  IntentionFeedbackRepository.swift
//  Attunetion
//
//  Created by Nathan Fennel on 12/2/25.
//

import Foundation
import SwiftData

/// Repository for managing IntentionFeedback entities
@MainActor
class IntentionFeedbackRepository {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    /// Create feedback for an intention
    func create(_ feedback: IntentionFeedback) throws {
        modelContext.insert(feedback)
        try modelContext.save()
    }
    
    /// Get feedback for a specific intention
    func getFeedback(for intentionId: UUID) -> IntentionFeedback? {
        let predicate = #Predicate<IntentionFeedback> { feedback in
            feedback.intentionId == intentionId
        }
        let descriptor = FetchDescriptor<IntentionFeedback>(predicate: predicate)
        return try? modelContext.fetch(descriptor).first
    }
    
    /// Get all feedback
    func getAll() -> [IntentionFeedback] {
        let descriptor = FetchDescriptor<IntentionFeedback>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    /// Delete feedback
    func delete(_ feedback: IntentionFeedback) throws {
        modelContext.delete(feedback)
        try modelContext.save()
    }
    
    /// Get feedback count for a user (for rate limiting)
    func getFeedbackCount(since date: Date) -> Int {
        let predicate = #Predicate<IntentionFeedback> { feedback in
            feedback.createdAt >= date
        }
        let descriptor = FetchDescriptor<IntentionFeedback>(predicate: predicate)
        return (try? modelContext.fetch(descriptor).count) ?? 0
    }
}


