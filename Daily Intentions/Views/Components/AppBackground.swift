//
//  AppBackground.swift
//  Daily Intentions
//
//  Created for reusable app background component
//

import SwiftUI

/// Custom background view that adapts to app theme and color scheme
struct AppBackground: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        AppThemeManager.shared.backgroundColor(for: colorScheme)
            .ignoresSafeArea()
    }
}

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
