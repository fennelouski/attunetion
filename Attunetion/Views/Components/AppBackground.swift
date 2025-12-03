//
//  AppBackground.swift
//  Attunetion
//
//  Created for reusable app background component
//

import SwiftUI

/// Custom background view that adapts to app theme and color scheme
struct AppBackground: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var themeManager: AppThemeManager
    
    var body: some View {
        themeManager.backgroundColor(for: colorScheme)
            .toColor(colorScheme: colorScheme)
            .ignoresSafeArea()
    }
}

/// Gradient background view for special screens
struct GradientBackground: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var themeManager: AppThemeManager
    
    let startColor: ThemeColor
    let endColor: ThemeColor
    
    init(themeManager: AppThemeManager, startColor: ThemeColor? = nil, endColor: ThemeColor? = nil) {
        self.themeManager = themeManager
        self.startColor = startColor ?? themeManager.accentColor(for: .light)
        self.endColor = endColor ?? themeManager.accentColor(for: .dark)
    }
    
    var body: some View {
        LinearGradient(
            colors: [
                startColor.toSwiftUIColor(),
                endColor.toSwiftUIColor()
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}



