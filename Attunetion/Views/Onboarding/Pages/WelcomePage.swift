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
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Custom background
                AppBackground(themeManager: themeManager)
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Main content area - centered vertically
                    VStack(spacing: contentSpacing) {
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
                            Image(systemName: "target")
                                .font(.system(size: iconFontSize, weight: .ultraLight))
                                .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                                .symbolEffect(.pulse, options: .repeating.speed(0.4))
                                .opacity(contentAppeared ? 1.0 : 0.0)
                                .scaleEffect(contentAppeared ? 1.0 : 0.8)
                                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: contentAppeared)
                        }
                        .frame(height: iconSize)
                        
                        // Welcome card with enhanced glass morphism
                        VStack(spacing: 24) {
                            Text(String(localized: "Welcome to Attunetion"))
                                .font(.system(size: titleFontSize, weight: .thin, design: .default))
                                .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                                .tracking(-0.8)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                                .opacity(contentAppeared ? 1.0 : 0.0)
                                .offset(y: contentAppeared ? 0 : 10)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: contentAppeared)
                            
                            VStack(spacing: 16) {
                                Text(String(localized: "Set intentions for your day, week, or month."))
                                    .font(.system(size: bodyFontSize, weight: .light, design: .default))
                                    .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                                    .fixedSize(horizontal: false, vertical: true)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(nil)
                                    .opacity(0.85)
                                    .lineSpacing(4)
                                
                                Text(String(localized: "Stay focused on what matters most."))
                                    .font(.system(size: secondaryFontSize, weight: .light, design: .default))
                                    .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                                    .fixedSize(horizontal: false, vertical: true)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(nil)
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
                            ZStack {
                                // Blur effect (glass morphism)
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .fill(.ultraThinMaterial)
                                
                                // Tint overlay using themed colors
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .fill(
                                        colorScheme == .dark
                                            ? themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.08)
                                            : themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.04)
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
                                color: themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor().opacity(colorScheme == .dark ? 0.3 : 0.08),
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
                    
                    Spacer()
                    
                    // Action buttons - TESTING 5 DIFFERENT APPROACHES
                    VStack(spacing: 12) {
                        // Button 1: Explicit frame width constraint
                        Button(action: {}) {
                            Text("1: Frame Width")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .frame(height: 44)
                                .frame(width: 200)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.red)
                                )
                        }
                        .buttonStyle(.plain)
                        
                        // Button 2: HStack with Spacers
                        HStack {
                            Spacer()
                            Button(action: {}) {
                                Text("2: HStack Spacers")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .frame(height: 44)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.blue)
                                    )
                            }
                            .buttonStyle(.plain)
                            Spacer()
                        }
                        
                        // Button 3: LayoutPriority approach
                        Button(action: {}) {
                            Text("3: LayoutPriority")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .frame(height: 44)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.green)
                                )
                        }
                        .buttonStyle(.plain)
                        .layoutPriority(1)
                        
                        // Button 4: FixedSize on Text before padding
                        Button(action: {}) {
                            Text("4: FixedSize Text")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .fixedSize(horizontal: true, vertical: false)
                                .padding(.horizontal, 24)
                                .frame(height: 44)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.orange)
                                )
                        }
                        .buttonStyle(.plain)
                        
                        // Button 5: Background applied differently
                        Button(action: {}) {
                            Text("5: Background Order")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .frame(height: 44)
                        }
                        .buttonStyle(.plain)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.purple)
                        )
                        
                        // Original button for comparison
                        PrimaryButton("Get Started", themeManager: themeManager) {
                            #if os(iOS)
                            HapticFeedback.medium()
                            #endif
                            onContinue()
                        }
                        .opacity(contentAppeared ? 1.0 : 0.0)
                        .offset(y: contentAppeared ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5), value: contentAppeared)
                        
                        #if os(macOS)
                        // On macOS, make skip button less prominent
                        Button(action: onSkip) {
                            Text(String(localized: "Skip for now"))
                                .font(.system(size: 15, weight: .regular, design: .default))
                                .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(nil)
                        }
                        .buttonStyle(.plain)
                        .opacity(contentAppeared ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.4).delay(0.6), value: contentAppeared)
                        #else
                        TextButton("Skip", themeManager: themeManager, action: onSkip)
                            .opacity(contentAppeared ? 1.0 : 0.0)
                            .animation(.easeOut(duration: 0.4).delay(0.6), value: contentAppeared)
                        #endif
                    }
                    .padding(.horizontal, buttonHorizontalPadding)
                    .padding(.bottom, skipButtonBottomPadding)
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
    private var contentSpacing: CGFloat { 40 }
    private var buttonSpacing: CGFloat { 16 }
    private var skipButtonBottomPadding: CGFloat { 100 }
    private var iconSize: CGFloat { 180 }
    private var iconFontSize: CGFloat { 72 }
    private var titleFontSize: CGFloat { 44 }
    private var bodyFontSize: CGFloat { 21 }
    private var secondaryFontSize: CGFloat { 19 }
    private var cardHorizontalPadding: CGFloat { 64 }
    private var cardVerticalPadding: CGFloat { 48 }
    private var cardMaxWidth: CGFloat { 800 }
    private var contentHorizontalPadding: CGFloat { 60 }
    private var buttonFontSize: CGFloat { 19 }
    private var buttonMaxWidth: CGFloat { 380 }
    private var buttonHeight: CGFloat { 60 }
    private var buttonHorizontalPadding: CGFloat { 60 }
    #else
    private var contentSpacing: CGFloat { 32 }
    private var buttonSpacing: CGFloat { 16 }
    private var skipButtonBottomPadding: CGFloat { 80 }
    private var iconSize: CGFloat { 140 }
    private var iconFontSize: CGFloat { 56 }
    private var titleFontSize: CGFloat { 36 }
    private var bodyFontSize: CGFloat { 18 }
    private var secondaryFontSize: CGFloat { 16 }
    private var cardHorizontalPadding: CGFloat { 32 }
    private var cardVerticalPadding: CGFloat { 36 }
    private var cardMaxWidth: CGFloat { .infinity }
    private var contentHorizontalPadding: CGFloat { 24 }
    private var buttonFontSize: CGFloat { 17 }
    private var buttonMaxWidth: CGFloat { 360 }
    private var buttonHeight: CGFloat { 54 }
    private var buttonHorizontalPadding: CGFloat { 40 }
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
