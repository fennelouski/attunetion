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
                            HStack(spacing: 16) {
                                // Widget preview
                                if let theme = themeOption.theme {
                                    WidgetPreviewCard(theme: theme, name: themeOption.name)
                                        .frame(width: 120, height: 120)
                                } else {
                                    // For "Use Intention Theme", show a placeholder
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 120, height: 120)
                                        .overlay(
                                            Text(String(localized: "Dynamic"))
                                                .font(.system(size: 10, weight: .medium))
                                                .foregroundColor(.secondary)
                                        )
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(themeOption.name)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                                    
                                    if themeOption.id == nil {
                                        Text(String(localized: "Widget matches your app theme"))
                                            .font(.system(size: 13))
                                            .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                                    } else if themeOption.id == "use_intention" {
                                        Text(String(localized: "Widget matches your intention's theme"))
                                            .font(.system(size: 13))
                                            .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                                    }
                                }
                                
                                Spacer()
                                
                                if (selectedThemeId == nil && themeOption.id == nil) || selectedThemeId == themeOption.id {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    ThemedSectionHeader(text: "Widget Appearance", themeManager: themeManager)
                } footer: {
                    ThemedSectionFooter(text: "Choose how your widget looks. Changes apply to all widget sizes.", themeManager: themeManager)
                }
            }
            .scrollContentBackground(.hidden)
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

