//
//  WelcomePage.swift
//  Daily Intentions
//
//  Created for onboarding experience
//

import SwiftUI

/// First page of onboarding - Welcome screen with spa-like, Apple-inspired design
struct WelcomePage: View {
    let onContinue: () -> Void
    let onSkip: () -> Void
    @Environment(\.colorScheme) var colorScheme

    @State private var sparkleAnimation = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Sage-themed gradient background
                AppThemeManager.shared.backgroundColor(for: colorScheme)
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    // Main content area - centered and properly sized
                    VStack(spacing: 48) {
                        // Icon with subtle animation
                        ZStack {
                            // Glow effect
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            AppThemeManager.shared.accentColor(for: colorScheme).opacity(0.3),
                                            AppThemeManager.shared.accentColor(for: colorScheme).opacity(0.0)
                                        ],
                                        center: .center,
                                        startRadius: 20,
                                        endRadius: 80
                                    )
                                )
                                .frame(width: 160, height: 160)
                                .blur(radius: 30)
                                .opacity(sparkleAnimation ? 0.6 : 0.4)
                                .animation(
                                    Animation.easeInOut(duration: 2.0)
                                        .repeatForever(autoreverses: true),
                                    value: sparkleAnimation
                                )

                            // Icon
                            Image(systemName: "sparkles")
                                .font(.system(size: 72, weight: .ultraLight))
                                .foregroundColor(AppThemeManager.shared.accentColor(for: colorScheme))
                                .symbolEffect(.pulse, options: .repeating.speed(0.5))
                        }

                        // Title and description
                        VStack(spacing: 20) {
                            Text("Welcome to Daily Intentions")
                                .font(.system(size: 42, weight: .ultraLight, design: .default))
                                .foregroundColor(AppThemeManager.shared.primaryTextColor(for: colorScheme))
                                .tracking(-0.5)

                            VStack(spacing: 12) {
                                Text("Set intentions for your day, week, or month.")
                                    .font(.system(size: 20, weight: .light, design: .default))
                                    .foregroundColor(AppThemeManager.shared.primaryTextColor(for: colorScheme))
                                    .opacity(0.9)

                                Text("Stay focused on what matters most.")
                                    .font(.system(size: 18, weight: .light, design: .default))
                                    .foregroundColor(AppThemeManager.shared.secondaryTextColor(for: colorScheme))
                                    .opacity(0.8)
                            }
                        }
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 60)
                        .frame(maxWidth: 700)
                    }

                    Spacer()

                    // Action buttons - clear call to action
                    VStack(spacing: 16) {
                        HStack {
                            Spacer(minLength: 32)
                            PrimaryButton("Get Started", action: onContinue)
                                .frame(maxWidth: 400)
                            Spacer(minLength: 32)
                        }

                        TextButton(title: "Skip for now", action: onSkip)
                            .padding(.top, 8)
                    }
                    .padding(.bottom, 60)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .onAppear {
            sparkleAnimation = true
        }
    }
}

#Preview {
    WelcomePage(
        onContinue: { print("Continue") },
        onSkip: { print("Skip") }
    )
    .frame(width: 800, height: 600)
}
