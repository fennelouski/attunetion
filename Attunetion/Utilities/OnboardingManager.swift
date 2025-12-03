//
//  OnboardingManager.swift
//  Attunetion
//
//  Created for onboarding experience
//

import Foundation
import SwiftData

/// Manages onboarding state and persistence
@Observable
@MainActor
class OnboardingManager {
    static let shared = OnboardingManager()
    
    private var modelContext: ModelContext?
    
    private init() {}
    
    /// Set the model context for accessing UserPreferences
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    var hasCompletedOnboarding: Bool {
        get {
            guard let modelContext = modelContext else {
                // Fallback to UserDefaults if ModelContext not set yet
                return UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
            }
            let prefsRepo = UserPreferencesRepository(modelContext: modelContext)
            return prefsRepo.getPreferences()?.onboardingCompleted ?? false
        }
    }
    
    func completeOnboarding() {
        guard let modelContext = modelContext else {
            // Fallback to UserDefaults if ModelContext not set yet
            UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
            return
        }
        let prefsRepo = UserPreferencesRepository(modelContext: modelContext)
        do {
            try prefsRepo.markOnboardingCompleted()
        } catch {
            print("Failed to mark onboarding as completed: \(error)")
            // Fallback to UserDefaults
            UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        }
    }
    
    func resetOnboarding() {
        // For testing - reset onboarding
        guard let modelContext = modelContext else {
            UserDefaults.standard.set(false, forKey: "hasSeenOnboarding")
            return
        }
        let prefsRepo = UserPreferencesRepository(modelContext: modelContext)
        if let prefs = prefsRepo.getPreferences() {
            prefs.onboardingCompleted = false
            try? prefsRepo.update(prefs)
        }
    }
}

