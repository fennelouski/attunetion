//
//  ScopeSelector.swift
//  Attunetion
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI
#if os(macOS)
import AppKit
#endif

struct ScopeSelector: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var selectedScope: IntentionScope?
    @ObservedObject var themeManager: AppThemeManager
    let availableScopes: [IntentionScope]
    
    init(selectedScope: Binding<IntentionScope?>, themeManager: AppThemeManager, availableScopes: [IntentionScope]) {
        self._selectedScope = selectedScope
        self.themeManager = themeManager
        self.availableScopes = availableScopes
    }
    
    private var buttonSpacing: CGFloat {
        #if os(watchOS)
        return 6
        #else
        return 10
        #endif
    }
    
    private var buttonFontSize: CGFloat {
        #if os(watchOS)
        return 12
        #else
        return 14
        #endif
    }
    
    private var buttonHorizontalPadding: CGFloat {
        #if os(watchOS)
        return 12
        #else
        return 18
        #endif
    }
    
    private var buttonVerticalPadding: CGFloat {
        #if os(watchOS)
        return 8
        #else
        return 10
        #endif
    }
    
    private var buttonCornerRadius: CGFloat {
        #if os(watchOS)
        return 8
        #else
        return 10
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
        HStack(spacing: buttonSpacing) {
            // "All" button
            Button(action: {
                selectedScope = nil
            }) {
                Text("All")
                    .font(.system(size: buttonFontSize, weight: selectedScope == nil ? .semibold : .regular, design: fontDesign))
                    .foregroundColor(
                        selectedScope == nil
                            ? themeManager.buttonTextColor(for: colorScheme).toSwiftUIColor()
                            : themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor()
                    )
                    .padding(.horizontal, buttonHorizontalPadding)
                    .padding(.vertical, buttonVerticalPadding)
                    .background(
                        RoundedRectangle(cornerRadius: buttonCornerRadius, style: .continuous)
                            .fill(
                                selectedScope == nil
                                    ? themeManager.buttonBackgroundColor(for: colorScheme).toSwiftUIColor()
                                    : (colorScheme == .dark
                                        ? themeManager.currentTheme.darkSecondaryButtonBackground.toSwiftUIColor().opacity(0.4)
                                        : Color.white.opacity(0.5))
                            )
                    )
            }
            .buttonStyle(.plain)
            
            // Scope buttons (only show available scopes)
            ForEach(availableScopes, id: \.self) { scope in
                Button(action: {
                    selectedScope = selectedScope == scope ? nil : scope
                }) {
                    Text(scope.rawValue.capitalized)
                        .font(.system(size: buttonFontSize, weight: selectedScope == scope ? .semibold : .regular, design: fontDesign))
                        .foregroundColor(
                            selectedScope == scope
                                ? themeManager.buttonTextColor(for: colorScheme).toSwiftUIColor()
                                : themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor()
                        )
                        .padding(.horizontal, buttonHorizontalPadding)
                        .padding(.vertical, buttonVerticalPadding)
                        .background(
                            RoundedRectangle(cornerRadius: buttonCornerRadius, style: .continuous)
                                .fill(
                                    selectedScope == scope
                                        ? themeManager.buttonBackgroundColor(for: colorScheme).toSwiftUIColor()
                                        : (colorScheme == .dark
                                            ? themeManager.currentTheme.darkSecondaryButtonBackground.toSwiftUIColor().opacity(0.4)
                                            : Color.white.opacity(0.5))
                                )
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    @Previewable @State var selected: IntentionScope? = .day
    return ScopeSelector(selectedScope: $selected, themeManager: AppThemeManager(), availableScopes: [.day, .week, .month])
        .padding()
        .background(AppBackground(themeManager: AppThemeManager()))
}
