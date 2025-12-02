//
//  NotificationPermissionPage.swift
//  Daily Intentions
//
//  Created for onboarding experience
//

import SwiftUI

/// Fourth page of onboarding - Notification permission request
struct NotificationPermissionPage: View {
    let onContinue: () -> Void
    let onSkip: () -> Void
    
    @State private var permissionGranted = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "bell.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue)
            
            VStack(spacing: 16) {
                Text("Stay on track with reminders")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Get gentle reminders to set your daily, weekly, or monthly intentions")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                Button {
                    requestNotificationPermission()
                } label: {
                    Text("Enable Notifications")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                
                Button(action: onContinue) {
                    Text("Maybe Later")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
        .padding()
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

