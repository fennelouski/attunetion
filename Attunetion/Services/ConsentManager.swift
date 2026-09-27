//
//  ConsentManager.swift
//  Attunetion
//
//  Manages user consent for AI features that share data with third parties
//

import Foundation
import SwiftData

/// Manages user consent for using suggestion features
@MainActor
class ConsentManager {
    static let shared = ConsentManager()

    private init() {}

    /// Check if user has accepted terms for using AI/suggestion features
    /// Returns true if accepted, false otherwise
    func hasAcceptedTerms(modelContext: ModelContext) -> Bool {
        let repository = UserProfileRepository(modelContext: modelContext)
        return repository.getProfile()?.hasAcceptedTerms == true
    }

    /// Mark that user has accepted terms
    func acceptTerms(modelContext: ModelContext) throws {
        let repository = UserProfileRepository(modelContext: modelContext)
        let profile = repository.getOrCreateProfile()
        let previousConsent = profile.hasAcceptedTerms
        let previousDate = profile.termsAcceptedDate
        profile.hasAcceptedTerms = true
        profile.termsAcceptedDate = Date()
        do {
            try repository.update(profile)
        } catch {
            profile.hasAcceptedTerms = previousConsent
            profile.termsAcceptedDate = previousDate
            throw error
        }
    }

    /// Revoke user consent (when they disable AI features)
    func revokeConsent(modelContext: ModelContext) throws {
        let repository = UserProfileRepository(modelContext: modelContext)
        let profile = repository.getOrCreateProfile()
        profile.hasAcceptedTerms = false
        profile.termsAcceptedDate = nil
        profile.autoGenerateEnabled = false
        try repository.update(profile)
    }

    /// Check consent before making an AI API call
    /// Throws an error if user hasn't accepted terms
    func requireConsent(modelContext: ModelContext) throws {
        guard hasAcceptedTerms(modelContext: modelContext) else {
            throw ConsentError.termsNotAccepted
        }
    }
}

/// Errors related to consent management
enum ConsentError: LocalizedError {
    case termsNotAccepted

    var errorDescription: String? {
        switch self {
        case .termsNotAccepted:
            return "You must accept the Terms of Service and Privacy Policy before using suggestion features. Please visit Settings > Suggested Intentions to review and accept."
        }
    }
}
