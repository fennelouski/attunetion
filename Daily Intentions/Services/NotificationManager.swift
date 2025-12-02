//
//  NotificationManager.swift
//  Daily Intentions
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
        
        if settings.dailyEnabled, let time = settings.dailyTime {
            await scheduleDailyNotification(time: time)
        }
        
        if settings.weeklyEnabled, let time = settings.weeklyTime {
            let weekday = Calendar.current.component(.weekday, from: Date())
            let adjustedDay = (settings.weeklyDay - weekday + 7) % 7
            await scheduleWeeklyNotification(day: settings.weeklyDay, time: time)
        }
        
        if settings.monthlyEnabled, let time = settings.monthlyTime {
            await scheduleMonthlyNotification(day: settings.monthlyDay, time: time)
        }
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
        content.body = "This is a test notification from Daily Intentions."
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
        try? await center.setNotificationCategories([dailyCategory, weeklyCategory, monthlyCategory])
    }
}
