//
//  ThemePickerView.swift
//  Daily Intentions
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI
import SwiftData

struct ThemePickerView: View {
    @Binding var selectedTheme: IntentionTheme?
    @State private var isGeneratingAITheme = false
    let intentionText: String
    let modelContext: ModelContext
    let onAIGenerate: () async -> Void
    
    @State private var presetThemes: [IntentionTheme] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose Theme")
                .font(.headline)
            
            // Preset themes grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(presetThemes, id: \.id) { theme in
                    ThemeCard(
                        theme: theme,
                        isSelected: selectedTheme?.id == theme.id
                    ) {
                        selectedTheme = theme
                    }
                }
            }
            
            // AI Generate button
            Button(action: {
                Task {
                    isGeneratingAITheme = true
                    await onAIGenerate()
                    isGeneratingAITheme = false
                }
            }) {
                HStack {
                    if isGeneratingAITheme {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "sparkles")
                    }
                    Text("Generate AI Theme")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.accentColor.opacity(0.1))
                .foregroundColor(.accentColor)
                .cornerRadius(10)
            }
            .disabled(isGeneratingAITheme)
        }
        .onAppear {
            loadPresetThemes()
        }
    }
    
    private func loadPresetThemes() {
        Task { @MainActor in
            let themeRepo = ThemeRepository(modelContext: modelContext)
            presetThemes = themeRepo.getPresetThemes()
            if presetThemes.isEmpty {
                // Populate preset themes if they don't exist
                try? PresetThemes.populatePresetThemes(in: themeRepo)
                presetThemes = themeRepo.getPresetThemes()
            }
        }
    }
}

struct ThemeCard: View {
    let theme: IntentionTheme
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Color preview
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [theme.backgroundColorValue, theme.accentColorValue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 60)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 3)
                    )
                
                Text(theme.name)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    @Previewable @State var selected: PresetTheme? = PresetThemes.ocean
    return ThemePickerView(
        selectedTheme: $selected,
        intentionText: "Be present with family"
    ) {
        // Mock AI generation
    }
    .padding()
}

