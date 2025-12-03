//
//  OnboardingContainerView.swift
//  Attunetion
//
//  Created for onboarding experience
//

import SwiftUI
import SwiftData
#if os(macOS)
import AppKit
#endif

/// Main coordinator for the onboarding flow
struct OnboardingContainerView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var currentPage = 0
    @Environment(\.dismiss) private var dismiss
    @StateObject private var themeManager: AppThemeManager
    
    var onComplete: (() -> Void)?
    
    @State private var showCrossPlatformPage = false
    
    // Computed property to determine if cross-platform page should be shown
    private var shouldShowCrossPlatformPage: Bool {
        showCrossPlatformPage
    }
    
    // Adjusted current page for indicator (accounts for skipped cross-platform page)
    private var adjustedCurrentPage: Int {
        if !shouldShowCrossPlatformPage && currentPage >= 4 {
            // If we skipped cross-platform page, adjust the indicator
            return currentPage - 1
        }
        return currentPage
    }
    
    init(onComplete: (() -> Void)? = nil) {
        self.onComplete = onComplete
        // Initialize theme manager - will be updated with modelContext in onAppear
        _themeManager = StateObject(wrappedValue: AppThemeManager())
    }
    
    var body: some View {
        ZStack {
            // Custom background using theme
            AppBackground(themeManager: themeManager)
            
            // Page content
            TabView(selection: $currentPage) {
                WelcomePage(
                    onContinue: nextPage,
                    onSkip: completeOnboarding
                )
                .environmentObject(themeManager)
                .tag(0)
                
                HowItWorksPage(
                    onContinue: nextPage,
                    onSkip: completeOnboarding
                )
                .environmentObject(themeManager)
                .tag(1)
                
                WidgetSetupPage(
                    onContinue: nextPage,
                    onSkip: completeOnboarding
                )
                .environmentObject(themeManager)
                .tag(2)
                
                NotificationPermissionPage(
                    onContinue: nextPage,
                    onSkip: completeOnboarding
                )
                .environmentObject(themeManager)
                .tag(3)
                
                // Cross-platform page (shown only if no existing intentions)
                CrossPlatformPage(
                    onContinue: nextPage,
                    onSkip: completeOnboarding
                )
                .environmentObject(themeManager)
                .tag(4)
                
                FirstIntentionPage(
                    onComplete: completeOnboarding
                )
                .environmentObject(themeManager)
                .tag(5)
            }
            #if os(iOS) || os(watchOS)
            .tabViewStyle(.page(indexDisplayMode: .never))
            #elseif os(macOS)
            .tabViewStyle(.automatic)
            #else
            .tabViewStyle(.page)
            #endif
            .animation(.easeInOut(duration: 0.3), value: currentPage)
            
            // Page indicator overlay - positioned at bottom center
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    OnboardingPageIndicator(
                        currentPage: adjustedCurrentPage,
                        pageCount: shouldShowCrossPlatformPage ? 6 : 5,
                        themeManager: themeManager
                    )
                    Spacer()
                }
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            // Update theme manager with model context
            themeManager.userPreferencesRepository = UserPreferencesRepository(modelContext: modelContext)
            themeManager.loadThemePreference()
            
            // Check if there are existing intentions (indicating data from another device)
            checkForExistingIntentions()
        }
    }
    
    func nextPage() {
        var nextPageIndex = currentPage + 1
        
        // Skip cross-platform page if we don't want to show it
        if nextPageIndex == 4 && !shouldShowCrossPlatformPage {
            nextPageIndex = 5 // Skip to FirstIntentionPage
        }
        
        // Maximum page index is 5 (FirstIntentionPage)
        if nextPageIndex <= 5 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPage = nextPageIndex
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
    
    /// Check if there are existing intentions in the database
    /// If there are no intentions, show the cross-platform page (first device)
    /// If there are intentions, skip it (data has synced from another device)
    private func checkForExistingIntentions() {
        let repository = IntentionRepository(modelContext: modelContext)
        let existingIntentions = repository.getAll()
        
        // If there are no intentions, this is likely the first device
        // Show the cross-platform page to inform user about multi-device sync
        if existingIntentions.isEmpty {
            showCrossPlatformPage = true
        } else {
            // Intentions exist, likely synced from another device
            // Skip the cross-platform page
            showCrossPlatformPage = false
        }
    }
}

#Preview {
    OnboardingContainerView()
}

