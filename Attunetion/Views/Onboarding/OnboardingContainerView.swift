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
    @StateObject private var animationSpeedManager = AnimationSpeedManager.shared
    
    var onComplete: (() -> Void)?
    
    // Computed property to determine the last page index
    private var lastPageIndex: Int {
        return 4 // FirstIntentionPage is always the last page
    }
    
    // Computed property to determine if we're on the first page
    private var isFirstPage: Bool {
        return currentPage == 0
    }
    
    // Computed property to determine if we're on the last page
    private var isLastPage: Bool {
        return currentPage == lastPageIndex
    }
    
    // MARK: - Platform-specific sizing
    private var pageIndicatorBottomPadding: CGFloat {
        #if os(macOS)
        return 24
        #else
        return 24
        #endif
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
                
                FirstIntentionPage(
                    onComplete: completeOnboarding
                )
                .environmentObject(themeManager)
                .tag(4)
            }
            #if os(iOS) || os(watchOS)
            .tabViewStyle(.page(indexDisplayMode: .never))
            #elseif os(macOS)
            // macOS: Use automatic style but disable swipe gestures
            // Navigation is handled via the page indicator clicks
            .tabViewStyle(.automatic)
            #else
            .tabViewStyle(.page)
            #endif
            .animation(animationSpeedManager.easeInOut(duration: 0.3), value: currentPage)
            #if os(iOS) || os(watchOS)
            .highPriorityGesture(
                DragGesture(minimumDistance: 30)
                    .onEnded { value in
                        let horizontalTranslation = value.translation.width
                        let swipeThreshold: CGFloat = 50
                        
                        // Swipe right (positive translation) = go backward
                        if horizontalTranslation > swipeThreshold {
                            // Only allow backward swipe if not on first page
                            if !isFirstPage {
                                previousPage()
                            }
                        }
                        // Swipe left (negative translation) = go forward
                        else if horizontalTranslation < -swipeThreshold {
                            // Only allow forward swipe if not on last page
                            if !isLastPage {
                                nextPage()
                            }
                        }
                    }
            )
            #endif
            
            // Page indicator overlay - positioned at bottom center
            // macOS uses a different, more desktop-appropriate indicator
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    #if os(macOS)
                    MacOSPageIndicator(
                        currentPage: currentPage,
                        pageCount: 5,
                        themeManager: themeManager
                    )
                    #else
                    OnboardingPageIndicator(
                        currentPage: currentPage,
                        pageCount: 5,
                        themeManager: themeManager
                    )
                    #endif
                    Spacer()
                }
                .padding(.bottom, pageIndicatorBottomPadding)
            }
        }
        .onAppear {
            // Update theme manager with model context
            themeManager.userPreferencesRepository = UserPreferencesRepository(modelContext: modelContext)
            themeManager.loadThemePreference()
            
        }
    }
    
    func nextPage() {
        let nextPageIndex = currentPage + 1
        
        if nextPageIndex <= lastPageIndex {
            animationSpeedManager.withAnimation(0.3) {
                currentPage = nextPageIndex
            }
        } else {
            completeOnboarding()
        }
    }
    
    func previousPage() {
        let previousPageIndex = currentPage - 1
        
        // Minimum page index is 0 (WelcomePage)
        if previousPageIndex >= 0 {
            animationSpeedManager.withAnimation(0.3) {
                currentPage = previousPageIndex
            }
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
