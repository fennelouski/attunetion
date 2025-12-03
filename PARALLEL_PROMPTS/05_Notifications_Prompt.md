# Chat 5: Notification System

## Your Mission
Build a comprehensive notification system that reminds users to set new intentions and allows them to create intentions directly from notification actions (inline text input).

## Context
Users want configurable reminders to set daily/weekly/monthly intentions. Notifications should be fully customizable (time, frequency, enable/disable) and support inline text input so users can add intentions without opening the app.

## Your Scope - FILES YOU OWN

Create these files in `Attunetion/Services/`:
```
Services/
├── NotificationManager.swift (main notification service)
└── NotificationHandler.swift (handle notification responses)
```

Create these files in `Attunetion/Views/Settings/`:
```
Views/Settings/
├── NotificationSettingsView.swift (UI for configuring notifications)
└── Components/
    ├── NotificationToggleRow.swift
    └── TimePickerRow.swift
```

Create Notification Service Extension (if needed for rich notifications):
```
IntentionNotificationService/ (new target)
└── NotificationService.swift
```

## What You Need to Build

### 1. Notification Manager Service

```swift
@Observable
class NotificationManager {
    static let shared = NotificationManager()

    // Request notification permissions
    func requestAuthorization() async -> Bool

    // Schedule notifications based on user preferences
    func scheduleAllNotifications()
    func scheduleDailyNotification(time: Date)
    func scheduleWeeklyNotification(day: Weekday, time: Date)
    func scheduleMonthlyNotification(day: Int, time: Date)

    // Cancel notifications
    func cancelAllNotifications()
    func cancelDailyNotifications()
    func cancelWeeklyNotifications()
    func cancelMonthlyNotifications()

    // Check settings
    func getNotificationStatus() async -> UNAuthorizationStatus
    func getPendingNotifications() async -> [UNNotificationRequest]
}
```

### 2. Notification Types

#### Daily Intention Reminder
- **Title**: "Time for today's intention"
- **Body**: "What do you want to focus on today?"
- **Category**: "DAILY_INTENTION"
- **Actions**:
  - "Set Intention" (opens text input)
  - "Skip" (dismisses)
  - "View App" (opens app)
- **Default Time**: 8:00 AM (user configurable)

#### Weekly Intention Reminder
- **Title**: "Plan your week"
- **Body**: "What's your intention for this week?"
- **Category**: "WEEKLY_INTENTION"
- **Actions**: Same as daily
- **Default Time**: Sunday 7:00 PM (user configurable day + time)

#### Monthly Intention Reminder
- **Title**: "New month, new intentions"
- **Body**: "Set your intention for [Month Name]"
- **Category**: "MONTHLY_INTENTION"
- **Actions**: Same as daily
- **Default Time**: 1st of month at 9:00 AM (user configurable day + time)

### 3. Notification Actions (Inline Text Input)

```swift
// Define notification categories with actions
func setupNotificationCategories() {
    let setIntentionAction = UNTextInputNotificationAction(
        identifier: "SET_INTENTION_ACTION",
        title: "Set Intention",
        options: [.authenticationRequired],
        textInputButtonTitle: "Set",
        textInputPlaceholder: "Enter your intention..."
    )

    let skipAction = UNNotificationAction(
        identifier: "SKIP_ACTION",
        title: "Skip",
        options: []
    )

    let dailyCategory = UNNotificationCategory(
        identifier: "DAILY_INTENTION",
        actions: [setIntentionAction, skipAction],
        intentIdentifiers: [],
        options: [.customDismissAction]
    )

    // Register categories
    UNUserNotificationCenter.current().setNotificationCategories([
        dailyCategory,
        weeklyCategory,
        monthlyCategory
    ])
}
```

### 4. Notification Handler

```swift
class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationHandler()

    // Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        return [.banner, .sound, .badge]
    }

    // Handle user interaction with notification
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        switch response.actionIdentifier {
        case "SET_INTENTION_ACTION":
            if let textResponse = response as? UNTextInputNotificationResponse {
                let intentionText = textResponse.userText
                let category = response.notification.request.content.categoryIdentifier

                // Determine scope from category
                let scope: IntentionScope = {
                    switch category {
                    case "DAILY_INTENTION": return .day
                    case "WEEKLY_INTENTION": return .week
                    case "MONTHLY_INTENTION": return .month
                    default: return .day
                    }
                }()

                // Create intention
                await createIntention(text: intentionText, scope: scope)
            }

        case "SKIP_ACTION":
            // Just dismiss
            break

        case UNNotificationDefaultActionIdentifier:
            // User tapped notification - open app to new intention screen
            await openApp(toScreen: .newIntention)

        default:
            break
        }
    }

    private func createIntention(text: String, scope: IntentionScope) async {
        // Use repository to create intention
        // Show confirmation (local notification or in-app if opened)
    }

    private func openApp(toScreen: AppScreen) async {
        // Use deep link or app state to navigate
    }
}
```

### 5. Notification Settings UI

#### NotificationSettingsView
```swift
struct NotificationSettingsView: View {
    @State private var dailyEnabled = false
    @State private var dailyTime = Date()

    @State private var weeklyEnabled = false
    @State private var weeklyDay = 0 // 0 = Sunday
    @State private var weeklyTime = Date()

    @State private var monthlyEnabled = false
    @State private var monthlyDay = 1 // 1-31
    @State private var monthlyTime = Date()

    var body: some View {
        Form {
            Section("Daily Reminder") {
                Toggle("Enable", isOn: $dailyEnabled)
                if dailyEnabled {
                    DatePicker("Time", selection: $dailyTime, displayedComponents: .hourAndMinute)
                }
            }

            Section("Weekly Reminder") {
                Toggle("Enable", isOn: $weeklyEnabled)
                if weeklyEnabled {
                    Picker("Day", selection: $weeklyDay) {
                        ForEach(Weekday.allCases) { day in
                            Text(day.name).tag(day.rawValue)
                        }
                    }
                    DatePicker("Time", selection: $weeklyTime, displayedComponents: .hourAndMinute)
                }
            }

            Section("Monthly Reminder") {
                Toggle("Enable", isOn: $monthlyEnabled)
                if monthlyEnabled {
                    Stepper("Day \(monthlyDay)", value: $monthlyDay, in: 1...31)
                    DatePicker("Time", selection: $monthlyTime, displayedComponents: .hourAndMinute)
                }
            }

            Section {
                Button("Test Notification") {
                    // Send test notification immediately
                }
            }
        }
        .navigationTitle("Notifications")
        .onChange(of: dailyEnabled) { rescheduleNotifications() }
        .onChange(of: dailyTime) { rescheduleNotifications() }
        // ... similar for other settings
    }

    private func rescheduleNotifications() {
        Task {
            await NotificationManager.shared.scheduleAllNotifications()
        }
    }
}
```

### 6. Scheduling Logic

#### Daily Notifications
```swift
func scheduleDailyNotification(time: Date) {
    let content = UNMutableNotificationContent()
    content.title = "Time for today's intention"
    content.body = "What do you want to focus on today?"
    content.categoryIdentifier = "DAILY_INTENTION"
    content.sound = .default

    // Schedule at specific time each day
    var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: time)
    dateComponents.second = 0

    let trigger = UNCalendarNotificationTrigger(
        dateMatching: dateComponents,
        repeats: true
    )

    let request = UNNotificationRequest(
        identifier: "daily-intention-\(UUID().uuidString)",
        content: content,
        trigger: trigger
    )

    UNUserNotificationCenter.current().add(request)
}
```

#### Weekly Notifications
```swift
func scheduleWeeklyNotification(weekday: Int, time: Date) {
    let content = UNMutableNotificationContent()
    content.title = "Plan your week"
    content.body = "What's your intention for this week?"
    content.categoryIdentifier = "WEEKLY_INTENTION"
    content.sound = .default

    var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: time)
    dateComponents.weekday = weekday + 1 // Calendar weekday: 1=Sunday
    dateComponents.second = 0

    let trigger = UNCalendarNotificationTrigger(
        dateMatching: dateComponents,
        repeats: true
    )

    let request = UNNotificationRequest(
        identifier: "weekly-intention-\(UUID().uuidString)",
        content: content,
        trigger: trigger
    )

    UNUserNotificationCenter.current().add(request)
}
```

#### Monthly Notifications
```swift
func scheduleMonthlyNotification(day: Int, time: Date) {
    let content = UNMutableNotificationContent()
    content.title = "New month, new intentions"
    content.body = "Set your intention for this month"
    content.categoryIdentifier = "MONTHLY_INTENTION"
    content.sound = .default

    var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: time)
    dateComponents.day = day
    dateComponents.second = 0

    let trigger = UNCalendarNotificationTrigger(
        dateMatching: dateComponents,
        repeats: true
    )

    let request = UNNotificationRequest(
        identifier: "monthly-intention-\(UUID().uuidString)",
        content: content,
        trigger: trigger
    )

    UNUserNotificationCenter.current().add(request)
}
```

### 7. Permission Handling

```swift
func requestAuthorization() async -> Bool {
    do {
        let granted = try await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge])

        if granted {
            await setupNotificationCategories()
        }

        return granted
    } catch {
        print("Notification authorization error: \(error)")
        return false
    }
}

// Check current status
func checkAuthorizationStatus() async -> UNAuthorizationStatus {
    let settings = await UNUserNotificationCenter.current().notificationSettings()
    return settings.authorizationStatus
}
```

### 8. Persistent Settings

Store notification preferences using UserDefaults or UserPreferences model:

```swift
struct NotificationPreferences: Codable {
    var dailyEnabled: Bool = false
    var dailyTime: Date = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!

    var weeklyEnabled: Bool = false
    var weeklyDay: Int = 0 // Sunday
    var weeklyTime: Date = Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: Date())!

    var monthlyEnabled: Bool = false
    var monthlyDay: Int = 1
    var monthlyTime: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!
}

extension UserDefaults {
    var notificationPreferences: NotificationPreferences {
        get {
            guard let data = data(forKey: "notificationPreferences"),
                  let prefs = try? JSONDecoder().decode(NotificationPreferences.self, from: data)
            else { return NotificationPreferences() }
            return prefs
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                set(data, forKey: "notificationPreferences")
            }
        }
    }
}
```

### 9. App Launch Setup

In `Daily_IntentionsApp.swift`:
```swift
init() {
    // Set notification delegate
    UNUserNotificationCenter.current().delegate = NotificationHandler.shared

    // Setup notification categories
    Task {
        await NotificationManager.shared.setupNotificationCategories()
    }
}
```

### 10. Testing Notifications

Create a test notification function:
```swift
func sendTestNotification() async {
    let content = UNMutableNotificationContent()
    content.title = "Test: Daily Intention"
    content.body = "This is a test notification"
    content.categoryIdentifier = "DAILY_INTENTION"
    content.sound = .default

    // Trigger in 5 seconds
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

    let request = UNNotificationRequest(
        identifier: "test-\(UUID().uuidString)",
        content: content,
        trigger: trigger
    )

    try? await UNUserNotificationCenter.current().add(request)
}
```

## Integration Points

### What Others Need From You
- **UI Team** needs: NotificationSettingsView to link from main settings
- **Data Team** needs: Notification handler to create intentions

### What You Need From Others
- **Data Team** will provide: Repository to create intentions from notifications
- **UI Team** will provide: Deep link handling to navigate from notifications

### Integration Plan
1. Build notification system independently (use mock intention creation)
2. Later: integrate with real IntentionRepository
3. Coordinate with UI team for deep linking

## Constraints
- iOS 16+ for inline text input in notifications
- Notification limits: ~64 scheduled notifications max (clean up old ones)
- Background app refresh must be enabled for reliable delivery
- Users can disable notifications - handle gracefully

## Testing Checklist
- [ ] Request permissions flow
- [ ] Daily notification appears at correct time
- [ ] Weekly notification appears on correct day/time
- [ ] Monthly notification appears on correct day/time
- [ ] Inline text input works (create intention from notification)
- [ ] Skip action works
- [ ] Tapping notification opens app
- [ ] Settings persist across app launches
- [ ] Settings changes reschedule notifications correctly
- [ ] Disabling notification cancels scheduled notifications
- [ ] Test notification button works
- [ ] App works when notification permission denied

## Deliverables
1. NotificationManager service with scheduling logic
2. NotificationHandler for action handling
3. NotificationSettingsView with full configuration UI
4. Inline text input to create intentions from notifications
5. Permission request flow
6. Deep linking support (coordinate with UI team)
7. Persistent settings storage
8. Test notification feature
9. Documentation of notification categories and actions

## Nice-to-Haves (if time permits)
- Rich notifications with images
- Custom notification sounds
- Smart notification timing (machine learning based on usage)
- Notification history in app
- Snooze option
- Custom notification messages (user can write their own reminder text)

**Start by implementing basic notification permission request and scheduling logic, then add inline text input and settings UI.**
