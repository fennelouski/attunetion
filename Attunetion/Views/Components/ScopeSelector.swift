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
            scopeButton(label: "All", isSelected: selectedScope == nil) {
                selectedScope = nil
            }
            // Scope buttons (only show available scopes)
            ForEach(availableScopes, id: \.self) { scope in
                scopeButton(label: scope.rawValue.capitalized, isSelected: selectedScope == scope) {
                    selectedScope = selectedScope == scope ? nil : scope
                }
            }
        }
    }

    @ViewBuilder
    private func scopeButton(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        let tintColor = isSelected
            ? themeManager.buttonBackgroundColor(for: colorScheme).toSwiftUIColor()
            : (colorScheme == .dark
                ? themeManager.currentTheme.darkSecondaryButtonBackground.toSwiftUIColor()
                : Color.white)
        let textColor = isSelected
            ? themeManager.buttonTextColor(for: colorScheme).toSwiftUIColor()
            : themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor()

        if isSelected {
            Button(action: action) {
                Text(label)
                    .font(.system(size: buttonFontSize, weight: .semibold, design: fontDesign))
                    .frame(maxWidth: .infinity)
            }
            .accessibilityAddTraits(.isSelected)
            .buttonStyle(.borderedProminent)
            .controlSize(.regular)
            .tint(tintColor)
            .foregroundColor(textColor)
        } else {
            Button(action: action) {
                Text(label)
                    .font(.system(size: buttonFontSize, weight: .regular, design: fontDesign))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.regular)
            .tint(tintColor)
            .foregroundColor(textColor)
        }
    }
}

#Preview {
    @Previewable @State var selected: IntentionScope? = .day
    return ScopeSelector(selectedScope: $selected, themeManager: AppThemeManager(), availableScopes: [.day, .week, .month])
        .padding()
        .background(AppBackground(themeManager: AppThemeManager()))
}
