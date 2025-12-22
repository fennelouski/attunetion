//
//  WidgetSetupPage.swift
//  Daily Intentions
//
//  Created for onboarding experience
//

import SwiftUI
#if os(macOS)
import AppKit
#endif
#if canImport(WidgetKit)
import WidgetKit
#endif

/// Third page of onboarding - Widget setup information
struct WidgetSetupPage: View {
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
                        // Widget illustration
                        Image(systemName: "square.on.square")
                            .font(.system(size: 60, weight: .ultraLight))
                            .foregroundColor(AppThemeManager.shared.accentColor(for: colorScheme))

                        VStack(spacing: 16) {
                            Text(String(localized: "Your intention,"))
                                .font(.system(size: 28, weight: .light, design: .default))
                                .foregroundColor(AppThemeManager.shared.primaryTextColor(for: colorScheme))
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)

                            Text(String(localized: "always visible"))
                                .font(.system(size: 28, weight: .light, design: .default))
                                .foregroundColor(AppThemeManager.shared.primaryTextColor(for: colorScheme))
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                        }

                        Text(String(localized: "Add a widget to your home screen or lock screen to keep your intention in sight"))
                            .font(.system(size: 17, weight: .light, design: .default))
                            .foregroundColor(AppThemeManager.shared.secondaryTextColor(for: colorScheme))
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .opacity(0.75)
                            .padding(.horizontal, 60)
                            .frame(maxWidth: 700)

                        // Widget preview mockup
                        VStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(
                                    colorScheme == .dark
                                        ? AppThemeManager.shared.secondaryButtonBackground(for: colorScheme).opacity(0.4)
                                        : Color.white.opacity(0.6)
                                )
                                .frame(height: 120)
                                .overlay(
                                    VStack(spacing: 8) {
                                        Text(String(localized: "TODAY"))
                                            .font(.system(size: 12, weight: .medium, design: .default))
                                            .foregroundColor(AppThemeManager.shared.secondaryTextColor(for: colorScheme))
                                            .fixedSize(horizontal: false, vertical: true)
                                            .lineLimit(nil)
                                        Text(String(localized: "Be present"))
                                            .font(.system(size: 20, weight: .light, design: .default))
                                            .foregroundColor(AppThemeManager.shared.primaryTextColor(for: colorScheme))
                                            .fixedSize(horizontal: false, vertical: true)
                                            .multilineTextAlignment(.center)
                                            .lineLimit(nil)
                                    }
                                    .padding(.horizontal, 8)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(
                                            AppThemeManager.shared.secondaryTextColor(for: colorScheme).opacity(0.1),
                                            lineWidth: 1
                                        )
                                )
                                .shadow(
                                    color: AppThemeManager.shared.primaryTextColor(for: colorScheme).opacity(0.05),
                                    radius: 8,
                                    x: 0,
                                    y: 2
                                )
                                .padding(.horizontal, 32)

                            Text(String(localized: "Customize with themes and fonts"))
                                .font(.caption)
                                .foregroundColor(AppThemeManager.shared.secondaryTextColor(for: colorScheme))
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                                .opacity(0.75)
                        }
                    }

                    Spacer()

                    // Action buttons
                    VStack(spacing: 20) {
                        PrimaryButton("Continue", action: onContinue)

                        TextButton("Skip", action: onSkip)
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

#Preview {
    WidgetSetupPage(
        onContinue: { print("Continue") },
        onSkip: { print("Skip") }
    )
}
