//
//  IntentionFeedback.swift
//  Attunetion
//
//  Created by Nathan Fennel on 12/2/25.
//

import Foundation
import SwiftData

/// Model representing user feedback on a suggested intention
@Model
final class IntentionFeedback {
    var id: UUID
    var intentionId: UUID
    var isApproved: Bool // true for approve, false for disapprove
    var feedbackText: String? // Optional feedback text (max 100 chars)
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        intentionId: UUID,
        isApproved: Bool,
        feedbackText: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.intentionId = intentionId
        self.isApproved = isApproved
        self.feedbackText = feedbackText
        self.createdAt = createdAt
    }
}


