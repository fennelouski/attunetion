//
//  FontPickerView.swift
//  Daily Intentions
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI

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
    @Binding var selectedFont: String?
    
    private var selectedFontOption: FontOption? {
        guard let selectedFont = selectedFont else { return nil }
        return FontOption.all.first { $0.id == selectedFont }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose Font")
                .font(.headline)
            
            ForEach(FontOption.all) { fontOption in
                Button(action: {
                    selectedFont = fontOption.id
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(fontOption.name)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            
                            Text("Sample Text Preview")
                                .font(fontOption.font)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if selectedFontOption?.id == fontOption.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(selectedFontOption?.id == fontOption.id ? Color.accentColor.opacity(0.1) : Color(.systemGray6))
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    @Previewable @State var selected: String? = "system"
    return FontPickerView(selectedFont: $selected)
        .padding()
}

