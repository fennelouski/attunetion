//
//  HowItWorksPage.swift
//  Daily Intentions
//
//  Created for onboarding experience
//

import SwiftUI

/// Second page of onboarding - Explains how the app works
struct HowItWorksPage: View {
    let onContinue: () -> Void
    let onSkip: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Calendar illustration
            Image(systemName: "calendar")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
            
            VStack(spacing: 16) {
                Text("Set intentions for your")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("day, week, or month")
                    .font(.title2)
                    .fontWeight(.bold)
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
            
            Text("Day intentions override week, week overrides month")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
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
    HowItWorksPage(
        onContinue: { print("Continue") },
        onSkip: { print("Skip") }
    )
}

