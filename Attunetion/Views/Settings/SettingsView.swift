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
    @Query private var intentionThemes: [IntentionTheme]
    @State private var preferenceSaveError: String?
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
    
    private var defaultTheme: IntentionTheme? {
        guard let id = preferences?.defaultThemeId else { return nil }
        return intentionThemes.first { $0.id == id }
    }

    private var defaultFont: String? { preferences?.defaultFont }

    private var defaultThemeBinding: Binding<IntentionTheme?> {
        Binding(get: { defaultTheme }, set: { saveDefaultTheme($0) })
    }

    private var defaultFontBinding: Binding<String?> {
        Binding(get: { defaultFont }, set: { saveDefaultFont($0) })
    }

    private var notificationSettings: NotificationSettings {
        preferences?.notificationSettings ?? NotificationSettings()
    }
    
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var selectedSection: SettingsSection = .appearance
    @State private var showsCompactDetail = false

    var body: some View {
        adaptiveLayout(compactDetail: false)
            .navigationDestination(isPresented: $showsCompactDetail) {
                adaptiveLayout(compactDetail: true)
            }
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
    }

    private func adaptiveLayout(compactDetail: Bool) -> some View {
        GeometryReader { geometry in
            let isWide = geometry.size.width >= (dynamicTypeSize.isAccessibilitySize ? 1040 : 760)
            ZStack {
                AppBackground(themeManager: themeManager)
                Group {
                    if isWide {
                        HStack(spacing: 0) {
                            sectionSidebar
                                .frame(width: dynamicTypeSize.isAccessibilitySize ? 460 : 280)
                            Divider()
                            sectionForm
                                .frame(maxWidth: 740)
                                .frame(maxWidth: .infinity)
                        }
                    } else if compactDetail {
                        sectionForm
                    } else {
                        sectionHub
                    }
                }
            }
            .navigationTitle(compactDetail && !isWide ? selectedSection.title : String(localized: "Settings"))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .onChange(of: isWide) { oldValue, newValue in
                if !compactDetail && oldValue && !newValue { showsCompactDetail = true }
            }
        }
        .tint(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
            .sheet(isPresented: visiblePresentation($showingAbout, compactDetail: compactDetail)) {
                AboutView()
            }
            .sheet(isPresented: visiblePresentation($showingAppThemePicker, compactDetail: compactDetail)) {
                AppThemePickerView(themeManager: themeManager)
            }
            #if os(iOS)
            .fullScreenCover(isPresented: visiblePresentation($showingOnboarding, compactDetail: compactDetail)) {
                OnboardingContainerView {
                    showingOnboarding = false
                }
                .environment(\.modelContext, modelContext)
            }
            #else
            .sheet(isPresented: visiblePresentation($showingOnboarding, compactDetail: compactDetail)) {
                OnboardingContainerView {
                    showingOnboarding = false
                }
                .environment(\.modelContext, modelContext)
            }
            #endif
            .alert("Enable Notifications", isPresented: visiblePresentation($showPermissionAlert, compactDetail: compactDetail)) {
                Button("Open Settings") {
                    openSettings()
                }
                Button("Maybe Later", role: .cancel) {}
            } message: {
                Text("To receive reminders, please enable notifications in your device settings.")
            }
            .alert("Delete Local Data", isPresented: visiblePresentation($showDeleteDataAlert, compactDetail: compactDetail)) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    deleteAllData()
                }
            } message: {
                Text("This permanently deletes your intentions, custom themes, profile, feedback, and preferences from this device, and clears its widgets and reminders. Bundled themes remain. This cannot be undone and does not delete copies on other devices or information previously sent to the suggestion service.")
            }
            .alert("Could Not Save Preference", isPresented: visiblePresentation(Binding(
                get: { preferenceSaveError != nil },
                set: { if !$0 { preferenceSaveError = nil } }
            ), compactDetail: compactDetail)) {
                Button("OK", role: .cancel) { preferenceSaveError = nil }
            } message: {
                Text(preferenceSaveError ?? "Please try again.")
            }
            .alert("Could Not Delete Data", isPresented: visiblePresentation(Binding(
                get: { deletionError != nil },
                set: { if !$0 { deletionError = nil } }
            ), compactDetail: compactDetail)) {
                Button("OK", role: .cancel) { deletionError = nil }
            } message: {
                Text(deletionError ?? "Please try again.")
            }
    }

    private func visiblePresentation(_ isPresented: Binding<Bool>, compactDetail: Bool) -> Binding<Bool> {
        Binding(
            get: { compactDetail == showsCompactDetail && isPresented.wrappedValue },
            set: { if compactDetail == showsCompactDetail { isPresented.wrappedValue = $0 } }
        )
    }

    private var sectionSidebar: some View {
        List(selection: Binding<SettingsSection?>(
            get: { selectedSection },
            set: { if let section = $0 { selectedSection = section } }
        )) {
            ForEach(SettingsSection.allCases) { section in
                sectionLabel(section, isSelected: selectedSection == section)
                    .tag(section)
                    .accessibilityIdentifier("settings.section.\(section.rawValue)")
            }
        }
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
    }

    private var sectionHub: some View {
        List {
            Section {
                ForEach(SettingsSection.allCases) { section in
                    Button {
                        selectedSection = section
                        showsCompactDetail = true
                    } label: {
                        HStack {
                            sectionLabel(section)
                            Spacer(minLength: 12)
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                                .accessibilityHidden(true)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("settings.section.\(section.rawValue)")
                }
            } header: {
                Text("Attunetion").font(.title2)
            }
        }
        .scrollContentBackground(.hidden)
    }

    private func sectionLabel(_ section: SettingsSection, isSelected: Bool = false) -> some View {
        let selectedInk = Color(red: 0.10, green: 0.13, blue: 0.16)
        return Label {
            VStack(alignment: .leading, spacing: 4) {
                Text(section.title).font(.headline)
                    .foregroundStyle(isSelected ? selectedInk : Color.primary)
                Text(section.subtitle).font(.caption)
                    .foregroundStyle(isSelected ? selectedInk : Color.secondary)
            }
            .padding(.vertical, 6)
        } icon: {
            Image(systemName: section.symbol)
                .foregroundStyle(isSelected ? selectedInk : themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                .fixedSize()
                .accessibilityHidden(true)
        }
    }

    private var sectionForm: some View {
        Form {
            switch selectedSection {
            case .appearance: appearanceSections
            case .intentions: intentionsSection
            case .reminders:
                reminderSection
                if notificationAuthorizationStatus != .authorized { permissionsSection }
            case .suggestions: suggestionsSection
            case .aboutHelp: aboutHelpSections
            case .localData: localDataSection
            }
        }
        .formStyle(.grouped)
        .buttonStyle(.plain)
        .scrollContentBackground(.hidden)
        .accessibilityIdentifier("settings.detail.\(selectedSection.rawValue)")
        .tint(colorScheme == .light
              ? themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor()
              : themeManager.accentColor(for: colorScheme).toSwiftUIColor())
    }

    @ViewBuilder
    private var appearanceSections: some View {
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
            NavigationLink(destination: DefaultThemePickerView(selectedTheme: defaultThemeBinding)) {
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
            NavigationLink(destination: DefaultFontPickerView(selectedFont: defaultFontBinding)) {
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
                        .fixedSize()
                    Text("Widget Appearance")
                        .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                    Spacer()

                }
            }
        } header: {
            ThemedSectionHeader(text: "Widget", themeManager: themeManager)
        }
    }

    @ViewBuilder
    private var intentionsSection: some View {
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
                        .fixedSize()
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
                        .fixedSize()
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
    }

    @ViewBuilder
    private var reminderSection: some View {
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


                }
            }
        } header: {
            ThemedSectionHeader(text: "Notifications", themeManager: themeManager)
        } footer: {
            if notificationAuthorizationStatus == .authorized {
                ThemedSectionFooter(text: "Configure how often and what types of reminders you receive.", themeManager: themeManager)
            }
        }
    }

    @ViewBuilder
    private var suggestionsSection: some View {
        Section {
            NavigationLink(destination: UserProfileView(modelContext: modelContext)) {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                        .fixedSize()

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
    }

    @ViewBuilder
    private var aboutHelpSections: some View {
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
                        .fixedSize()

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
    }

    @ViewBuilder
    private var localDataSection: some View {
        Section {
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
                        .fixedSize()
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
            ThemedSectionHeader(text: "Local data", themeManager: themeManager)
        }
    }

    // MARK: - Permissions Section
    
    private var permissionsSection: some View {
        Section {
            // Notification permission row
            HStack {
                Image(systemName: "bell.fill")
                    .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                    .fixedSize()
                
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
                            .foregroundColor(colorScheme == .light
                                             ? themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor()
                                             : themeManager.accentColor(for: colorScheme).toSwiftUIColor())
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
    
    private func saveDefaultTheme(_ theme: IntentionTheme?) {
        let repository = UserPreferencesRepository(modelContext: modelContext)
        let existing = repository.getPreferences()
        let preferences = existing ?? UserPreferences()
        let creationContext = existing == nil ? ModelContext(modelContext.container) : nil
        creationContext?.autosaveEnabled = false
        let previous = preferences.defaultThemeId
        preferences.defaultThemeId = theme?.id
        do {
            if let creationContext {
                try UserPreferencesRepository(modelContext: creationContext).create(preferences)
            } else {
                try repository.update(preferences)
            }
        } catch {
            preferences.defaultThemeId = previous
            creationContext?.rollback()
            preferenceSaveError = "Your default theme could not be saved. Please try again. \(error.localizedDescription)"
        }
    }

    private func saveDefaultFont(_ font: String?) {
        let repository = UserPreferencesRepository(modelContext: modelContext)
        let existing = repository.getPreferences()
        let preferences = existing ?? UserPreferences()
        let creationContext = existing == nil ? ModelContext(modelContext.container) : nil
        creationContext?.autosaveEnabled = false
        let previous = preferences.defaultFont
        preferences.defaultFont = font
        do {
            if let creationContext {
                try UserPreferencesRepository(modelContext: creationContext).create(preferences)
            } else {
                try repository.update(preferences)
            }
        } catch {
            preferences.defaultFont = previous
            creationContext?.rollback()
            preferenceSaveError = "Your default font could not be saved. Please try again. \(error.localizedDescription)"
        }
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
            intentionListStyle = .cards
        } catch {
            deletionError = "Your local data could not be deleted. Please try again. \(error.localizedDescription)"
        }
    }

}


private enum SettingsSection: String, CaseIterable, Identifiable {
    case appearance, intentions, reminders, suggestions, aboutHelp, localData
    var id: Self { self }
    var title: String {
        switch self {
        case .appearance: return "Appearance"
        case .intentions: return "Intentions"
        case .reminders: return "Reminders"
        case .suggestions: return "Suggestions"
        case .aboutHelp: return "About & Help"
        case .localData: return "Local data"
        }
    }
    var subtitle: String {
        switch self {
        case .appearance: return "Themes, fonts & widgets"
        case .intentions: return "Frequency & list style"
        case .reminders: return "Schedule & permissions"
        case .suggestions: return "Personalized intentions"
        case .aboutHelp: return "Guides & legal"
        case .localData: return "Data on this device"
        }
    }
    var symbol: String {
        switch self {
        case .appearance: return "paintpalette"
        case .intentions: return "target"
        case .reminders: return "bell"
        case .suggestions: return "sparkles"
        case .aboutHelp: return "questionmark.circle"
        case .localData: return "externaldrive"
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
        for key in ["hasSeenOnboarding", "intentionListStyle", "openNewIntentionFromNotification",
                    "everyOtherDayReminderAnchor"] {
            standard.removeObject(forKey: key)
        }
        for key in ["currentIntentionData", "currentThemeData", "defaultIntentionFrequency",
                    "widgetUserState", "widgetThemePreference"] {
            widgets?.removeObject(forKey: key)
        }
    }
}


struct DefaultThemePickerView: View {
    @Binding var selectedTheme: IntentionTheme?
    @Query(filter: #Predicate<IntentionTheme> { $0.isPreset }, sort: \IntentionTheme.createdAt) private var presetThemes: [IntentionTheme]
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
            
            ForEach(presetThemes) { theme in
                Button(action: {
                    selectedTheme = theme
                    dismiss()
                }) {
                    HStack {
                        // Color swatch
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [theme.backgroundColorValue, theme.accentColorValue],
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
