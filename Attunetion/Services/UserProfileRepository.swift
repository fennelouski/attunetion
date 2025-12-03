//
//  UserProfileRepository.swift
//  Attunetion
//
//  Created by Nathan Fennel on 12/2/25.
//

import Foundation
import SwiftData

/// Repository for managing UserProfile (singleton - should only have one instance)
@MainActor
class UserProfileRepository {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    /// Get or create user profile (singleton pattern)
    func getOrCreateProfile() -> UserProfile {
        if let existing = getProfile() {
            return existing
        }
        
        let profile = UserProfile()
        modelContext.insert(profile)
        try? modelContext.save()
        return profile
    }
    
    /// Get current user profile
    func getProfile() -> UserProfile? {
        let descriptor = FetchDescriptor<UserProfile>()
        return try? modelContext.fetch(descriptor).first
    }
    
    /// Update user profile
    func update(_ profile: UserProfile) throws {
        profile.updatedAt = Date()
        try modelContext.save()
    }
    
    /// Delete user profile
    func delete(_ profile: UserProfile) throws {
        modelContext.delete(profile)
        try modelContext.save()
    }
}


