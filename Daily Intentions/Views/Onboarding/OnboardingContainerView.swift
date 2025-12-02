//
//  OnboardingContainerView.swift
//  Daily Intentions
//
//  Created for onboarding experience
//

import SwiftUI

/// Main coordinator for the onboarding flow
struct OnboardingContainerView: View {
    @State private var currentPage = 0
    @Environment(\.dismiss) private var dismiss
    
    var onComplete: (() -> Void)?
    
    private let totalPages = 5
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            // Page content
            TabView(selection: $currentPage) {
                WelcomePage(
                    onContinue: nextPage,
                    onSkip: completeOnboarding
                )
                .tag(0)
                
                HowItWorksPage(
                    onContinue: nextPage,
                    onSkip: completeOnboarding
                )
                .tag(1)
                
                WidgetSetupPage(
                    onContinue: nextPage,
                    onSkip: completeOnboarding
                )
                .tag(2)
                
                NotificationPermissionPage(
                    onContinue: nextPage,
                    onSkip: completeOnboarding
                )
                .tag(3)
                
                FirstIntentionPage(
                    onComplete: completeOnboarding
                )
                .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: currentPage)
            
            // Skip button overlay
            VStack {
                HStack {
                    Spacer()
                    Button("Skip") {
                        completeOnboarding()
                    }
                    .padding()
                    .foregroundStyle(.secondary)
                }
                Spacer()
            }
            
            // Page indicator overlay
            VStack {
                Spacer()
                OnboardingPageIndicator(
                    currentPage: currentPage,
                    pageCount: totalPages
                )
                .padding(.bottom, 40)
            }
        }
    }
    
    func nextPage() {
        if currentPage < totalPages - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPage += 1
            }
        } else {
            completeOnboarding()
        }
    }
    
    func completeOnboarding() {
        OnboardingManager.shared.completeOnboarding()
        onComplete?()
        dismiss()
    }
}

#Preview {
    OnboardingContainerView()
}

