//
//  AnimatedWeeklyIcon.swift
//  Daily Intentions
//
//  Created by Nathan Fennel on 12/21/25.
//

import SwiftUI

struct AnimatedWeeklyIcon: View {
    let iconIndex: Int
    let icon: String
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

            // Weekly icon
            Image(systemName: icon)
                .font(.system(size: 32, weight: .ultraLight))
                .foregroundColor(primaryColor)
                .symbolEffect(.variableColor.iterative, options: .repeating.speed(0.7))
        }
    }
}

