//
//  OnboardingPageIndicator.swift
//  Daily Intentions
//
//  Created for onboarding experience
//

import SwiftUI

/// Page indicator showing current page and total pages
struct OnboardingPageIndicator: View {
    @Environment(\.colorScheme) var colorScheme

    let currentPage: Int
    let pageCount: Int

    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<pageCount, id: \.self) { index in
                Capsule()
                    .fill(
                        index == currentPage
                            ? AppThemeManager.shared.accentColor(for: colorScheme)
                            : AppThemeManager.shared.secondaryTextColor(for: colorScheme).opacity(0.25)
                    )
                    .frame(
                        width: index == currentPage ? 28 : 8,
                        height: 8
                    )
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.7),
                        value: currentPage
                    )
                    .overlay {
                        // Subtle glow for active indicator
                        if index == currentPage {
                            Capsule()
                                .fill(
                                    AppThemeManager.shared.accentColor(for: colorScheme).opacity(0.3)
                                )
                                .frame(width: 28, height: 8)
                                .blur(radius: 4)
                        }
                    }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            // Subtle background for better visibility
            Capsule()
                .fill(
                    colorScheme == .dark
                        ? AppThemeManager.shared.primaryTextColor(for: colorScheme).opacity(0.05)
                        : AppThemeManager.shared.primaryTextColor(for: colorScheme).opacity(0.03)
                )
                .background {
                    Capsule()
                        .fill(.ultraThinMaterial)
                }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        OnboardingPageIndicator(currentPage: 0, pageCount: 5)
        OnboardingPageIndicator(currentPage: 2, pageCount: 5)
        OnboardingPageIndicator(currentPage: 4, pageCount: 5)
    }
    .padding()
}

