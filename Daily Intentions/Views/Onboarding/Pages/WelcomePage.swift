//
//  WelcomePage.swift
//  Daily Intentions
//
//  Created for onboarding experience
//

import SwiftUI

/// First page of onboarding - Welcome screen
struct WelcomePage: View {
    let onContinue: () -> Void
    let onSkip: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // App Icon/Logo
            Image(systemName: "sparkles")
                .font(.system(size: 80))
                .foregroundStyle(.blue)
                .symbolEffect(.pulse, options: .repeating)
            
            VStack(spacing: 12) {
                Text("Daily Intentions")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(spacing: 8) {
                    Text("Set intentions. Stay focused.")
                        .font(.title3)
                        .foregroundStyle(.primary)
                    
                    Text("Build a meaningful life.")
                        .font(.title3)
                        .foregroundStyle(.primary)
                }
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                
                Button(action: onSkip) {
                    Text("Skip")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
        .padding()
    }
}

#Preview {
    WelcomePage(
        onContinue: { print("Continue") },
        onSkip: { print("Skip") }
    )
}

