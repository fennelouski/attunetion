//
//  ThemedList.swift
//  Attunetion
//
//  Created for themed list component
//

import SwiftUI

/// Themed list that adapts to app theme
struct ThemedList<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var themeManager: AppThemeManager
    let content: Content
    
    init(themeManager: AppThemeManager, @ViewBuilder content: () -> Content) {
        self.themeManager = themeManager
        self.content = content()
    }
    
    var body: some View {
        List {
            content
        }
        .scrollContentBackground(.hidden)
        .background(themeManager.backgroundColor(for: colorScheme).toColor(colorScheme: colorScheme))
    }
}

/// Themed section header
struct ThemedSectionHeader: View {
    @Environment(\.colorScheme) var colorScheme
    let text: String
    @ObservedObject var themeManager: AppThemeManager
    
    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .medium, design: .default))
            .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
            .textCase(.none)
    }
}

/// Themed section footer
struct ThemedSectionFooter: View {
    @Environment(\.colorScheme) var colorScheme
    let text: String
    @ObservedObject var themeManager: AppThemeManager
    
    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .regular, design: .default))
            .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.8))
    }
}



