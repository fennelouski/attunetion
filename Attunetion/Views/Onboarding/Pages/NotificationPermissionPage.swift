//
//  NotificationPermissionPage.swift
//  Attunetion
//
//  Created for onboarding experience
//

import SwiftUI

/// Fourth page of onboarding - Notification permission request
struct NotificationPermissionPage: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager: AppThemeManager
    
    let onContinue: () -> Void
    let onSkip: () -> Void
    
    @State private var permissionGranted = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Custom background
                AppBackground(themeManager: themeManager)
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Main content area
                    VStack(spacing: 32) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 80, weight: .ultraLight))
                            .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                        
                        VStack(spacing: 16) {
                            Text("Stay on track with reminders")
                                .font(.system(size: 28, weight: .light, design: .default))
                                .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                            
                            Text("Get gentle reminders to set your daily, weekly, or monthly intentions")
                                .font(.system(size: 17, weight: .light, design: .default))
                                .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                                .opacity(0.75)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 60)
                                .frame(maxWidth: 700)
                        }
                    }
                    
                    Spacer()
                    
                    // Action buttons
                    VStack(spacing: 20) {
                        PrimaryButton("Enable Notifications", themeManager: themeManager) {
                            requestNotificationPermission()
                        }
                        .frame(maxWidth: 400)
                        
                        TextButton("Maybe Later", themeManager: themeManager, action: onContinue)
                            .padding(.top, 4)
                    }
                    .padding(.bottom, 80)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
    
    func requestNotificationPermission() {
        Task {
            let granted = await NotificationManager.shared.requestAuthorization()
            permissionGranted = granted
            
            if granted {
                // Auto-advance to next page after brief delay
                try? await Task.sleep(nanoseconds: 500_000_000)
                onContinue()
            }
        }
    }
}

#Preview {
    NotificationPermissionPage(
        onContinue: { print("Continue") },
        onSkip: { print("Skip") }
    )
}

