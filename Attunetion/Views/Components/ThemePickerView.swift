//
//  ThemePickerView.swift
//  Attunetion
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI
import SwiftData

struct ThemePickerView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var selectedTheme: IntentionTheme?
    @State private var isGeneratingAITheme = false
    let intentionText: String
    let modelContext: ModelContext
    @ObservedObject var themeManager: AppThemeManager
    let onAIGenerate: () async -> Void
    
    @State private var presetThemes: [IntentionTheme] = []
    
    init(
        selectedTheme: Binding<IntentionTheme?>,
        intentionText: String,
        modelContext: ModelContext,
        themeManager: AppThemeManager,
        onAIGenerate: @escaping () async -> Void
    ) {
        self._selectedTheme = selectedTheme
        self.intentionText = intentionText
        self.modelContext = modelContext
        self.themeManager = themeManager
        self.onAIGenerate = onAIGenerate
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(String(localized: "Choose Theme"))
                .font(.system(size: 17, weight: .semibold, design: .default))
                .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
            
            // Preset themes grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(presetThemes, id: \.id) { theme in
                    ThemeCard(
                        theme: theme,
                        isSelected: selectedTheme?.id == theme.id,
                        themeManager: themeManager
                    ) {
                        selectedTheme = theme
                    }
                }
            }
            
            // AI Generate button - only show if backend is available
            if BackendHealthManager.shared.isBackendAvailable {
                Button(action: {
                    #if os(iOS)
                    HapticFeedback.light()
                    #endif
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
                                .tint(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                        } else {
                            Image(systemName: "sparkles")
                        }
                        Text(String(localized: "Generate AI Theme"))
                            .font(.system(size: 15, weight: .medium, design: .default))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(themeManager.accentColor(for: colorScheme).toSwiftUIColor().opacity(0.15))
                    )
                    .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                }
                .disabled(isGeneratingAITheme)
            }
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
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var themeManager: AppThemeManager
    let theme: IntentionTheme
    let isSelected: Bool
    let action: () -> Void
    
    init(theme: IntentionTheme, isSelected: Bool, themeManager: AppThemeManager, action: @escaping () -> Void) {
        self.theme = theme
        self.isSelected = isSelected
        self.themeManager = themeManager
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            #if os(iOS)
            HapticFeedback.light()
            #endif
            action()
        }) {
            VStack(spacing: 8) {
                // Color preview
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [theme.backgroundColorValue, theme.accentColorValue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 60)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(
                                isSelected
                                    ? themeManager.accentColor(for: colorScheme).toSwiftUIColor()
                                    : themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.2),
                                lineWidth: isSelected ? 3 : 1
                            )
                    )
                    .shadow(
                        color: isSelected
                            ? themeManager.accentColor(for: colorScheme).toSwiftUIColor().opacity(0.3)
                            : .clear,
                        radius: isSelected ? 8 : 0,
                        x: 0,
                        y: isSelected ? 4 : 0
                    )
                
                Text(theme.name)
                    .font(.system(size: 12, weight: .medium, design: .default))
                    .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    @Previewable @State var selected: IntentionTheme? = nil
    let container = try! ModelContainer(for: IntentionTheme.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let context = container.mainContext
    ThemePickerView(
        selectedTheme: $selected,
        intentionText: "Be present with family",
        modelContext: context,
        themeManager: AppThemeManager()
    ) {
        // Mock AI generation
    }
    .padding()
    .modelContainer(container)
    .environmentObject(BackendHealthManager.shared)
}

