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

/// Model representing a user's intention for a specific time period (versioned schema V1)
typealias Intention = AttunetionSchemaV1.Intention

