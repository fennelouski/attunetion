//
//  OnboardingPageIndicator.swift
//  Attunetion
//
//  Created for onboarding experience
//

import SwiftUI

/// Page indicator showing current page and total pages
struct OnboardingPageIndicator: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var themeManager: AppThemeManager
    
    let currentPage: Int
    let pageCount: Int
    
    init(currentPage: Int, pageCount: Int, themeManager: AppThemeManager) {
        self.currentPage = currentPage
        self.pageCount = pageCount
        self.themeManager = themeManager
    }
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<pageCount, id: \.self) { index in
                Capsule()
                    .fill(
                        index == currentPage
                            ? themeManager.accentColor(for: colorScheme).toSwiftUIColor()
                            : themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.25)
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
                                    themeManager.accentColor(for: colorScheme).toSwiftUIColor().opacity(0.3)
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
                        ? Color.white.opacity(0.05)
                        : Color.black.opacity(0.03)
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
        OnboardingPageIndicator(currentPage: 0, pageCount: 5, themeManager: AppThemeManager())
        OnboardingPageIndicator(currentPage: 2, pageCount: 5, themeManager: AppThemeManager())
        OnboardingPageIndicator(currentPage: 4, pageCount: 5, themeManager: AppThemeManager())
    }
    .padding()
}

