//
//  WidgetAppearanceView.swift
//  Attunetion
//
//  Created for widget appearance customization
//

import SwiftUI
import SwiftData
import WidgetKit

struct WidgetAppearanceView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var themeManager: AppThemeManager
    @Query private var preferencesQuery: [UserPreferences]
    @State private var selectedThemeId: String?
    
    private var preferences: UserPreferences? {
        preferencesQuery.first
    }
    
    // Widget theme options
    private var widgetThemes: [(id: String?, name: String, theme: ThemeData?)] {
        var themes: [(id: String?, name: String, theme: ThemeData?)] = []
        
        // First option: Use App Theme (nil = default)
        if let appTheme = themeManager.currentTheme.lightBackground.hex,
           let textColor = themeManager.currentTheme.lightPrimaryText.hex {
            themes.append((
                id: nil,
                name: String(localized: "Use App Theme"),
                theme: ThemeData(
                    backgroundColor: appTheme,
                    textColor: textColor,
                    accentColor: themeManager.currentTheme.lightAccent.hex,
                    fontName: nil
                )
            ))
        }
        
        // Second option: Use Intention Theme
        themes.append((
            id: "use_intention",
            name: String(localized: "Use Intention Theme"),
            theme: nil // Will use intention's theme dynamically
        ))
        
        // Preset widget themes
        themes.append(("ocean", "Ocean", WidgetTheme.ocean))
        themes.append(("sunset", "Sunset", WidgetTheme.sunset))
        themes.append(("forest", "Forest", WidgetTheme.forest))
        themes.append(("minimal", "Minimal", WidgetTheme.minimal))
        themes.append(("midnight", "Midnight", WidgetTheme.midnight))
        
        return themes
    }
    
    var body: some View {
        ZStack {
            AppBackground(themeManager: themeManager)
            
            List {
                Section {
                    ForEach(Array(widgetThemes.enumerated()), id: \.offset) { index, themeOption in
                        Button(action: {
                            #if os(iOS)
                            HapticFeedback.light()
                            #endif
                            selectedThemeId = themeOption.id
                            saveWidgetTheme(themeOption.id)
                            // Reload widgets
                            WidgetCenter.shared.reloadAllTimelines()
                        }) {
                            Group {
                                if dynamicTypeSize.isAccessibilitySize {
                                    VStack(alignment: .leading, spacing: 12) {
                                        choiceLabel(themeOption)
                                        choicePreview(themeOption)
                                    }
                                } else {
                                    HStack(spacing: 16) {
                                        choicePreview(themeOption)
                                        choiceLabel(themeOption)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(Color.clear)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(themeOption.name)
                        .accessibilityValue(selectedThemeId == themeOption.id ? "Selected" : "")
                    }
                } header: {
                    ThemedSectionHeader(text: "Widget Appearance", themeManager: themeManager)
                } footer: {
                    ThemedSectionFooter(text: "Choose how your widget looks. Changes apply to all widget sizes.", themeManager: themeManager)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .frame(maxWidth: 740)
        }
        .navigationTitle(String(localized: "Widget Appearance"))
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onAppear {
            // Load current selection
            // nil = use app theme (default), "use_intention" = use intention theme, or specific theme name
            if let prefs = preferences {
                selectedThemeId = prefs.widgetThemeId // nil means use app theme
            } else {
                selectedThemeId = nil // Default to app theme
            }
        }
    }
    
    @ViewBuilder
    private func choicePreview(_ option: (id: String?, name: String, theme: ThemeData?)) -> some View {
        Group {
            if let theme = option.theme {
                WidgetPreviewCard(theme: theme, name: option.name)
            } else {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.gray.opacity(0.2))
                    .overlay(Text(String(localized: "Dynamic")).font(.caption).foregroundStyle(.secondary))
            }
        }
        .frame(width: 120, height: 120)
        .accessibilityHidden(true)
    }

    private func choiceLabel(_ option: (id: String?, name: String, theme: ThemeData?)) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(option.name)
                    .font(.body.weight(.medium))
                    .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                if option.id == nil {
                    Text(String(localized: "Widget matches your app theme"))
                        .font(.footnote)
                        .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                } else if option.id == "use_intention" {
                    Text(String(localized: "Widget matches your intention's theme"))
                        .font(.footnote)
                        .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            if selectedThemeId == option.id {
                Image(systemName: "checkmark")
                    .font(.body.weight(.semibold))
                    .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                    .fixedSize()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func saveWidgetTheme(_ themeId: String?) {
        let prefsRepo = UserPreferencesRepository(modelContext: modelContext)
        let prefs = prefsRepo.getOrCreatePreferences()
        prefs.widgetThemeId = themeId
        
        // Update widget data service
        if themeId == nil {
            // Use app theme - will be handled by widget data service
            WidgetDataService.shared.updateWidgetThemePreference(nil)
        } else if themeId == "use_intention" {
            // Use intention's theme - will be handled by widget data service
            WidgetDataService.shared.updateWidgetThemePreference(nil)
        } else {
            // Use selected preset theme
            if let themeOption = widgetThemes.first(where: { $0.id == themeId }) {
                WidgetDataService.shared.updateWidgetThemePreference(themeOption.theme)
            }
        }
        
        try? prefsRepo.update(prefs)
        
        // Reload widget data to apply changes
        WidgetDataService.shared.updateWidgetDataFromSwiftData(modelContext: modelContext)
    }
}

struct WidgetPreviewCard: View {
    let theme: ThemeData
    let name: String
    
    var body: some View {
        ZStack {
            // Background gradient
            WidgetTheme.gradient(for: theme)
            WidgetTheme.overlayGradient()
            
            // Sample content
            VStack(spacing: 4) {
                Image(systemName: "target")
                    .font(.system(size: 20, weight: .light))
                    .foregroundColor(WidgetTheme.color(from: theme.textColor).opacity(0.7))
                
                Text("Sample")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(WidgetTheme.color(from: theme.textColor))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .padding(8)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        WidgetAppearanceView()
            .modelContainer(for: UserPreferences.self, inMemory: true)
            .environmentObject(AppThemeManager())
    }
}

