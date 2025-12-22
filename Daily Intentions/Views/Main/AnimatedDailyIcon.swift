//
//  AnimatedDailyIcon.swift
//  Daily Intentions
//
//  Created by Nathan Fennel on 12/21/25.
//

import SwiftUI

struct AnimatedDailyIcon: View {
    let iconIndex: Int
    let colorScheme: ColorScheme

    var primaryColor: Color {
        AppThemeManager.shared.accentColor(for: colorScheme)
    }

    var dailyIcons = ["sunrise", "sun.max", "sunset", "moon.stars"]

    var body: some View {
        ZStack {
            // Background glow
            Circle()
                .fill(primaryColor.opacity(0.1))
                .frame(width: 80, height: 80)

            // Daily icon
            Image(systemName: dailyIcons[iconIndex % dailyIcons.count])
                .font(.system(size: 32, weight: .ultraLight))
                .foregroundColor(primaryColor)
                .symbolEffect(.variableColor.iterative, options: .repeating.speed(0.9))
        }
    }
}
