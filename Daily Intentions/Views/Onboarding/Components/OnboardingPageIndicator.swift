//
//  OnboardingPageIndicator.swift
//  Daily Intentions
//
//  Created for onboarding experience
//

import SwiftUI

/// Page indicator showing current page and total pages
struct OnboardingPageIndicator: View {
    let currentPage: Int
    let pageCount: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<pageCount, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.primary : Color.secondary.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .animation(.easeInOut(duration: 0.2), value: currentPage)
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

