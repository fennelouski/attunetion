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
