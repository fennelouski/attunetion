//
//  PrimaryButton.swift
//  Attunetion
//
//  Created for reusable primary button component
//

import SwiftUI

/// Custom primary button style that adapts to app theme
struct PrimaryButton: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var themeManager: AppThemeManager
    
    let title: String
    let action: () -> Void
    
    init(_ title: String, themeManager: AppThemeManager, action: @escaping () -> Void) {
        self.title = title
        self.themeManager = themeManager
        self.action = action
    }
    
    private var buttonHeight: CGFloat {
        #if os(watchOS)
        return 44
        #elseif os(iOS)
        return 50
        #else
        return 52
        #endif
    }
    
    private var cornerRadius: CGFloat {
        #if os(watchOS)
        return 10
        #elseif os(iOS)
        return 12
        #else
        return 14
        #endif
    }
    
    private var shadowRadius: CGFloat {
        #if os(watchOS)
        return 0  // No shadows on watchOS for better performance
        #elseif os(iOS)
        return 6
        #else
        return 8
        #endif
    }
    
    private var shadowY: CGFloat {
        #if os(watchOS)
        return 0
        #elseif os(iOS)
        return 2
        #else
        return 4
        #endif
    }
    
    private var fontSize: CGFloat {
        #if os(watchOS)
        return 15
        #else
        return 17
        #endif
    }
    
    private var fontDesign: Font.Design {
        #if os(watchOS)
        return .rounded
        #else
        return .default
        #endif
    }
    
    var body: some View {
        Button(action: {
            #if os(iOS)
            HapticFeedback.light()
            #endif
            action()
        }) {
            Text(title)
                .font(.system(size: fontSize, weight: .semibold, design: fontDesign))
                .foregroundColor(themeManager.buttonTextColor(for: colorScheme).toSwiftUIColor())
                .frame(maxWidth: .infinity)
                .frame(height: buttonHeight)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(themeManager.buttonBackgroundColor(for: colorScheme).toSwiftUIColor())
                )
                .shadow(
                    color: shadowRadius > 0 ? themeManager.buttonBackgroundColor(for: colorScheme).toSwiftUIColor().opacity(0.3) : .clear,
                    radius: shadowRadius,
                    x: 0,
                    y: shadowY
                )
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
    }
}

/// Custom secondary button style
struct SecondaryButton: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var themeManager: AppThemeManager
    
    let title: String
    let action: () -> Void
    
    init(_ title: String, themeManager: AppThemeManager, action: @escaping () -> Void) {
        self.title = title
        self.themeManager = themeManager
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .default))
                .foregroundColor(themeManager.secondaryButtonTextColor(for: colorScheme).toSwiftUIColor())
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(themeManager.secondaryButtonBackgroundColor(for: colorScheme).toSwiftUIColor())
                )
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
    }
}

/// Text-only button style for subtle actions
struct TextButton: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var themeManager: AppThemeManager
    
    let title: String
    let action: () -> Void
    
    init(_ title: String, themeManager: AppThemeManager, action: @escaping () -> Void) {
        self.title = title
        self.themeManager = themeManager
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .medium, design: .default))
                .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
        }
        .buttonStyle(.plain)
    }
}

