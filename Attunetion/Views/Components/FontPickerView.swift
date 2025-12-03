//
//  FontPickerView.swift
//  Attunetion
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI
#if os(macOS)
import AppKit
#endif

struct FontOption: Identifiable {
    let id: String
    let name: String
    let font: Font
    
    static let system = FontOption(id: "system", name: "System (SF Pro)", font: .system(.body, design: .default))
    static let serif = FontOption(id: "serif", name: "Serif (New York)", font: .system(.body, design: .serif))
    static let rounded = FontOption(id: "rounded", name: "Rounded (SF Rounded)", font: .system(.body, design: .rounded))
    static let monospace = FontOption(id: "monospace", name: "Monospace (SF Mono)", font: .system(.body, design: .monospaced))
    
    static let all: [FontOption] = [system, serif, rounded, monospace]
}

struct FontPickerView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var selectedFont: String?
    @ObservedObject var themeManager: AppThemeManager
    
    init(selectedFont: Binding<String?>, themeManager: AppThemeManager) {
        self._selectedFont = selectedFont
        self.themeManager = themeManager
    }
    
    private var selectedFontOption: FontOption? {
        guard let selectedFont = selectedFont else { return nil }
        return FontOption.all.first { $0.id == selectedFont }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose Font")
                .font(.system(size: 17, weight: .semibold, design: .default))
                .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
            
            ForEach(FontOption.all) { fontOption in
                Button(action: {
                    #if os(iOS)
                    HapticFeedback.light()
                    #endif
                    selectedFont = fontOption.id
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(fontOption.name)
                                .font(.system(size: 15, weight: .medium, design: .default))
                                .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                            
                            Text("Sample Text Preview")
                                .font(fontOption.font)
                                .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                        }
                        
                        Spacer()
                        
                        if selectedFontOption?.id == fontOption.id {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(
                                selectedFontOption?.id == fontOption.id
                                    ? themeManager.accentColor(for: colorScheme).toSwiftUIColor().opacity(0.15)
                                    : (colorScheme == .dark
                                        ? themeManager.currentTheme.darkSecondaryButtonBackground.toSwiftUIColor().opacity(0.4)
                                        : Color.white.opacity(0.5))
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(
                                selectedFontOption?.id == fontOption.id
                                    ? themeManager.accentColor(for: colorScheme).toSwiftUIColor().opacity(0.3)
                                    : themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.1),
                                lineWidth: 1
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    @Previewable @State var selected: String? = "system"
    return FontPickerView(selectedFont: $selected, themeManager: AppThemeManager())
        .padding()
        .background(AppBackground(themeManager: AppThemeManager()))
}

