//
//  AnimatedLightbulbIcon.swift
//  Daily Intentions
//
//  Created by Nathan Fennel on 12/21/25.
//

import SwiftUI

struct AnimatedLightbulbIcon: View {
    let iconIndex: Int
    let icon: String
    let colorScheme: ColorScheme
    @State private var isPulsing = false

    private var primaryColor: Color {
        AppThemeManager.shared.accentColor(for: colorScheme)
    }

    private var secondaryColor: Color {
        // Use a complementary color from the theme
        let accent = AppThemeManager.shared.accentColor(for: colorScheme)
        // Create a slightly lighter/different shade for variety
        return accent.opacity(0.7)
    }

    private var tertiaryColor: Color {
        // Use another complementary color
        let accent = AppThemeManager.shared.accentColor(for: colorScheme)
        return accent.opacity(0.5)
    }

    var body: some View {
        ZStack {
            // Background glow
            Circle()
                .fill(primaryColor.opacity(0.1))
                .frame(width: 80, height: 80)
                .scaleEffect(isPulsing ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 1.5).repeatForever(), value: isPulsing)

            // Icon
            Image(systemName: icon)
                .font(.system(size: 32, weight: .ultraLight))
                .foregroundColor(primaryColor)
                .symbolEffect(.variableColor.iterative, options: .repeating.speed(0.8))
        }
        .onAppear {
            isPulsing = true
        }
    }
}
