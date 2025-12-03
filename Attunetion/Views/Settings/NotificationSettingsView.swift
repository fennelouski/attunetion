//
//  NotificationSettingsView.swift
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

/// View for configuring notification settings with user-friendly controls
struct NotificationSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager: AppThemeManager
    @Query private var preferencesQuery: [UserPreferences]
    
    // Frequency control
    @State private var frequency: NotificationFrequency = .daily
    
    // Notification types
    @State private var reminderToAddEnabled = true
    @State private var reminderOfIntentionEnabled = false
    @State private var encouragementEnabled = false
    @State private var timeOfDayEnabled = false
    
    // Times
    @State private var morningTime = Date()
    @State private var eveningTime = Date()
    
    // Blackout settings
    @State private var blackoutEnabled = true
    @State private var blackoutStartHour = 22
    @State private var blackoutStartMinute = 0
    @State private var blackoutEndHour = 8
    @State private var blackoutEndMinute = 0
    @State private var blackoutDays: Set<Int> = []
    
    // Permission
    @State private var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @State private var isRequestingPermission = false
    @State private var showPermissionAlert = false
    
    private var preferences: UserPreferences? {
        preferencesQuery.first
    }
    
    private var preferencesRepository: UserPreferencesRepository {
        UserPreferencesRepository(modelContext: modelContext)
    }
    
    var body: some View {
        ZStack {
            AppBackground(themeManager: themeManager)
            
            Form {
                // Permission Section
                permissionSection
                
                // Frequency Slider Section
                frequencySection
                
                // Notification Types Section
                notificationTypesSection
                
                // Time Settings Section (shown when time-based is enabled)
                if timeOfDayEnabled || frequency == .twiceDaily {
                    timeSettingsSection
                }
                
                // Quiet Hours Section
                quietHoursSection
                
                // Test Section
                testSection
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Reminders")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onAppear {
            loadSettings()
            Task {
                await checkAuthorizationStatus()
            }
        }
        .onChange(of: frequency) { _, _ in
            saveAndReschedule()
        }
        .onChange(of: reminderToAddEnabled) { _, _ in
            saveAndReschedule()
        }
        .onChange(of: reminderOfIntentionEnabled) { _, _ in
            saveAndReschedule()
        }
        .onChange(of: encouragementEnabled) { _, _ in
            saveAndReschedule()
        }
        .onChange(of: timeOfDayEnabled) { _, _ in
            saveAndReschedule()
        }
        .onChange(of: morningTime) { _, _ in
            saveAndReschedule()
        }
        .onChange(of: eveningTime) { _, _ in
            saveAndReschedule()
        }
        .onChange(of: blackoutEnabled) { _, _ in
            saveAndReschedule()
        }
        .onChange(of: blackoutStartHour) { _, _ in
            saveAndReschedule()
        }
        .onChange(of: blackoutStartMinute) { _, _ in
            saveAndReschedule()
        }
        .onChange(of: blackoutEndHour) { _, _ in
            saveAndReschedule()
        }
        .onChange(of: blackoutEndMinute) { _, _ in
            saveAndReschedule()
        }
        .onChange(of: blackoutDays) { _, _ in
            saveAndReschedule()
        }
        .alert("Enable Notifications", isPresented: $showPermissionAlert) {
            Button("Open Settings") {
                openSettings()
            }
            Button("Maybe Later", role: .cancel) {}
        } message: {
            Text("To receive reminders, please enable notifications in your device settings.")
        }
    }
    
    // MARK: - Sections
    
    private var permissionSection: some View {
        Section {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Notifications")
                        .font(.system(size: 17, weight: .semibold, design: .default))
                        .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                    Text(permissionStatusText)
                        .font(.system(size: 13, weight: .regular, design: .default))
                        .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                }
                Spacer()
                statusBadge
            }
            
            if authorizationStatus != .authorized {
                PrimaryButton("Enable Notifications", themeManager: themeManager) {
                    Task {
                        await requestPermission()
                    }
                }
                .disabled(isRequestingPermission)
            }
        } header: {
            ThemedSectionHeader(text: "Notifications", themeManager: themeManager)
        } footer: {
            if authorizationStatus != .authorized {
                ThemedSectionFooter(text: "We'll only send you reminders you choose. You can change these settings anytime.", themeManager: themeManager)
            }
        }
    }
    
    private var frequencySection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("How often?")
                        .font(.system(size: 17, weight: .semibold, design: .default))
                        .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                    Spacer()
                    Text(frequency.displayName)
                        .font(.system(size: 15, weight: .regular, design: .default))
                        .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                }
                
                VStack(spacing: 8) {
                    Slider(
                        value: Binding(
                            get: { Double(frequency.rawValue) },
                            set: { frequency = NotificationFrequency(rawValue: Int($0)) ?? .daily }
                        ),
                        in: 0...6,
                        step: 1
                    )
                    .tint(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                    
                    Text(frequency.description)
                        .font(.system(size: 12, weight: .regular, design: .default))
                        .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.vertical, 4)
        } header: {
            ThemedSectionHeader(text: "Reminder Frequency", themeManager: themeManager)
        } footer: {
            ThemedSectionFooter(text: "Choose how often you'd like to be reminded. You can always adjust this later.", themeManager: themeManager)
        }
    }
    
    private var notificationTypesSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 16) {
                Text("What would you like reminders for?")
                    .font(.system(size: 17, weight: .semibold, design: .default))
                    .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                    .padding(.bottom, 4)
                
                NotificationTypeToggle(
                    title: NotificationType.reminderToAdd.displayName,
                    description: NotificationType.reminderToAdd.description,
                    isEnabled: $reminderToAddEnabled,
                    icon: "bell.fill",
                    themeManager: themeManager
                )
                
                NotificationTypeToggle(
                    title: NotificationType.reminderOfIntention.displayName,
                    description: NotificationType.reminderOfIntention.description,
                    isEnabled: $reminderOfIntentionEnabled,
                    icon: "eye.fill",
                    themeManager: themeManager
                )
                
                NotificationTypeToggle(
                    title: NotificationType.encouragement.displayName,
                    description: NotificationType.encouragement.description,
                    isEnabled: $encouragementEnabled,
                    icon: "heart.fill",
                    themeManager: themeManager
                )
                
                NotificationTypeToggle(
                    title: NotificationType.timeOfDay.displayName,
                    description: NotificationType.timeOfDay.description,
                    isEnabled: $timeOfDayEnabled,
                    icon: "clock.fill",
                    themeManager: themeManager
                )
            }
            .padding(.vertical, 4)
        } header: {
            ThemedSectionHeader(text: "Reminder Types", themeManager: themeManager)
        } footer: {
            ThemedSectionFooter(text: "Select the types of reminders that would be helpful for you.", themeManager: themeManager)
        }
    }
    
    private var timeSettingsSection: some View {
        Section {
            if frequency == .twiceDaily || timeOfDayEnabled {
                VStack(alignment: .leading, spacing: 12) {
                    Text("When would you like reminders?")
                        .font(.system(size: 17, weight: .semibold, design: .default))
                        .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                    
                    if frequency == .twiceDaily || timeOfDayEnabled {
                        DatePicker(
                            "Morning",
                            selection: $morningTime,
                            displayedComponents: .hourAndMinute
                        )
                        .tint(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                        
                        DatePicker(
                            "Evening",
                            selection: $eveningTime,
                            displayedComponents: .hourAndMinute
                        )
                        .tint(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                    } else {
                        DatePicker(
                            "Preferred time",
                            selection: $morningTime,
                            displayedComponents: .hourAndMinute
                        )
                        .tint(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                    }
                }
                .padding(.vertical, 4)
            }
        } header: {
            ThemedSectionHeader(text: "Timing", themeManager: themeManager)
        } footer: {
            ThemedSectionFooter(text: "Choose times that work best for you. We'll respect your quiet hours.", themeManager: themeManager)
        }
    }
    
    private var quietHoursSection: some View {
        Section {
            Toggle("Quiet hours", isOn: $blackoutEnabled)
                .tint(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
            
            if blackoutEnabled {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Don't send reminders between:")
                        .font(.system(size: 15, weight: .regular, design: .default))
                        .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                    
                    HStack {
                        Text("From")
                            .font(.system(size: 15, weight: .regular, design: .default))
                            .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                        Spacer()
                        Picker("Start hour", selection: $blackoutStartHour) {
                            ForEach(0..<24) { hour in
                                Text(formatHour(hour)).tag(hour)
                            }
                        }
                        .tint(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                        Picker("Start minute", selection: $blackoutStartMinute) {
                            ForEach([0, 15, 30, 45], id: \.self) { minute in
                                Text("\(minute)").tag(minute)
                            }
                        }
                        .tint(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                    }
                    
                    HStack {
                        Text("Until")
                            .font(.system(size: 15, weight: .regular, design: .default))
                            .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                        Spacer()
                        Picker("End hour", selection: $blackoutEndHour) {
                            ForEach(0..<24) { hour in
                                Text(formatHour(hour)).tag(hour)
                            }
                        }
                        .tint(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                        Picker("End minute", selection: $blackoutEndMinute) {
                            ForEach([0, 15, 30, 45], id: \.self) { minute in
                                Text("\(minute)").tag(minute)
                            }
                        }
                        .tint(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                    }
                    
                    Text("Skip reminders on:")
                        .font(.system(size: 15, weight: .regular, design: .default))
                        .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                        .padding(.top, 8)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                        ForEach(0..<7) { dayIndex in
                            DayToggleButton(
                                dayIndex: dayIndex,
                                isSelected: blackoutDays.contains(dayIndex),
                                themeManager: themeManager
                            ) {
                                #if os(iOS)
                                HapticFeedback.light()
                                #endif
                                if blackoutDays.contains(dayIndex) {
                                    blackoutDays.remove(dayIndex)
                                } else {
                                    blackoutDays.insert(dayIndex)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        } header: {
            ThemedSectionHeader(text: "Quiet Hours", themeManager: themeManager)
        } footer: {
            ThemedSectionFooter(text: "Set times and days when you don't want to receive reminders.", themeManager: themeManager)
        }
    }
    
    private var testSection: some View {
        Section {
            SecondaryButton("Send a test reminder", themeManager: themeManager) {
                #if os(iOS)
                HapticFeedback.medium()
                #endif
                Task {
                    await NotificationManager.shared.sendTestNotification()
                }
            }
        } header: {
            ThemedSectionHeader(text: "Testing", themeManager: themeManager)
        } footer: {
            ThemedSectionFooter(text: "Try it out! You'll receive a test reminder in a few seconds.", themeManager: themeManager)
        }
    }
    
    // MARK: - Views
    
    @ViewBuilder
    private var statusBadge: some View {
        switch authorizationStatus {
        case .authorized:
            Label("Enabled", systemImage: "checkmark.circle.fill")
                .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                .font(.system(size: 12, weight: .medium, design: .default))
        case .denied:
            Label("Disabled", systemImage: "xmark.circle.fill")
                .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                .font(.system(size: 12, weight: .medium, design: .default))
        case .notDetermined:
            Label("Not Set", systemImage: "questionmark.circle.fill")
                .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor().opacity(0.7))
                .font(.system(size: 12, weight: .medium, design: .default))
        default:
            Label("Unknown", systemImage: "questionmark.circle")
                .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                .font(.system(size: 12, weight: .medium, design: .default))
        }
    }
    
    private var permissionStatusText: String {
        switch authorizationStatus {
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
    
    private func loadSettings() {
        guard let prefs = preferences else {
            // Set defaults
            morningTime = defaultMorningTime()
            eveningTime = defaultEveningTime()
            return
        }
        
        let settings = prefs.notificationSettings
        
        frequency = settings.frequency
        reminderToAddEnabled = settings.enabledTypes.contains(.reminderToAdd)
        reminderOfIntentionEnabled = settings.enabledTypes.contains(.reminderOfIntention)
        encouragementEnabled = settings.enabledTypes.contains(.encouragement)
        timeOfDayEnabled = settings.enabledTypes.contains(.timeOfDay)
        
        morningTime = settings.morningTime ?? defaultMorningTime()
        eveningTime = settings.eveningTime ?? defaultEveningTime()
        
        blackoutEnabled = settings.blackoutEnabled
        blackoutStartHour = settings.blackoutTime.startHour
        blackoutStartMinute = settings.blackoutTime.startMinute
        blackoutEndHour = settings.blackoutTime.endHour
        blackoutEndMinute = settings.blackoutTime.endMinute
        blackoutDays = settings.blackoutDays
    }
    
    private func saveAndReschedule() {
        var enabledTypes: Set<NotificationType> = []
        if reminderToAddEnabled { enabledTypes.insert(.reminderToAdd) }
        if reminderOfIntentionEnabled { enabledTypes.insert(.reminderOfIntention) }
        if encouragementEnabled { enabledTypes.insert(.encouragement) }
        if timeOfDayEnabled { enabledTypes.insert(.timeOfDay) }
        
        let blackoutTime = BlackoutTime(
            startHour: blackoutStartHour,
            startMinute: blackoutStartMinute,
            endHour: blackoutEndHour,
            endMinute: blackoutEndMinute
        )
        
        let settings = NotificationSettings(
            frequency: frequency,
            enabledTypes: enabledTypes,
            morningTime: (frequency == .twiceDaily || timeOfDayEnabled) ? morningTime : nil,
            eveningTime: (frequency == .twiceDaily || timeOfDayEnabled) ? eveningTime : nil,
            blackoutEnabled: blackoutEnabled,
            blackoutTime: blackoutTime,
            blackoutDays: blackoutDays
        )
        
        do {
            try preferencesRepository.updateNotificationSettings(settings)
        } catch {
            print("Failed to save notification settings: \(error)")
        }
        
        // Reschedule notifications
        Task {
            await NotificationManager.shared.scheduleAllNotifications(settings: settings)
        }
    }
    
    private func requestPermission() async {
        isRequestingPermission = true
        defer { isRequestingPermission = false }
        
        let granted = await NotificationManager.shared.requestAuthorization()
        
        if !granted {
            showPermissionAlert = true
        }
        
        await checkAuthorizationStatus()
    }
    
    private func checkAuthorizationStatus() async {
        authorizationStatus = await NotificationManager.shared.getNotificationStatus()
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
    
    private func formatHour(_ hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        let date = Calendar.current.date(bySettingHour: hour % 24, minute: 0, second: 0, of: Date()) ?? Date()
        return formatter.string(from: date)
    }
    
    private func defaultMorningTime() -> Date {
        Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
    }
    
    private func defaultEveningTime() -> Date {
        Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date()
    }
}

// MARK: - Supporting Views

struct NotificationTypeToggle: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let description: String
    @Binding var isEnabled: Bool
    let icon: String
    @ObservedObject var themeManager: AppThemeManager
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(
                    isEnabled
                        ? themeManager.accentColor(for: colorScheme).toSwiftUIColor()
                        : themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor()
                )
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .medium, design: .default))
                    .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                Text(description)
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
            }
            
            Spacer()
            
            Toggle("", isOn: $isEnabled)
                .labelsHidden()
                .tint(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
        }
        .padding(.vertical, 6)
    }
}

struct DayToggleButton: View {
    @Environment(\.colorScheme) var colorScheme
    let dayIndex: Int
    let isSelected: Bool
    @ObservedObject var themeManager: AppThemeManager
    let action: () -> Void
    
    private var dayName: String {
        let days = ["S", "M", "T", "W", "T", "F", "S"]
        return days[dayIndex]
    }
    
    var body: some View {
        Button(action: action) {
            Text(dayName)
                .font(.system(size: 13, weight: .semibold, design: .default))
                .foregroundColor(
                    isSelected
                        ? themeManager.buttonTextColor(for: colorScheme).toSwiftUIColor()
                        : themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor()
                )
                .frame(width: 36, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(
                            isSelected
                                ? themeManager.buttonBackgroundColor(for: colorScheme).toSwiftUIColor()
                                : (colorScheme == .dark
                                    ? themeManager.currentTheme.darkSecondaryButtonBackground.toSwiftUIColor().opacity(0.4)
                                    : Color.white.opacity(0.5))
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(
                            themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor().opacity(isSelected ? 0 : 0.1),
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
    }
}
