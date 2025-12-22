//
//  AnimatedCalendarIcon.swift
//  Daily Intentions
//
//  Created by Nathan Fennel on 12/21/25.
//

import SwiftUI

struct AnimatedCalendarIcon: View {
    let iconIndex: Int
    let colorScheme: ColorScheme

    private var primaryColor: Color {
        AppThemeManager.shared.accentColor(for: colorScheme)
    }

    var body: some View {
        ZStack {
            // Background glow
            Circle()
                .fill(primaryColor.opacity(0.1))
                .frame(width: 80, height: 80)

            // Calendar with animated date
            Image(systemName: "calendar")
                .font(.system(size: 32, weight: .ultraLight))
                .foregroundColor(primaryColor)
                .symbolEffect(.variableColor.iterative, options: .repeating.speed(0.6))
                .overlay(
                    Text("\(iconIndex + 1)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(primaryColor)
                        .offset(y: 2)
                )
        }
    }
}
