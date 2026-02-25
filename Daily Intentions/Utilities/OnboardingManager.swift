//
//  OnboardingManager.swift
//  Daily Intentions
//
//  Created for onboarding experience
//

import Foundation

/// Manages onboarding state and persistence
@MainActor
class OnboardingManager {
    static let shared = OnboardingManager()

    private init() {}

    var hasCompletedOnboarding: Bool {
        get {
            UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        }
    }

    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }

    func resetOnboarding() {
        // For testing - reset onboarding
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
    }
}

