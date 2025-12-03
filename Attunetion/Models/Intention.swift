//
//  Intention.swift
//  Attunetion
//
//  Created by Nathan Fennel on 12/2/25.
//

import Foundation
import SwiftData

/// Represents the scope of an intention (day, week, or month)
enum IntentionScope: String, Codable, CaseIterable, Hashable {
    case day = "day"
    case week = "week"
    case month = "month"
}

/// Model representing a user's intention for a specific time period
@Model
final class Intention {
    var id: UUID
    var text: String
    var scope: IntentionScope
    var date: Date
    var createdAt: Date
    var updatedAt: Date
    var themeId: UUID?
    var customFont: String?
    var aiGenerated: Bool
    var aiRephrased: Bool
    var quote: String?
    
    init(
        id: UUID = UUID(),
        text: String,
        scope: IntentionScope,
        date: Date,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        themeId: UUID? = nil,
        customFont: String? = nil,
        aiGenerated: Bool = false,
        aiRephrased: Bool = false,
        quote: String? = nil
    ) {
        self.id = id
        self.text = text
        self.scope = scope
        self.date = date
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.themeId = themeId
        self.customFont = customFont
        self.aiGenerated = aiGenerated
        self.aiRephrased = aiRephrased
        self.quote = quote
    }
}

