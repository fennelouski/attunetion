//
//  ThemedCard.swift
//  Attunetion
//
//  Created for themed card component
//

import SwiftUI

/// Themed card component with consistent styling
struct ThemedCard<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var themeManager: AppThemeManager
    let content: Content
    let padding: CGFloat
    
    init(themeManager: AppThemeManager, padding: CGFloat = 20, @ViewBuilder content: () -> Content) {
        self.themeManager = themeManager
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        colorScheme == .dark
                            ? themeManager.currentTheme.darkSecondaryButtonBackground.toSwiftUIColor().opacity(0.6)
                            : Color.white.opacity(0.7)
                    )
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
    }
}



