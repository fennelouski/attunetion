//
//  OnboardingManager.swift
//  Daily Intentions
//
//  Created for onboarding experience
//

import Foundation

/// Manages onboarding state and persistence
@Observable
class OnboardingManager {
    static let shared = OnboardingManager()
    
    private let hasSeenOnboardingKey = "hasSeenOnboarding"
    
    var hasCompletedOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: hasSeenOnboardingKey) }
        set { UserDefaults.standard.set(newValue, forKey: hasSeenOnboardingKey) }
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
    }
    
    func resetOnboarding() {
        // For testing - reset onboarding
        hasCompletedOnboarding = false
    }
}

