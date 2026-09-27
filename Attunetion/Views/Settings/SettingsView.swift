//
//  SettingsView.swift
//  Attunetion
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI
import SwiftData
import UserNotifications
#if canImport(WidgetKit)
import WidgetKit
#endif
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
    @State private var deletionError: String?
    @State private var notificationAuthorizationStatus: UNAuthorizationStatus = .notDetermined
    @State private var isRequestingPermission = false
    @State private var showPermissionAlert = false
    @AppStorage("intentionListStyle") private var intentionListStyle: IntentionListStyle = .cards
    
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
                    // Widget appearance
                    NavigationLink(destination: WidgetAppearanceView()) {
                        HStack {
                            Image(systemName: "square.grid.2x2")
                                .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                                .frame(width: 24)
                            Text("Widget Appearance")
                                .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                        }
                    }
                } header: {
                    ThemedSectionHeader(text: "Widget", themeManager: themeManager)
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

                    // Intentions list display style
                    Picker(selection: $intentionListStyle) {
                        ForEach(IntentionListStyle.allCases) { style in
                            Text(style.displayName).tag(style)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "list.bullet.rectangle")
                                .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                                .frame(width: 24)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("List Style")
                                    .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                                Text(intentionListStyle.description)
                                    .font(.caption)
                                    .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                            }
                        }
                    }
                } header: {
                    ThemedSectionHeader(text: "Intentions", themeManager: themeManager)
                } footer: {
                    ThemedSectionFooter(text: "Choose how often you'd like to set new intentions and how your intentions list is displayed. This helps personalize your widget's placeholder text.", themeManager: themeManager)
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
                    let baseURL = APIClient.shared.baseURL
                    
                    if let privacyURL = URL(string: "https://nathanfennel.com/attunetion/privacy.html") {
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
                            Text("Delete Local Data")
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
            .alert("Delete Local Data", isPresented: $showDeleteDataAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    deleteAllData()
                }
            } message: {
                Text("This permanently deletes your intentions, custom themes, profile, feedback, and preferences from this device, and clears its widgets and reminders. Bundled themes remain. This cannot be undone and does not delete copies on other devices or information previously sent to the suggestion service.")
            }
            .alert("Could Not Delete Data", isPresented: Binding(
                get: { deletionError != nil },
                set: { if !$0 { deletionError = nil } }
            )) {
                Button("OK", role: .cancel) { deletionError = nil }
            } message: {
                Text(deletionError ?? "Please try again.")
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
        do {
            try LocalUserDataDeletion.delete(from: modelContext)

            // Clear secondary copies only after the database commit succeeds.
            LocalUserDataDeletion.clearPreferences(
                standard: .standard,
                widgets: UserDefaults(suiteName: "group.com.nathanfennel.Attunetion")
            )
            let notifications = UNUserNotificationCenter.current()
            notifications.removeAllPendingNotificationRequests()
            notifications.removeAllDeliveredNotifications()
            #if canImport(WidgetKit)
            WidgetCenter.shared.reloadAllTimelines()
            #endif

            themeManager.currentTheme = .ocean
            defaultTheme = nil
            defaultFont = nil
            intentionListStyle = .cards
        } catch {
            deletionError = "Your local data could not be deleted. Please try again. \(error.localizedDescription)"
        }
    }

}


/// Keep the deletion in one save so a failure cannot leave a partially erased library.
@MainActor
enum LocalUserDataDeletion {
    static func delete(from sourceContext: ModelContext) throws {
        // Include pending edits, then isolate failed deletions from the live UI context.
        if sourceContext.hasChanges { try sourceContext.save() }
        let context = ModelContext(sourceContext.container)
        context.autosaveEnabled = false
        do {
            let intentions = try context.fetch(FetchDescriptor<Intention>())
            let profiles = try context.fetch(FetchDescriptor<UserProfile>())
            let preferences = try context.fetch(FetchDescriptor<UserPreferences>())
            let feedback = try context.fetch(FetchDescriptor<IntentionFeedback>())
            let customThemes = try context.fetch(FetchDescriptor<IntentionTheme>(
                predicate: #Predicate { !$0.isPreset }
            ))

            for intention in intentions { context.delete(intention) }
            for profile in profiles { context.delete(profile) }
            for preference in preferences { context.delete(preference) }
            for response in feedback { context.delete(response) }
            for theme in customThemes { context.delete(theme) }
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }

    static func clearPreferences(standard: UserDefaults, widgets: UserDefaults?) {
        for key in ["hasSeenOnboarding", "intentionListStyle"] {
            standard.removeObject(forKey: key)
        }
        for key in ["currentIntentionData", "currentThemeData", "defaultIntentionFrequency",
                    "widgetUserState", "widgetThemePreference"] {
            widgets?.removeObject(forKey: key)
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

