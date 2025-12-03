//
//  WelcomePage.swift
//  Attunetion
//
//  Created for onboarding experience
//

import SwiftUI

/// First page of onboarding - Welcome screen with spa-like, Apple-inspired design
struct WelcomePage: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager: AppThemeManager
    
    let onContinue: () -> Void
    let onSkip: () -> Void
    
    @State private var sparkleAnimation = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Custom background
                AppBackground(themeManager: themeManager)
                
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
                                            themeManager.accentColor(for: colorScheme).toSwiftUIColor().opacity(0.2),
                                            themeManager.accentColor(for: colorScheme).toSwiftUIColor().opacity(0.0)
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
                                .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                                .symbolEffect(.pulse, options: .repeating.speed(0.5))
                        }
                        
                        // Title and description
                        VStack(spacing: 20) {
                            Text("Welcome to Attunetion")
                                .font(.system(size: 42, weight: .ultraLight, design: .default))
                                .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                                .tracking(-0.5)
                            
                            VStack(spacing: 12) {
                                Text("Set intentions for your day, week, or month.")
                                    .font(.system(size: 20, weight: .light, design: .default))
                                    .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                                    .opacity(0.9)
                                
                                Text("Stay focused on what matters most.")
                                    .font(.system(size: 18, weight: .light, design: .default))
                                    .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
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
                        PrimaryButton("Get Started", themeManager: themeManager, action: onContinue)
                            .frame(maxWidth: 400)
                            .padding(.horizontal, 40)
                        
                        #if os(macOS)
                        // On macOS, make skip button less prominent
                        Button(action: onSkip) {
                            Text("Skip for now")
                                .font(.system(size: 15, weight: .regular, design: .default))
                                .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 8)
                        #else
                        TextButton("Skip", themeManager: themeManager, action: onSkip)
                            .padding(.top, 4)
                        #endif
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
    .environmentObject(AppThemeManager())
    .frame(width: 800, height: 600)
}
