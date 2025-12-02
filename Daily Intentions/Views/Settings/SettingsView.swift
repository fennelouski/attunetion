//
//  SettingsView.swift
//  Daily Intentions
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI

struct SettingsView: View {
    @State private var defaultTheme: PresetTheme? = nil
    @State private var defaultFont: String? = nil
    @State private var showingAbout = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    // Default theme picker
                    NavigationLink(destination: DefaultThemePickerView(selectedTheme: $defaultTheme)) {
                        HStack {
                            Text("Default Theme")
                            Spacer()
                            if let theme = defaultTheme {
                                Text(theme.name)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("None")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Default font picker
                    NavigationLink(destination: DefaultFontPickerView(selectedFont: $defaultFont)) {
                        HStack {
                            Text("Default Font")
                            Spacer()
                            if let fontId = defaultFont,
                               let fontOption = FontOption.all.first(where: { $0.id == fontId }) {
                                Text(fontOption.name)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("System Default")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Appearance")
                }
                
                Section {
                    // Notification settings (placeholder - will be built by notification team)
                    NavigationLink(destination: NotificationSettingsPlaceholderView()) {
                        HStack {
                            Text("Notifications")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Notifications")
                }
                
                Section {
                    Button(action: {
                        showingAbout = true
                    }) {
                        HStack {
                            Text("About")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Export data (placeholder for future)
                    Button(action: {
                        // TODO: Implement export
                    }) {
                        Text("Export Data")
                    }
                    .disabled(true)
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
        }
    }
}

struct DefaultThemePickerView: View {
    @Binding var selectedTheme: PresetTheme?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            Button(action: {
                selectedTheme = nil
                dismiss()
            }) {
                HStack {
                    Text("None")
                    Spacer()
                    if selectedTheme == nil {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
            }
            
            ForEach(PresetThemes.all) { theme in
                Button(action: {
                    selectedTheme = theme
                    dismiss()
                }) {
                    HStack {
                        // Color swatch
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [theme.backgroundColor, theme.accentColor ?? theme.backgroundColor],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 30, height: 30)
                        
                        Text(theme.name)
                        
                        Spacer()
                        
                        if selectedTheme?.id == theme.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
        }
        .navigationTitle("Default Theme")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DefaultFontPickerView: View {
    @Binding var selectedFont: String?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            Button(action: {
                selectedFont = nil
                dismiss()
            }) {
                HStack {
                    Text("System Default")
                    Spacer()
                    if selectedFont == nil {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
            }
            
            ForEach(FontOption.all) { fontOption in
                Button(action: {
                    selectedFont = fontOption.id
                    dismiss()
                }) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(fontOption.name)
                        
                        Text("Sample Text Preview")
                            .font(fontOption.font)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .overlay(
                        HStack {
                            Spacer()
                            if selectedFont == fontOption.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    )
                }
            }
        }
        .navigationTitle("Default Font")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct NotificationSettingsPlaceholderView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.slash")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("Notification Settings")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Notification settings will be available here once the notification team completes their work.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsView()
}

