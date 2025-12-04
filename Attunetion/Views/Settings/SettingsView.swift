//
//  SettingsView.swift
//  Attunetion
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI
import SwiftData
import UserNotifications
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct SettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var themeManager: AppThemeManager
    @Query private var preferencesQuery: [UserPreferences]
    @State private var defaultTheme: PresetTheme? = nil
    @State private var defaultFont: String? = nil
    @State private var showingAbout = false
    @State private var showingAppThemePicker = false
    @State private var showingOnboarding = false
    @State private var showingUserProfile = false
    @State private var showDeleteDataAlert = false
    @State private var notificationAuthorizationStatus: UNAuthorizationStatus = .notDetermined
    @State private var isRequestingPermission = false
    @State private var showPermissionAlert = false
    
    private var preferences: UserPreferences? {
        preferencesQuery.first
    }
    
    private var notificationSettings: NotificationSettings {
        preferences?.notificationSettings ?? NotificationSettings()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground(themeManager: themeManager)
                
                List {
                    Section {
                        // App Theme picker
                        Button(action: {
                            #if os(iOS)
                            HapticFeedback.light()
                            #endif
                            showingAppThemePicker = true
                        }) {
                            HStack {
                                Text("App Theme")
                                    .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                                Spacer()
                                Text(themeManager.currentTheme.name)
                                    .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                            }
                        }
                        
                        // Default theme picker (for intention themes)
                        NavigationLink(destination: DefaultThemePickerView(selectedTheme: $defaultTheme)) {
                            HStack {
                                Text("Default Intention Theme")
                                    .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                                Spacer()
                                if let theme = defaultTheme {
                                    Text(theme.name)
                                        .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                                } else {
                                    Text("None")
                                        .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                                }
                            }
                        }
                        
                        // Default font picker
                        NavigationLink(destination: DefaultFontPickerView(selectedFont: $defaultFont)) {
                            HStack {
                                Text("Default Font")
                                    .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                                Spacer()
                                if let fontId = defaultFont,
                                   let fontOption = FontOption.all.first(where: { $0.id == fontId }) {
                                    Text(fontOption.name)
                                        .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                                } else {
                                    Text("System Default")
                                        .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                                }
                            }
                        }
                    } header: {
                        ThemedSectionHeader(text: "Appearance", themeManager: themeManager)
                    }
                
                Section {
                    // Default intention frequency
                    Picker(selection: Binding(
                        get: {
                            preferences?.intentionFrequency ?? .monthly
                        },
                        set: { newFrequency in
                            if let prefs = preferences {
                                prefs.intentionFrequency = newFrequency
                                // Sync to widget
                                WidgetDataService.shared.updateIntentionFrequency(newFrequency.rawValue)
                                try? UserPreferencesRepository(modelContext: modelContext).update(prefs)
                            }
                        }
                    )) {
                        ForEach(IntentionFrequency.allCases, id: \.self) { frequency in
                            HStack {
                                Text(frequency.displayName)
                                Spacer()
                                Text(frequency.description)
                                    .font(.caption)
                                    .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                            }
                            .tag(frequency)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "calendar.badge.clock")
                                .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                                .frame(width: 24)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Intention Frequency")
                                    .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                                Text("How often you want to set intentions")
                                    .font(.caption)
                                    .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                            }
                        }
                    }
                } header: {
                    ThemedSectionHeader(text: "Intentions", themeManager: themeManager)
                } footer: {
                    ThemedSectionFooter(text: "Choose how often you'd like to set new intentions. This helps personalize your widget's placeholder text.", themeManager: themeManager)
                }
                
                Section {
                    // Notification settings
                    NavigationLink(destination: NotificationSettingsView()) {
                        HStack {
                            Text("Reminders")
                                .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                            Spacer()
                            
                            // Show summary when notifications are enabled
                            if notificationAuthorizationStatus == .authorized {
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text(notificationSettings.frequency.displayName)
                                        .font(.caption)
                                        .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                                    
                                    if !notificationSettings.enabledTypes.isEmpty {
                                        Text("\(notificationSettings.enabledTypes.count) type\(notificationSettings.enabledTypes.count == 1 ? "" : "s")")
                                            .font(.caption2)
                                            .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                                            .opacity(0.7)
                                    }
                                }
                            }
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                        }
                    }
                } header: {
                    ThemedSectionHeader(text: "Notifications", themeManager: themeManager)
                } footer: {
                    if notificationAuthorizationStatus == .authorized {
                        ThemedSectionFooter(text: "Configure how often and what types of reminders you receive.", themeManager: themeManager)
                    }
                }
                
                Section {
                    NavigationLink(destination: UserProfileView(modelContext: modelContext)) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Suggested Intentions")
                                    .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                                Text("Get personalized suggestions for your intentions")
                                    .font(.caption)
                                    .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                            }
                            
                            Spacer()
                        }
                    }
                } header: {
                    ThemedSectionHeader(text: "Suggestions", themeManager: themeManager)
                }
                
                Section {
                    Button(action: {
                        #if os(iOS)
                        HapticFeedback.light()
                        #endif
                        showingAbout = true
                    }) {
                        HStack {
                            Text("About")
                                .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                        }
                    }
                    
                    // Legal documents
                    let baseURL = APIClient.shared.baseURL.isEmpty ? "https://your-project.vercel.app" : APIClient.shared.baseURL
                    
                    if let privacyURL = URL(string: "\(baseURL)/legal/privacy-policy.html") {
                        Link(destination: privacyURL) {
                            HStack {
                                Text("Privacy Policy")
                                    .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .font(.caption)
                                    .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                            }
                        }
                    }
                    
                    if let eulaURL = URL(string: "\(baseURL)/legal/eula.html") {
                        Link(destination: eulaURL) {
                            HStack {
                                Text("End User License Agreement")
                                    .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .font(.caption)
                                    .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                            }
                        }
                    }
                    
                    if let termsURL = URL(string: "\(baseURL)/legal/terms-of-service.html") {
                        Link(destination: termsURL) {
                            HStack {
                                Text("Terms of Service")
                                    .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .font(.caption)
                                    .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                            }
                        }
                    }
                    
                    // Delete all data
                    Button(action: {
                        #if os(iOS)
                        HapticFeedback.light()
                        #endif
                        showDeleteDataAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .frame(width: 24)
                            Text("Delete All Data")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                    
                    // Export data (placeholder for future)
                    Button(action: {
                        // TODO: Implement export
                    }) {
                        Text("Export Data")
                            .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.6))
                    }
                    .disabled(true)
                } header: {
                    ThemedSectionHeader(text: "About", themeManager: themeManager)
                }
                
                Section {
                    Button(action: {
                        #if os(iOS)
                        HapticFeedback.light()
                        #endif
                        showingOnboarding = true
                    }) {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Show Onboarding")
                                    .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                                Text("Learn how to use the app and get inspiration")
                                    .font(.caption)
                                    .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                        }
                    }
                } header: {
                    Text(String(localized: "Help"))
                } footer: {
                    Text(String(localized: "Walk through the onboarding flow again to learn about features and get ideas for how to use the app."))
                }
                
                // Permissions Section - only show if not authorized, and at the bottom
                if notificationAuthorizationStatus != .authorized {
                    permissionsSection
                }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(String(localized: "Settings"))
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
            .sheet(isPresented: $showingAppThemePicker) {
                AppThemePickerView(themeManager: themeManager)
            }
            #if os(iOS)
            .fullScreenCover(isPresented: $showingOnboarding) {
                OnboardingContainerView {
                    showingOnboarding = false
                }
                .environment(\.modelContext, modelContext)
            }
            #else
            .sheet(isPresented: $showingOnboarding) {
                OnboardingContainerView {
                    showingOnboarding = false
                }
                .environment(\.modelContext, modelContext)
            }
            #endif
            .task {
                await checkNotificationAuthorizationStatus()
            }
            .onAppear {
                // Refresh status when view appears (e.g., returning from Settings)
                Task {
                    await checkNotificationAuthorizationStatus()
                }
                // Ensure preferences exist and sync frequency to widget
                let prefsRepo = UserPreferencesRepository(modelContext: modelContext)
                let prefs = prefsRepo.getOrCreatePreferences()
                WidgetDataService.shared.updateIntentionFrequency(prefs.intentionFrequency.rawValue)
            }
            .onChange(of: notificationAuthorizationStatus) { _, _ in
                // Refresh when status changes
                Task {
                    await checkNotificationAuthorizationStatus()
                }
            }
            .alert("Enable Notifications", isPresented: $showPermissionAlert) {
                Button("Open Settings") {
                    openSettings()
                }
                Button("Maybe Later", role: .cancel) {}
            } message: {
                Text("To receive reminders, please enable notifications in your device settings.")
            }
            .alert("Delete All Data", isPresented: $showDeleteDataAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    deleteAllData()
                }
            } message: {
                Text("This will permanently delete all your intentions, themes, preferences, and profile information. This action cannot be undone. Your data is stored locally and synced via iCloud, so it will be removed from all your devices.")
            }
        }
    }
    
    // MARK: - Permissions Section
    
    private var permissionsSection: some View {
        Section {
            // Notification permission row
            HStack {
                Image(systemName: "bell.fill")
                    .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Notifications")
                        .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                    Text(notificationStatusText)
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                }
                
                Spacer()
                
                notificationStatusBadge
            }
            
            // Enable button if not authorized
            if notificationAuthorizationStatus != .authorized {
                Button(action: {
                    #if os(iOS)
                    HapticFeedback.light()
                    #endif
                    Task {
                        await requestNotificationPermission()
                    }
                }) {
                    HStack {
                        Spacer()
                        Text("Enable Notifications")
                            .fontWeight(.medium)
                            .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                        Spacer()
                    }
                }
                .disabled(isRequestingPermission)
            }
        } header: {
            Text(String(localized: "Permissions"))
        } footer: {
            if notificationAuthorizationStatus != .authorized {
                Text(String(localized: "Enable notifications to receive reminders about setting your intentions."))
            }
        }
    }
    
    @ViewBuilder
    private var notificationStatusBadge: some View {
        switch notificationAuthorizationStatus {
        case .authorized:
            Label("Enabled", systemImage: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.caption)
        case .denied:
            Label("Disabled", systemImage: "xmark.circle.fill")
                .foregroundColor(.red)
                .font(.caption)
        case .notDetermined:
            Label("Not Set", systemImage: "questionmark.circle.fill")
                .foregroundColor(.orange)
                .font(.caption)
        default:
            Label("Unknown", systemImage: "questionmark.circle")
                .foregroundColor(.gray)
                .font(.caption)
        }
    }
    
    private var notificationStatusText: String {
        switch notificationAuthorizationStatus {
        case .authorized:
            return "You'll receive reminders based on your settings"
        case .denied:
            return "Notifications are disabled in Settings"
        case .notDetermined:
            return "Enable notifications to get reminders"
        default:
            return "Notification status unknown"
        }
    }
    
    // MARK: - Methods
    
    private func checkNotificationAuthorizationStatus() async {
        notificationAuthorizationStatus = await NotificationManager.shared.getNotificationStatus()
    }
    
    private func requestNotificationPermission() async {
        isRequestingPermission = true
        defer { isRequestingPermission = false }
        
        let granted = await NotificationManager.shared.requestAuthorization()
        
        if !granted {
            showPermissionAlert = true
        }
        
        await checkNotificationAuthorizationStatus()
    }
    
    private func openSettings() {
        #if os(iOS)
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
        #elseif os(macOS)
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") {
            NSWorkspace.shared.open(url)
        }
        #endif
    }
    
    private func deleteAllData() {
        // Delete all intentions
        let intentionRepo = IntentionRepository(modelContext: modelContext)
        let allIntentions = intentionRepo.getAll()
        for intention in allIntentions {
            try? intentionRepo.delete(intention)
        }
        
        // Delete user profile
        let profileRepo = UserProfileRepository(modelContext: modelContext)
        if let profile = profileRepo.getProfile() {
            try? profileRepo.delete(profile)
        }
        
        // Note: Themes and preferences are not deleted as they may be preset/system settings
        // Users can delete custom themes individually if needed
    }
}

/// App Theme Picker View
struct AppThemePickerView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var themeManager: AppThemeManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground(themeManager: themeManager)
                
                List {
                    ForEach(AppTheme.presetThemes) { theme in
                        Button(action: {
                            #if os(iOS)
                            HapticFeedback.medium()
                            #endif
                            themeManager.setTheme(theme)
                            dismiss()
                        }) {
                            HStack(spacing: 16) {
                                // Theme preview
                                HStack(spacing: 0) {
                                    Rectangle()
                                        .fill(theme.lightBackground.toSwiftUIColor())
                                        .frame(width: 40, height: 40)
                                    Rectangle()
                                        .fill(theme.lightAccent.toSwiftUIColor())
                                        .frame(width: 20, height: 40)
                                }
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(
                                            themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.2),
                                            lineWidth: 1
                                        )
                                )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(LocalizedStringKey(theme.name))
                                        .font(.system(size: 16, weight: .medium, design: .default))
                                        .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                                    
                                    Text(themeDescription(for: theme))
                                        .font(.system(size: 13, weight: .regular, design: .default))
                                        .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                                }
                                
                                Spacer()
                                
                                if themeManager.currentTheme.id == theme.id {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(String(localized: "App Theme"))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Done")) {
                        dismiss()
                    }
                    .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                }
            }
        }
    }
    
    private func themeDescription(for theme: AppTheme) -> String {
        switch theme.name {
        case "Serenity":
            return String(localized: "Calm and peaceful")
        case "Sunset":
            return String(localized: "Warm and cozy")
        case "Ocean":
            return String(localized: "Cool and refreshing")
        default:
            return String(localized: "Custom theme")
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
            
            ForEach(MockPresetThemes.all) { theme in
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
        .navigationTitle(String(localized: "Default Theme"))
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
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
                        
                        Text(String(localized: "Sample Text Preview"))
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
        .navigationTitle(String(localized: "Default Font"))
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct NotificationSettingsPlaceholderView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.slash")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text(String(localized: "Notification Settings"))
                .font(.title2)
                .fontWeight(.semibold)
            Text(String(localized: "Notification settings will be available here once the notification team completes their work."))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .navigationTitle(String(localized: "Notifications"))
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

#Preview {
    SettingsView()
}

