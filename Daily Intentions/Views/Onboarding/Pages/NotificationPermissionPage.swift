//
//  NotificationPermissionPage.swift
//  Daily Intentions
//
//  Created for onboarding experience
//

import SwiftUI

/// Fourth page of onboarding - Notification permission request
struct NotificationPermissionPage: View {
    @Environment(\.colorScheme) var colorScheme

    let onContinue: () -> Void
    let onSkip: () -> Void

    @State private var permissionGranted = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Custom background
                AppBackground()

                VStack(spacing: 0) {
                    Spacer()

                    // Main content area
                    VStack(spacing: 32) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 80, weight: .ultraLight))
                            .foregroundColor(AppThemeManager.shared.accentColor(for: colorScheme))

                        VStack(spacing: 16) {
                            Text(String(localized: "Stay on track with reminders"))
                                .font(.system(size: 28, weight: .light, design: .default))
                                .foregroundColor(AppThemeManager.shared.primaryTextColor(for: colorScheme))
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)

                            Text(String(localized: "Get gentle reminders to set your daily, weekly, or monthly intentions"))
                                .font(.system(size: 17, weight: .light, design: .default))
                                .foregroundColor(AppThemeManager.shared.secondaryTextColor(for: colorScheme))
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                                .opacity(0.75)
                                .padding(.horizontal, 60)
                                .frame(maxWidth: 700)
                        }
                    }

                    Spacer()

                    // Action buttons
                    VStack(spacing: 20) {
                        PrimaryButton("Enable Notifications") {
                            requestNotificationPermission()
                        }

                        TextButton("Maybe Later", action: onContinue)
                            .padding(.top, 4)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 80)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }

    func requestNotificationPermission() {
        Task {
            // Request notification permission
            let granted = await requestNotificationAuthorization()
            permissionGranted = granted

            if granted {
                // Auto-advance to next page after brief delay
                try? await Task.sleep(nanoseconds: 500_000_000)
                onContinue()
            }
        }
    }

    private func requestNotificationAuthorization() async -> Bool {
        // Simplified notification request for Daily Intentions
        // In a real app, you'd use UNUserNotificationCenter
        return true // Assume granted for demo
    }
}

#Preview {
    NotificationPermissionPage(
        onContinue: { print("Continue") },
        onSkip: { print("Skip") }
    )
}
