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
    @State private var contentAppeared = false
    @State private var buttonPressed = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Custom background
                AppBackground(themeManager: themeManager)
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Main content area - macOS optimized layout
                    VStack(spacing: macOSSpacing) {
                        // Icon with subtle animation
                        ZStack {
                            // Enhanced glow effect with multiple layers
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            themeManager.accentColor(for: colorScheme).toSwiftUIColor().opacity(0.25),
                                            themeManager.accentColor(for: colorScheme).toSwiftUIColor().opacity(0.1),
                                            themeManager.accentColor(for: colorScheme).toSwiftUIColor().opacity(0.0)
                                        ],
                                        center: .center,
                                        startRadius: 15,
                                        endRadius: 100
                                    )
                                )
                                .frame(width: iconSize, height: iconSize)
                                .blur(radius: 40)
                                .opacity(sparkleAnimation ? 0.7 : 0.5)
                                .animation(
                                    Animation.easeInOut(duration: 2.5)
                                        .repeatForever(autoreverses: true),
                                    value: sparkleAnimation
                                )
                            
                            // Icon with enhanced styling
                            Image(systemName: "sparkles")
                                .font(.system(size: iconFontSize, weight: .ultraLight))
                                .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                                .symbolEffect(.pulse, options: .repeating.speed(0.4))
                                .opacity(contentAppeared ? 1.0 : 0.0)
                                .scaleEffect(contentAppeared ? 1.0 : 0.8)
                                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: contentAppeared)
                        }
                        .padding(.bottom, 8)
                        
                        // Welcome card with enhanced glass morphism
                        VStack(spacing: 24) {
                            Text("Welcome to Attunetion")
                                .font(.system(size: titleFontSize, weight: .thin, design: .default))
                                .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                                .tracking(-0.8)
                                .opacity(contentAppeared ? 1.0 : 0.0)
                                .offset(y: contentAppeared ? 0 : 10)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: contentAppeared)
                            
                            VStack(spacing: 16) {
                                Text("Set intentions for your day, week, or month.")
                                    .font(.system(size: bodyFontSize, weight: .light, design: .default))
                                    .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                                    .opacity(0.85)
                                    .lineSpacing(4)
                                
                                Text("Stay focused on what matters most.")
                                    .font(.system(size: secondaryFontSize, weight: .light, design: .default))
                                    .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                                    .opacity(0.75)
                                    .lineSpacing(2)
                            }
                            .opacity(contentAppeared ? 1.0 : 0.0)
                            .offset(y: contentAppeared ? 0 : 10)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: contentAppeared)
                        }
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, cardHorizontalPadding)
                        .padding(.vertical, cardVerticalPadding)
                        .frame(maxWidth: cardMaxWidth)
                        .background {
                            // Enhanced glass morphism effect
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(
                                    colorScheme == .dark
                                        ? Color.white.opacity(0.08)
                                        : Color.black.opacity(0.04)
                                )
                                .background {
                                    // Blur effect
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .fill(
                                            .ultraThinMaterial
                                        )
                                }
                                .overlay {
                                    // Subtle border
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .stroke(
                                            themeManager.accentColor(for: colorScheme).toSwiftUIColor().opacity(0.15),
                                            lineWidth: 1
                                        )
                                }
                                .shadow(
                                    color: colorScheme == .dark
                                        ? Color.black.opacity(0.3)
                                        : Color.black.opacity(0.08),
                                    radius: 20,
                                    x: 0,
                                    y: 8
                                )
                        }
                        .opacity(contentAppeared ? 1.0 : 0.0)
                        .scaleEffect(contentAppeared ? 1.0 : 0.95)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.35), value: contentAppeared)
                    }
                    .padding(.horizontal, contentHorizontalPadding)
                    
                    Spacer()
                    
                    // Action buttons - macOS optimized
                    VStack(spacing: 20) {
                        Button(action: {
                            #if os(iOS)
                            HapticFeedback.medium()
                            #endif
                            buttonPressed = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                buttonPressed = false
                                onContinue()
                            }
                        }) {
                            Text("Get Started")
                                .font(.system(size: buttonFontSize, weight: .semibold, design: .default))
                                .foregroundColor(themeManager.buttonTextColor(for: colorScheme).toSwiftUIColor())
                                .frame(maxWidth: buttonMaxWidth)
                                .frame(height: buttonHeight)
                                .background {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(themeManager.buttonBackgroundColor(for: colorScheme).toSwiftUIColor())
                                        .shadow(
                                            color: themeManager.buttonBackgroundColor(for: colorScheme).toSwiftUIColor().opacity(0.4),
                                            radius: buttonPressed ? 8 : 12,
                                            x: 0,
                                            y: buttonPressed ? 2 : 4
                                        )
                                }
                                .scaleEffect(buttonPressed ? 0.97 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: buttonPressed)
                        }
                        .buttonStyle(.plain)
                        .opacity(contentAppeared ? 1.0 : 0.0)
                        .offset(y: contentAppeared ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5), value: contentAppeared)
                        
                        #if os(macOS)
                        // On macOS, make skip button less prominent
                        Button(action: onSkip) {
                            Text("Skip for now")
                                .font(.system(size: 15, weight: .regular, design: .default))
                                .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 4)
                        .opacity(contentAppeared ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.4).delay(0.6), value: contentAppeared)
                        #else
                        TextButton("Skip", themeManager: themeManager, action: onSkip)
                            .padding(.top, 4)
                            .opacity(contentAppeared ? 1.0 : 0.0)
                            .animation(.easeOut(duration: 0.4).delay(0.6), value: contentAppeared)
                        #endif
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, bottomPadding)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .onAppear {
            sparkleAnimation = true
            withAnimation {
                contentAppeared = true
            }
        }
    }
    
    // MARK: - Platform-specific sizing
    
    #if os(macOS)
    private var macOSSpacing: CGFloat { 64 }
    private var iconSize: CGFloat { 220 }
    private var iconFontSize: CGFloat { 90 }
    private var titleFontSize: CGFloat { 44 }
    private var bodyFontSize: CGFloat { 21 }
    private var secondaryFontSize: CGFloat { 19 }
    private var cardHorizontalPadding: CGFloat { 64 }
    private var cardVerticalPadding: CGFloat { 48 }
    private var cardMaxWidth: CGFloat { 800 }
    private var contentHorizontalPadding: CGFloat { 60 }
    private var buttonFontSize: CGFloat { 19 }
    private var buttonMaxWidth: CGFloat { 450 }
    private var buttonHeight: CGFloat { 60 }
    private var bottomPadding: CGFloat { 100 }
    #else
    private var macOSSpacing: CGFloat { 56 }
    private var iconSize: CGFloat { 200 }
    private var iconFontSize: CGFloat { 80 }
    private var titleFontSize: CGFloat { 38 }
    private var bodyFontSize: CGFloat { 19 }
    private var secondaryFontSize: CGFloat { 17 }
    private var cardHorizontalPadding: CGFloat { 48 }
    private var cardVerticalPadding: CGFloat { 40 }
    private var cardMaxWidth: CGFloat { 680 }
    private var contentHorizontalPadding: CGFloat { 32 }
    private var buttonFontSize: CGFloat { 18 }
    private var buttonMaxWidth: CGFloat { 400 }
    private var buttonHeight: CGFloat { 56 }
    private var bottomPadding: CGFloat { 80 }
    #endif
}

#Preview {
    WelcomePage(
        onContinue: { print("Continue") },
        onSkip: { print("Skip") }
    )
    .environmentObject(AppThemeManager())
    .frame(width: 800, height: 600)
}
