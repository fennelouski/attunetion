//
//  GradientBackground.swift
//  Daily Intentions
//
//  Created by Nathan Fennel on 12/21/25.
//

import SwiftUI

/// Gradient background view for special screens
struct GradientBackground: View {
    @Environment(\.colorScheme) var colorScheme

    let startColor: Color
    let endColor: Color

    init(startColor: Color? = nil, endColor: Color? = nil) {
        self.startColor = startColor ?? AppThemeManager.shared.accentColor(for: .light)
        self.endColor = endColor ?? AppThemeManager.shared.accentColor(for: .dark)
    }

    var body: some View {
        LinearGradient(
            colors: [
                startColor,
                endColor
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}
