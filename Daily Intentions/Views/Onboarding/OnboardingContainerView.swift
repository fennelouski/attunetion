//
//  OnboardingContainerView.swift
//  Daily Intentions
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

    // Computed property to determine the last page index
    private var lastPageIndex: Int {
        return 5 // FirstIntentionPage is always the last page
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
    }

    var body: some View {
        ZStack {
            // Custom background using theme
            AppBackground()

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

                // Cross-platform page (shown only if no existing intentions)
                CrossPlatformPage(
                    onContinue: nextPage,
                    onSkip: completeOnboarding
                )
                .tag(4)

                FirstIntentionPage(
                    onComplete: completeOnboarding
                )
                .tag(5)
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
            .animation(.easeInOut(duration: 0.3), value: currentPage)
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
                        currentPage: adjustedCurrentPage,
                        pageCount: shouldShowCrossPlatformPage ? 6 : 5
                    )
                    #else
                    OnboardingPageIndicator(
                        currentPage: adjustedCurrentPage,
                        pageCount: shouldShowCrossPlatformPage ? 6 : 5
                    )
                    #endif
                    Spacer()
                }
                .padding(.bottom, pageIndicatorBottomPadding)
            }
        }
        .onAppear {
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

    func previousPage() {
        var previousPageIndex = currentPage - 1

        // Skip cross-platform page if we don't want to show it
        if previousPageIndex == 4 && !shouldShowCrossPlatformPage {
            previousPageIndex = 3 // Skip back to NotificationPermissionPage
        }

        // Minimum page index is 0 (WelcomePage)
        if previousPageIndex >= 0 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPage = previousPageIndex
            }
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
        do {
            let descriptor = FetchDescriptor<Intention>()
            let existingIntentions = try modelContext.fetch(descriptor)

            // If there are no intentions, this is likely the first device
            // Show the cross-platform page to inform user about multi-device sync
            if existingIntentions.isEmpty {
                showCrossPlatformPage = true
            } else {
                // Intentions exist, likely synced from another device
                // Skip the cross-platform page
                showCrossPlatformPage = false
            }
        } catch {
            // If there's an error, default to showing the cross-platform page
            showCrossPlatformPage = true
        }
    }
}

#Preview {
    OnboardingContainerView()
}
