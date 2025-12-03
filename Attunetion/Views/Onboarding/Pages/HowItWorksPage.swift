//
//  HowItWorksPage.swift
//  Attunetion
//
//  Created for onboarding experience
//

import SwiftUI

/// Second page of onboarding - Explains how the app works
struct HowItWorksPage: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager: AppThemeManager
    
    let onContinue: () -> Void
    let onSkip: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Custom background
                AppBackground(themeManager: themeManager)
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Main content area
                    VStack(spacing: 32) {
                        // Calendar illustration
                        Image(systemName: "calendar")
                            .font(.system(size: 60, weight: .ultraLight))
                            .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                        
                        VStack(spacing: 16) {
                            Text("Set intentions for your")
                                .font(.system(size: 28, weight: .light, design: .default))
                                .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                            
                            Text("day, week, or month")
                                .font(.system(size: 28, weight: .light, design: .default))
                                .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                        }
                        
                        // Example intentions
                        VStack(spacing: 12) {
                            ExampleIntentionCard(
                                intention: ExampleIntention(
                                    text: "Be present",
                                    scope: .day,
                                    category: "Mindfulness"
                                ),
                                themeManager: themeManager
                            ) {}
                            
                            ExampleIntentionCard(
                                intention: ExampleIntention(
                                    text: "Focus on health",
                                    scope: .week,
                                    category: "Wellness"
                                ),
                                themeManager: themeManager
                            ) {}
                            
                            ExampleIntentionCard(
                                intention: ExampleIntention(
                                    text: "Practice growth",
                                    scope: .month,
                                    category: "Growth"
                                ),
                                themeManager: themeManager
                            ) {}
                        }
                        .padding(.horizontal, 32)
                    }
                    
                    Spacer()
                    
                    // Action buttons
                    VStack(spacing: 20) {
                        PrimaryButton("Continue", themeManager: themeManager, action: onContinue)
                            .frame(maxWidth: 400)
                        
                        TextButton("Skip", themeManager: themeManager, action: onSkip)
                            .padding(.top, 4)
                    }
                    .padding(.bottom, 80)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}

#Preview {
    HowItWorksPage(
        onContinue: { print("Continue") },
        onSkip: { print("Skip") }
    )
}


