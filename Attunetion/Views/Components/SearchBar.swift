//
//  SearchBar.swift
//  Attunetion
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI
#if os(macOS)
import AppKit
#endif

struct SearchBar: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var text: String
    @ObservedObject var themeManager: AppThemeManager
    var placeholder: String = "Search intentions..."
    
    init(text: Binding<String>, themeManager: AppThemeManager, placeholder: String = "Search intentions...") {
        self._text = text
        self.themeManager = themeManager
        self.placeholder = placeholder
    }
    
    private var horizontalPadding: CGFloat {
        #if os(watchOS)
        return 8
        #else
        return 16
        #endif
    }
    
    private var verticalPadding: CGFloat {
        #if os(watchOS)
        return 8
        #else
        return 12
        #endif
    }
    
    private var cornerRadius: CGFloat {
        #if os(watchOS)
        return 8
        #else
        return 12
        #endif
    }
    
    private var iconSize: CGFloat {
        #if os(watchOS)
        return 12
        #else
        return 15
        #endif
    }
    
    private var fontSize: CGFloat {
        #if os(watchOS)
        return 13
        #else
        return 15
        #endif
    }
    
    private var hStackSpacing: CGFloat {
        #if os(watchOS)
        return 8
        #else
        return 12
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
        HStack(spacing: hStackSpacing) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: iconSize, weight: .medium))
                .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
            
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .font(.system(size: fontSize, weight: .regular, design: fontDesign))
                .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: iconSize + 1))
                        .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    colorScheme == .dark
                        ? themeManager.currentTheme.darkSecondaryButtonBackground.toSwiftUIColor().opacity(0.5)
                        : Color.white.opacity(0.7)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(
                    themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.15),
                    lineWidth: 1
                )
        )
    }
}

#Preview {
    @Previewable @State var searchText = ""
    SearchBar(text: $searchText, themeManager: AppThemeManager())
        .padding()
        .background(AppBackground(themeManager: AppThemeManager()))
}
