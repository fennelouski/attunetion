//
//  NotificationSettingsView.swift
//  Daily Intentions
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI
import SwiftData
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// View for configuring notification settings
struct NotificationSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var preferencesQuery: [UserPreferences]
    
    @State private var dailyEnabled = false
    @State private var dailyTime = Date()
    
    @State private var weeklyEnabled = false
    @State private var weeklyDay = 0 // 0 = Sunday
    @State private var weeklyTime = Date()
    
    @State private var monthlyEnabled = false
    @State private var monthlyDay = 1 // 1-31
    @State private var monthlyTime = Date()
    
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
        Form {
            // Permission Status Section
            Section {
                HStack {
                    Text("Notification Permission")
                    Spacer()
                    statusBadge
                }
                
                if authorizationStatus != .authorized {
                    Button("Request Permission") {
                        Task {
                            await requestPermission()
                        }
                    }
                    .disabled(isRequestingPermission)
                }
            } header: {
                Text("Permission")
            } footer: {
                if authorizationStatus != .authorized {
                    Text("Enable notifications to receive reminders for setting intentions.")
                }
            }
            
            // Daily Reminder Section
            Section {
                NotificationToggleRow(
                    title: "Enable Daily Reminder",
                    isEnabled: $dailyEnabled
                )
                
                if dailyEnabled {
                    TimePickerRow(
                        title: "Time",
                        time: $dailyTime
                    )
                }
            } header: {
                Text("Daily Reminder")
            } footer: {
                Text("Get reminded each day to set your daily intention.")
            }
            
            // Weekly Reminder Section
            Section {
                NotificationToggleRow(
                    title: "Enable Weekly Reminder",
                    isEnabled: $weeklyEnabled
                )
                
                if weeklyEnabled {
                    Picker("Day", selection: $weeklyDay) {
                        ForEach(Weekday.allCases, id: \.rawValue) { day in
                            Text(day.displayName).tag(day.rawValue)
                        }
                    }
                    
                    TimePickerRow(
                        title: "Time",
                        time: $weeklyTime
                    )
                }
            } header: {
                Text("Weekly Reminder")
            } footer: {
                Text("Get reminded weekly to set your intention for the week.")
            }
            
            // Monthly Reminder Section
            Section {
                NotificationToggleRow(
                    title: "Enable Monthly Reminder",
                    isEnabled: $monthlyEnabled
                )
                
                if monthlyEnabled {
                    Stepper("Day of Month: \(monthlyDay)", value: $monthlyDay, in: 1...31)
                    
                    TimePickerRow(
                        title: "Time",
                        time: $monthlyTime
                    )
                }
            } header: {
                Text("Monthly Reminder")
            } footer: {
                Text("Get reminded monthly to set your intention for the month.")
            }
            
            // Test Notification Section
            Section {
                Button("Send Test Notification") {
                    Task {
                        await NotificationManager.shared.sendTestNotification()
                    }
                }
            } header: {
                Text("Testing")
            } footer: {
                Text("Send a test notification to verify your settings work correctly.")
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadSettings()
            Task {
                await checkAuthorizationStatus()
            }
        }
        .onChange(of: dailyEnabled) { _, _ in
            saveAndReschedule()
        }
        .onChange(of: dailyTime) { _, _ in
            saveAndReschedule()
        }
        .onChange(of: weeklyEnabled) { _, _ in
            saveAndReschedule()
        }
        .onChange(of: weeklyDay) { _, _ in
            saveAndReschedule()
        }
        .onChange(of: weeklyTime) { _, _ in
            saveAndReschedule()
        }
        .onChange(of: monthlyEnabled) { _, _ in
            saveAndReschedule()
        }
        .onChange(of: monthlyDay) { _, _ in
            saveAndReschedule()
        }
        .onChange(of: monthlyTime) { _, _ in
            saveAndReschedule()
        }
        .alert("Permission Required", isPresented: $showPermissionAlert) {
            Button("Open Settings") {
                #if os(iOS)
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
                #elseif os(macOS)
                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") {
                    NSWorkspace.shared.open(url)
                }
                #elseif os(watchOS)
                // watchOS doesn't have a direct way to open settings programmatically
                // User needs to go to Settings app manually
                #elseif os(visionOS)
                // visionOS uses the same settings URL as iOS
                if let url = URL(string: "app-settings:") {
                    // Note: visionOS may need different handling
                }
                #endif
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enable notifications in Settings to receive reminders.")
        }
    }
    
    // MARK: - Views
    
    @ViewBuilder
    private var statusBadge: some View {
        switch authorizationStatus {
        case .authorized:
            Label("Enabled", systemImage: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.caption)
        case .denied:
            Label("Denied", systemImage: "xmark.circle.fill")
                .foregroundColor(.red)
                .font(.caption)
        case .notDetermined:
            Label("Not Set", systemImage: "questionmark.circle.fill")
                .foregroundColor(.orange)
                .font(.caption)
        case .provisional:
            Label("Provisional", systemImage: "exclamationmark.circle.fill")
                .foregroundColor(.orange)
                .font(.caption)
        case .ephemeral:
            Label("Ephemeral", systemImage: "clock.fill")
                .foregroundColor(.blue)
                .font(.caption)
        @unknown default:
            Label("Unknown", systemImage: "questionmark.circle")
                .foregroundColor(.gray)
                .font(.caption)
        }
    }
    
    // MARK: - Methods
    
    private func loadSettings() {
        guard let prefs = preferences else { return }
        
        let settings = prefs.notificationSettings
        
        dailyEnabled = settings.dailyEnabled
        dailyTime = settings.dailyTime ?? defaultDailyTime()
        
        weeklyEnabled = settings.weeklyEnabled
        weeklyDay = settings.weeklyDay
        weeklyTime = settings.weeklyTime ?? defaultWeeklyTime()
        
        monthlyEnabled = settings.monthlyEnabled
        monthlyDay = settings.monthlyDay
        monthlyTime = settings.monthlyTime ?? defaultMonthlyTime()
    }
    
    private func saveAndReschedule() {
        // Save to preferences
        let settings = NotificationSettings(
            dailyEnabled: dailyEnabled,
            dailyTime: dailyEnabled ? dailyTime : nil,
            weeklyEnabled: weeklyEnabled,
            weeklyTime: weeklyEnabled ? weeklyTime : nil,
            weeklyDay: weeklyDay,
            monthlyEnabled: monthlyEnabled,
            monthlyTime: monthlyEnabled ? monthlyTime : nil,
            monthlyDay: monthlyDay
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
    
    // MARK: - Default Times
    
    private func defaultDailyTime() -> Date {
        Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
    }
    
    private func defaultWeeklyTime() -> Date {
        Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: Date()) ?? Date()
    }
    
    private func defaultMonthlyTime() -> Date {
        Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
    }
}

// MARK: - Weekday Enum

enum Weekday: Int, CaseIterable {
    case sunday = 0
    case monday = 1
    case tuesday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    case saturday = 6
    
    var displayName: String {
        switch self {
        case .sunday: return "Sunday"
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        }
    }
}

