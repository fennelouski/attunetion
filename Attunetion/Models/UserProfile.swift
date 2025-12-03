//
//  UserProfile.swift
//  Attunetion
//
//  Created by Nathan Fennel on 12/2/25.
//

import Foundation
import SwiftData

/// Model representing user profile information for AI-generated intentions
@Model
final class UserProfile {
    var id: UUID
    var userInfo: String // Free-form text about the user
    var autoGenerateEnabled: Bool // Whether to auto-generate intentions
    var lastGeneratedWeekStart: Date? // Start date of last generated week
    var totalGenerations: Int // Total number of generations requested
    var totalFeedbackGiven: Int // Total number of feedback submissions
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        userInfo: String = "",
        autoGenerateEnabled: Bool = false,
        lastGeneratedWeekStart: Date? = nil,
        totalGenerations: Int = 0,
        totalFeedbackGiven: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userInfo = userInfo
        self.autoGenerateEnabled = autoGenerateEnabled
        self.lastGeneratedWeekStart = lastGeneratedWeekStart
        self.totalGenerations = totalGenerations
        self.totalFeedbackGiven = totalFeedbackGiven
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

