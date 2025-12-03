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
        HStack(spacing: 10) {
            ForEach(0..<pageCount, id: \.self) { index in
                Circle()
                    .fill(
                        index == currentPage
                            ? themeManager.accentColor(for: colorScheme).toSwiftUIColor()
                            : themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.3)
                    )
                    .frame(width: index == currentPage ? 10 : 8, height: index == currentPage ? 10 : 8)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
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

