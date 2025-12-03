//
//  NotificationManager.swift
//  Attunetion
//
//  Created for notification permission requests
//

import Foundation
import UserNotifications

/// Manages notification permissions and scheduling
@MainActor
class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    /// Request notification authorization from the user
    func requestAuthorization() async -> Bool {
        do {
            #if os(watchOS)
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound]
            )
            #else
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            #endif
            return granted
        } catch {
            print("Error requesting notification authorization: \(error)")
            return false
        }
    }
    
    /// Check current authorization status
    func getAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }
    
    /// Get notification status (alias for getAuthorizationStatus for compatibility)
    func getNotificationStatus() async -> UNAuthorizationStatus {
        return await getAuthorizationStatus()
    }
    
    /// Schedule all notifications based on user settings
    func scheduleAllNotifications(settings: NotificationSettings) async {
        // Cancel all existing notifications first
        await cancelAllNotifications()
        
        // If no notification types are enabled, don't schedule anything
        guard !settings.enabledTypes.isEmpty else {
            return
        }
        
        // Schedule based on frequency
        switch settings.frequency {
        case .oncePerMonth:
            await scheduleMonthlyReminders(settings: settings)
        case .twicePerMonth:
            await scheduleBiMonthlyReminders(settings: settings)
        case .oncePerWeek:
            await scheduleWeeklyReminders(settings: settings)
        case .twicePerWeek:
            await scheduleBiWeeklyReminders(settings: settings)
        case .everyOtherDay:
            await scheduleEveryOtherDayReminders(settings: settings)
        case .daily:
            await scheduleDailyReminders(settings: settings)
        case .twiceDaily:
            await scheduleTwiceDailyReminders(settings: settings)
        }
        
        // Also handle legacy settings for backward compatibility
        if settings.dailyEnabled, let time = settings.dailyTime {
            await scheduleDailyNotification(time: time)
        }
        if settings.weeklyEnabled, let time = settings.weeklyTime {
            await scheduleWeeklyNotification(day: settings.weeklyDay, time: time)
        }
        if settings.monthlyEnabled, let time = settings.monthlyTime {
            await scheduleMonthlyNotification(day: settings.monthlyDay, time: time)
        }
    }
    
    // MARK: - Frequency-Based Scheduling
    
    private func scheduleMonthlyReminders(settings: NotificationSettings) async {
        // Schedule for the 1st of each month
        let calendar = Calendar.current
        let morningTime = settings.morningTime ?? defaultMorningTime()
        let components = calendar.dateComponents([.hour, .minute], from: morningTime)
        
        var dateComponents = DateComponents()
        dateComponents.day = 1
        dateComponents.hour = components.hour
        dateComponents.minute = components.minute
        
        await scheduleNotification(
            identifier: "monthly-reminder",
            title: getNotificationTitle(for: settings.enabledTypes),
            body: getNotificationBody(for: settings.enabledTypes, frequency: .oncePerMonth),
            dateComponents: dateComponents,
            settings: settings
        )
    }
    
    private func scheduleBiMonthlyReminders(settings: NotificationSettings) async {
        // Schedule for 1st and 15th of each month
        let calendar = Calendar.current
        let morningTime = settings.morningTime ?? defaultMorningTime()
        let components = calendar.dateComponents([.hour, .minute], from: morningTime)
        
        for day in [1, 15] {
            var dateComponents = DateComponents()
            dateComponents.day = day
            dateComponents.hour = components.hour
            dateComponents.minute = components.minute
            
            await scheduleNotification(
                identifier: "bi-monthly-reminder-\(day)",
                title: getNotificationTitle(for: settings.enabledTypes),
                body: getNotificationBody(for: settings.enabledTypes, frequency: .twicePerMonth),
                dateComponents: dateComponents,
                settings: settings
            )
        }
    }
    
    private func scheduleWeeklyReminders(settings: NotificationSettings) async {
        // Schedule for Sunday of each week
        let calendar = Calendar.current
        let morningTime = settings.morningTime ?? defaultMorningTime()
        let components = calendar.dateComponents([.hour, .minute], from: morningTime)
        
        var dateComponents = DateComponents()
        dateComponents.weekday = 1 // Sunday
        dateComponents.hour = components.hour
        dateComponents.minute = components.minute
        
        await scheduleNotification(
            identifier: "weekly-reminder",
            title: getNotificationTitle(for: settings.enabledTypes),
            body: getNotificationBody(for: settings.enabledTypes, frequency: .oncePerWeek),
            dateComponents: dateComponents,
            settings: settings
        )
    }
    
    private func scheduleBiWeeklyReminders(settings: NotificationSettings) async {
        // Schedule for Sunday and Wednesday
        let calendar = Calendar.current
        let morningTime = settings.morningTime ?? defaultMorningTime()
        let components = calendar.dateComponents([.hour, .minute], from: morningTime)
        
        for weekday in [1, 4] { // Sunday and Wednesday
            var dateComponents = DateComponents()
            dateComponents.weekday = weekday
            dateComponents.hour = components.hour
            dateComponents.minute = components.minute
            
            await scheduleNotification(
                identifier: "bi-weekly-reminder-\(weekday)",
                title: getNotificationTitle(for: settings.enabledTypes),
                body: getNotificationBody(for: settings.enabledTypes, frequency: .twicePerWeek),
                dateComponents: dateComponents,
                settings: settings
            )
        }
    }
    
    private func scheduleEveryOtherDayReminders(settings: NotificationSettings) async {
        // Schedule for every other day starting from today
        let calendar = Calendar.current
        let morningTime = settings.morningTime ?? defaultMorningTime()
        let components = calendar.dateComponents([.hour, .minute], from: morningTime)
        
        // Schedule for even days (2nd, 4th, 6th, etc.)
        for day in stride(from: 2, through: 28, by: 2) {
            var dateComponents = DateComponents()
            dateComponents.day = day
            dateComponents.hour = components.hour
            dateComponents.minute = components.minute
            
            await scheduleNotification(
                identifier: "every-other-day-reminder-\(day)",
                title: getNotificationTitle(for: settings.enabledTypes),
                body: getNotificationBody(for: settings.enabledTypes, frequency: .everyOtherDay),
                dateComponents: dateComponents,
                settings: settings
            )
        }
    }
    
    private func scheduleDailyReminders(settings: NotificationSettings) async {
        let calendar = Calendar.current
        let morningTime = settings.morningTime ?? defaultMorningTime()
        let components = calendar.dateComponents([.hour, .minute], from: morningTime)
        
        var dateComponents = DateComponents()
        dateComponents.hour = components.hour
        dateComponents.minute = components.minute
        
        await scheduleNotification(
            identifier: "daily-reminder",
            title: getNotificationTitle(for: settings.enabledTypes),
            body: getNotificationBody(for: settings.enabledTypes, frequency: .daily),
            dateComponents: dateComponents,
            settings: settings
        )
    }
    
    private func scheduleTwiceDailyReminders(settings: NotificationSettings) async {
        let calendar = Calendar.current
        let morningTime = settings.morningTime ?? defaultMorningTime()
        let eveningTime = settings.eveningTime ?? defaultEveningTime()
        
        let morningComponents = calendar.dateComponents([.hour, .minute], from: morningTime)
        let eveningComponents = calendar.dateComponents([.hour, .minute], from: eveningTime)
        
        // Morning reminder
        var morningDateComponents = DateComponents()
        morningDateComponents.hour = morningComponents.hour
        morningDateComponents.minute = morningComponents.minute
        
        await scheduleNotification(
            identifier: "twice-daily-morning",
            title: getNotificationTitle(for: settings.enabledTypes, isMorning: true),
            body: getNotificationBody(for: settings.enabledTypes, frequency: .twiceDaily, isMorning: true),
            dateComponents: morningDateComponents,
            settings: settings
        )
        
        // Evening reminder
        var eveningDateComponents = DateComponents()
        eveningDateComponents.hour = eveningComponents.hour
        eveningDateComponents.minute = eveningComponents.minute
        
        await scheduleNotification(
            identifier: "twice-daily-evening",
            title: getNotificationTitle(for: settings.enabledTypes, isMorning: false),
            body: getNotificationBody(for: settings.enabledTypes, frequency: .twiceDaily, isMorning: false),
            dateComponents: eveningDateComponents,
            settings: settings
        )
    }
    
    // MARK: - Helper Methods
    
    private func scheduleNotification(
        identifier: String,
        title: String,
        body: String,
        dateComponents: DateComponents,
        settings: NotificationSettings
    ) async {
        // Check if this time falls within blackout period
        if settings.blackoutEnabled {
            if isInBlackoutPeriod(dateComponents: dateComponents, settings: settings) {
                return
            }
        }
        
        // Check if this day is in blackout days
        if let weekday = dateComponents.weekday, settings.blackoutDays.contains(weekday - 1) {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        // Determine category based on enabled types
        if settings.enabledTypes.contains(.reminderToAdd) {
            content.categoryIdentifier = "DAILY_INTENTION"
        } else {
            content.categoryIdentifier = "GENERAL_REMINDER"
        }
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Error scheduling notification \(identifier): \(error)")
        }
    }
    
    private func isInBlackoutPeriod(dateComponents: DateComponents, settings: NotificationSettings) -> Bool {
        guard let hour = dateComponents.hour, let minute = dateComponents.minute else {
            return false
        }
        
        let notificationMinutes = hour * 60 + minute
        let blackoutStartMinutes = settings.blackoutTime.startHour * 60 + settings.blackoutTime.startMinute
        let blackoutEndMinutes = settings.blackoutTime.endHour * 60 + settings.blackoutTime.endMinute
        
        // Handle blackout that spans midnight
        if blackoutStartMinutes > blackoutEndMinutes {
            return notificationMinutes >= blackoutStartMinutes || notificationMinutes < blackoutEndMinutes
        } else {
            return notificationMinutes >= blackoutStartMinutes && notificationMinutes < blackoutEndMinutes
        }
    }
    
    private func getNotificationTitle(for types: Set<NotificationType>, isMorning: Bool = true) -> String {
        if types.contains(.reminderToAdd) {
            return isMorning ? "Time to set your intention" : "Evening check-in"
        } else if types.contains(.reminderOfIntention) {
            return "Your intention for today"
        } else if types.contains(.encouragement) {
            return "A little encouragement"
        } else {
            return "Daily reminder"
        }
    }
    
    private func getNotificationBody(for types: Set<NotificationType>, frequency: NotificationFrequency, isMorning: Bool = true) -> String {
        var messages: [String] = []
        
        if types.contains(.reminderToAdd) {
            if frequency == .twiceDaily {
                messages.append(isMorning ? "What's your intention for today?" : "How did today go?")
            } else {
                messages.append("What do you want to focus on?")
            }
        }
        
        if types.contains(.reminderOfIntention) {
            messages.append("Remember your intention for today")
        }
        
        if types.contains(.encouragement) {
            let encouragements = [
                "You've got this!",
                "Keep going!",
                "You're doing great!",
                "Stay focused on what matters"
            ]
            messages.append(encouragements.randomElement() ?? "Keep it up!")
        }
        
        return messages.joined(separator: " • ")
    }
    
    private func defaultMorningTime() -> Date {
        Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
    }
    
    private func defaultEveningTime() -> Date {
        Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date()
    }
    
    /// Schedule daily notification
    func scheduleDailyNotification(time: Date) async {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        let content = UNMutableNotificationContent()
        content.title = "Set Your Daily Intention"
        content.body = "What's your intention for today?"
        content.sound = .default
        content.categoryIdentifier = "DAILY_INTENTION"
        
        var dateComponents = DateComponents()
        dateComponents.hour = components.hour
        dateComponents.minute = components.minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily-intention-reminder", content: content, trigger: trigger)
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Error scheduling daily notification: \(error)")
        }
    }
    
    /// Schedule weekly notification
    func scheduleWeeklyNotification(day: Int, time: Date) async {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        let content = UNMutableNotificationContent()
        content.title = "Set Your Weekly Intention"
        content.body = "What's your intention for this week?"
        content.sound = .default
        content.categoryIdentifier = "WEEKLY_INTENTION"
        
        var dateComponents = DateComponents()
        dateComponents.weekday = day + 1 // UNCalendarNotificationTrigger uses 1-7 (Sunday=1)
        dateComponents.hour = components.hour
        dateComponents.minute = components.minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "weekly-intention-reminder", content: content, trigger: trigger)
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Error scheduling weekly notification: \(error)")
        }
    }
    
    /// Schedule monthly notification
    func scheduleMonthlyNotification(day: Int, time: Date) async {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        let content = UNMutableNotificationContent()
        content.title = "Set Your Monthly Intention"
        content.body = "What's your intention for this month?"
        content.sound = .default
        content.categoryIdentifier = "MONTHLY_INTENTION"
        
        var dateComponents = DateComponents()
        dateComponents.day = min(day, 28) // Use 28 to avoid issues with months that don't have 29-31 days
        dateComponents.hour = components.hour
        dateComponents.minute = components.minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "monthly-intention-reminder", content: content, trigger: trigger)
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Error scheduling monthly notification: \(error)")
        }
    }
    
    /// Cancel all notifications
    func cancelAllNotifications() async {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    /// Cancel daily notifications
    func cancelDailyNotifications() async {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily-intention-reminder"])
    }
    
    /// Cancel weekly notifications
    func cancelWeeklyNotifications() async {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["weekly-intention-reminder"])
    }
    
    /// Cancel monthly notifications
    func cancelMonthlyNotifications() async {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["monthly-intention-reminder"])
    }
    
    /// Send a test notification
    func sendTestNotification() async {
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "This is a test notification from Attunetion."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "test-notification-\(UUID().uuidString)", content: content, trigger: trigger)
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Error sending test notification: \(error)")
        }
    }
    
    /// Setup notification categories with actions
    func setupNotificationCategories() async {
        // Daily intention category
        let dailySetAction = UNTextInputNotificationAction(
            identifier: "SET_INTENTION_ACTION",
            title: "Set Intention",
            options: [],
            textInputButtonTitle: "Set",
            textInputPlaceholder: "Enter your intention..."
        )
        let dailySkipAction = UNNotificationAction(
            identifier: "SKIP_ACTION",
            title: "Skip",
            options: []
        )
        let dailyCategory = UNNotificationCategory(
            identifier: "DAILY_INTENTION",
            actions: [dailySetAction, dailySkipAction],
            intentIdentifiers: [],
            options: []
        )
        
        // Weekly intention category
        let weeklySetAction = UNTextInputNotificationAction(
            identifier: "SET_INTENTION_ACTION",
            title: "Set Intention",
            options: [],
            textInputButtonTitle: "Set",
            textInputPlaceholder: "Enter your intention..."
        )
        let weeklySkipAction = UNNotificationAction(
            identifier: "SKIP_ACTION",
            title: "Skip",
            options: []
        )
        let weeklyCategory = UNNotificationCategory(
            identifier: "WEEKLY_INTENTION",
            actions: [weeklySetAction, weeklySkipAction],
            intentIdentifiers: [],
            options: []
        )
        
        // Monthly intention category
        let monthlySetAction = UNTextInputNotificationAction(
            identifier: "SET_INTENTION_ACTION",
            title: "Set Intention",
            options: [],
            textInputButtonTitle: "Set",
            textInputPlaceholder: "Enter your intention..."
        )
        let monthlySkipAction = UNNotificationAction(
            identifier: "SKIP_ACTION",
            title: "Skip",
            options: []
        )
        let monthlyCategory = UNNotificationCategory(
            identifier: "MONTHLY_INTENTION",
            actions: [monthlySetAction, monthlySkipAction],
            intentIdentifiers: [],
            options: []
        )
        
        let center = UNUserNotificationCenter.current()
        center.setNotificationCategories([dailyCategory, weeklyCategory, monthlyCategory])
    }
}
