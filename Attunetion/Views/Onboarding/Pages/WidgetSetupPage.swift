//
//  WidgetSetupPage.swift
//  Attunetion
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
                        // Widget illustration
                        Image(systemName: "square.on.square")
                            .font(.system(size: 60, weight: .ultraLight))
                            .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                        
                        VStack(spacing: 16) {
                            Text("Your intention,")
                                .font(.system(size: 28, weight: .light, design: .default))
                                .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                            
                            Text("always visible")
                                .font(.system(size: 28, weight: .light, design: .default))
                                .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                        }
                        
                        Text("Add a widget to your home screen or lock screen to keep your intention in sight")
                            .font(.system(size: 17, weight: .light, design: .default))
                            .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                            .opacity(0.75)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 60)
                            .frame(maxWidth: 700)
                        
                        // Widget preview mockup
                        VStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(
                                    colorScheme == .dark
                                        ? themeManager.currentTheme.darkSecondaryButtonBackground.toSwiftUIColor().opacity(0.4)
                                        : Color.white.opacity(0.6)
                                )
                                .frame(height: 120)
                                .overlay(
                                    VStack(spacing: 8) {
                                        Text("TODAY")
                                            .font(.system(size: 12, weight: .medium, design: .default))
                                            .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                                        Text("Be present")
                                            .font(.system(size: 20, weight: .light, design: .default))
                                            .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                                    }
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(
                                            themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.1),
                                            lineWidth: 1
                                        )
                                )
                                .shadow(
                                    color: themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.05),
                                    radius: 8,
                                    x: 0,
                                    y: 2
                                )
                                .padding(.horizontal, 32)
                            
                            Text("Customize with themes and fonts")
                                .font(.caption)
                                .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                                .opacity(0.75)
                        }
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
    WidgetSetupPage(
        onContinue: { print("Continue") },
        onSkip: { print("Skip") }
    )
}

