//
//  HowItWorksPage.swift
//  Daily Intentions
//
//  Created for onboarding experience
//

import SwiftUI

/// Second page of onboarding - Explains how the app works
struct HowItWorksPage: View {
    @Environment(\.colorScheme) var colorScheme

    let onContinue: () -> Void
    let onSkip: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Custom background
                AppBackground()

                VStack(spacing: 0) {
                    Spacer()

                    // Main content area
                    VStack(spacing: 32) {
                        // Calendar illustration
                        Image(systemName: "calendar")
                            .font(.system(size: 60, weight: .ultraLight))
                            .foregroundColor(AppThemeManager.shared.accentColor(for: colorScheme))

                        VStack(spacing: 16) {
                            Text(String(localized: "Set intentions for your"))
                                .font(.system(size: 28, weight: .light, design: .default))
                                .foregroundColor(AppThemeManager.shared.primaryTextColor(for: colorScheme))
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)

                            Text(String(localized: "day, week, or month"))
                                .font(.system(size: 28, weight: .light, design: .default))
                                .foregroundColor(AppThemeManager.shared.primaryTextColor(for: colorScheme))
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                        }

                        // Example intentions
                        VStack(spacing: 12) {
                            ExampleIntentionCard(
                                intention: ExampleIntention(
                                    text: "Be present",
                                    scope: .day,
                                    category: "Mindfulness"
                                )
                            ) {}

                            ExampleIntentionCard(
                                intention: ExampleIntention(
                                    text: "Focus on health",
                                    scope: .week,
                                    category: "Wellness"
                                )
                            ) {}

                            ExampleIntentionCard(
                                intention: ExampleIntention(
                                    text: "Practice growth",
                                    scope: .month,
                                    category: "Growth"
                                )
                            ) {}
                        }
                        .padding(.horizontal, 32)
                    }

                    Spacer()

                    // Action buttons
                    VStack(spacing: 20) {
                        PrimaryButton("Continue", action: onContinue)

                        TextButton(title: "Skip", action: onSkip)
                            .padding(.top, 4)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 80)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}

struct TextButton: View {
    let title: String
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .regular, design: .default))
                .foregroundColor(AppThemeManager.shared.secondaryTextColor(for: colorScheme))
        }
    }
}

#Preview {
    HowItWorksPage(
        onContinue: { print("Continue") },
        onSkip: { print("Skip") }
    )
}

