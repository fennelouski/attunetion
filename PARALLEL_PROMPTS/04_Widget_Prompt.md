# Chat 4: Widget Extensions (iOS/macOS)

## Your Mission
Build beautiful, customizable widgets that display the user's current intention on the home screen, lock screen, and macOS desktop.

## Context
You're creating WidgetKit extensions that show the current daily/weekly/monthly intention. The widget needs to pull data from the main app's SwiftData store using App Groups, and support multiple sizes and customization options.

## Your Scope - FILES YOU OWN
Create a new Widget Extension target in Xcode:
```
IntentionWidget/ (new target)
├── IntentionWidget.swift (main entry point)
├── IntentionWidgetProvider.swift (timeline provider)
├── IntentionWidgetEntry.swift (timeline entry model)
├── Views/
│   ├── IntentionWidgetView.swift (main widget view)
│   ├── SmallWidgetView.swift
│   ├── MediumWidgetView.swift
│   ├── LargeWidgetView.swift
│   └── LockScreenWidgetView.swift (iOS 16+)
└── Assets.xcassets (widget-specific assets)
```

Also modify:
- Add App Group entitlement to both main app and widget
- Configure App Group in Xcode capabilities

## What You Need to Build

### 1. Widget Extension Setup

#### Create Widget Extension Target
1. File > New > Target > Widget Extension
2. Name: "IntentionWidget"
3. Enable "Include Configuration Intent" (for customization)
4. Add to same App Group as main app

#### App Group Configuration
```swift
// Use App Group to share data between app and widget
let appGroupIdentifier = "group.com.yourcompany.dailyintentions"
```

### 2. Widget Sizes to Support

#### iOS
- **Small (systemSmall)**: Just intention text, minimal
- **Medium (systemMedium)**: Intention + scope badge + date
- **Large (systemLarge)**: Intention + quote + theme styling
- **Lock Screen (accessoryRectangular)**: Compact intention display
- **Lock Screen (accessoryCircular)**: Scope icon with first letter of intention
- **Lock Screen (accessoryInline)**: One-line intention text

#### macOS (if supporting macOS Sonoma+)
- **Small**: Minimal intention text
- **Medium**: Intention + metadata
- **Large**: Full intention with styling

### 3. Timeline Provider

```swift
struct IntentionWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> IntentionEntry {
        // Return placeholder entry for widget gallery
    }

    func getSnapshot(in context: Context, completion: @escaping (IntentionEntry) -> Void) {
        // Return quick snapshot for preview
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<IntentionEntry>) -> Void) {
        // Fetch current intention from App Group
        // Create timeline entries
        // Update at midnight (for day intentions)
        // Update at start of week (for week intentions)
        // Update at start of month (for month intentions)
    }
}
```

#### Timeline Strategy
- Generate entries for the next 24 hours
- Update at midnight daily (to switch day intentions)
- Update at start of week (Sunday/Monday - check user's calendar)
- Update at start of month
- Use `Timeline(entries: entries, policy: .atEnd)` to refresh

### 4. Widget Entry Model

```swift
struct IntentionEntry: TimelineEntry {
    let date: Date
    let intention: IntentionData?
    let theme: ThemeData?
    let configuration: IntentionConfigurationIntent // for customization
}

struct IntentionData {
    let text: String
    let scope: String // "Day", "Week", "Month"
    let scopeDate: Date
    let quote: String?
    let aiGenerated: Bool
}

struct ThemeData {
    let backgroundColor: Color
    let textColor: Color
    let accentColor: Color
    let fontName: String?
}
```

### 5. Widget Views

#### SmallWidgetView (systemSmall)
```
┌─────────────────┐
│                 │
│  Be present     │
│  with family    │
│                 │
│  [Day badge]    │
│                 │
└─────────────────┘
```
- Intention text (truncated if needed)
- Small scope badge at bottom
- Apply theme colors

#### MediumWidgetView (systemMedium)
```
┌──────────────────────────────────┐
│  [Day]                           │
│                                  │
│  Be present with family          │
│                                  │
│  Today • December 2              │
└──────────────────────────────────┘
```
- Scope badge at top left
- Intention text (center or left-aligned)
- Date subtitle at bottom
- Theme colors applied

#### LargeWidgetView (systemLarge)
```
┌──────────────────────────────────┐
│  [Week]                          │
│                                  │
│  Focus on health and             │
│  meaningful movement             │
│                                  │
│  "The greatest wealth is         │
│  health." - Virgil               │
│                                  │
│  This Week • Dec 2-8             │
└──────────────────────────────────┘
```
- Scope badge
- Intention text (larger font)
- Quote (if available) in italic or different style
- Date range at bottom
- Full theme styling

#### LockScreenWidgetView (accessoryRectangular)
```
┌────────────────────────┐
│ 📅 Be present          │
│    with family         │
└────────────────────────┘
```
- Compact, 2-3 lines max
- Icon for scope (SF Symbol)
- Truncated text
- Follows iOS lock screen design guidelines

### 6. Widget Customization (Configuration Intent)

Create `IntentionConfiguration.intentdefinition`:
- **Show Quote**: Boolean (show AI quote if available)
- **Theme**: Enum (Use App Theme / Always Light / Always Dark / Custom)
- **Widget Style**: Enum (Minimal / Standard / Decorative)

Allow users to long-press widget and configure these options.

### 7. Data Fetching from App Group

```swift
// In TimelineProvider
func getCurrentIntention() -> IntentionData? {
    // Access SwiftData container via App Group
    let containerURL = FileManager.default
        .containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)

    // Load SwiftData model container
    // Query for current intention (respecting hierarchy)
    // Return intention data

    // IMPORTANT: This needs to respect day > week > month hierarchy
}
```

**Challenge**: SwiftData access from widget can be tricky. Options:
1. Use shared SwiftData container (recommended)
2. Or: Have app write current intention to UserDefaults in App Group (simpler)
3. Or: Use Background Refresh to keep widget updated

Recommended approach for simplicity:
```swift
// In main app, whenever intention changes:
extension UserDefaults {
    static let shared = UserDefaults(suiteName: "group.com.yourcompany.dailyintentions")!

    func saveCurrentIntention(_ intention: IntentionData) {
        // Encode and save
    }

    func getCurrentIntention() -> IntentionData? {
        // Decode and return
    }
}

// Widget reads from UserDefaults.shared
```

### 8. Widget Deep Linking

When user taps widget, open main app to that intention:
```swift
.widgetURL(URL(string: "dailyintentions://intention/\(intention.id)")!)

// In main app, handle URL:
.onOpenURL { url in
    // Parse URL and navigate to detail view
}
```

### 9. Preview Themes

Create 5 preset themes that look great on widgets:

```swift
struct WidgetTheme {
    static let ocean = ThemeData(
        backgroundColor: Color(hex: "1E3A8A"),
        textColor: .white,
        accentColor: Color(hex: "60A5FA")
    )

    static let sunset = ThemeData(
        backgroundColor: Color(hex: "FCD34D"),
        textColor: Color(hex: "78350F"),
        accentColor: Color(hex: "FB923C")
    )

    static let forest = ThemeData(
        backgroundColor: Color(hex: "166534"),
        textColor: .white,
        accentColor: Color(hex: "86EFAC")
    )

    static let minimal = ThemeData(
        backgroundColor: .white,
        textColor: .black,
        accentColor: .gray
    )

    static let midnight = ThemeData(
        backgroundColor: Color(hex: "0F172A"),
        textColor: .white,
        accentColor: Color(hex: "818CF8")
    )
}
```

### 10. Empty State

When no intention is set:
```
┌──────────────────────────────────┐
│                                  │
│  No intention set                │
│  Tap to create one               │
│                                  │
└──────────────────────────────────┘
```

## Integration Points

### What Others Need From You
- **UI Team** can preview widgets in app (widget preview feature)
- **Data Team** needs to know: widget reads from App Group UserDefaults

### What You Need From Others
- **Data Team** will provide: Intention models (use mock data to start)
- **UI Team** will provide: Theme definitions (create your own presets for now)

### Integration Plan
1. Start with mock data hardcoded in widget
2. Test all widget sizes with mock data
3. Integrate with App Group UserDefaults
4. Test with real data from main app

## Testing

### Widget Testing
- Use Xcode widget gallery to preview
- Test on actual device (widgets can behave differently than simulator)
- Test timeline updates (change system time to test midnight refresh)
- Test deep linking (tap widget → opens app)
- Test configuration changes (long-press → edit widget)

### Visual Testing
Each widget size should be tested with:
- Short intention text (5 words)
- Long intention text (30+ words) - ensure proper truncation
- With and without quotes
- All theme variations
- Light and dark mode

## Constraints
- Widget extension has memory limits (~30MB)
- Widget extension cannot make network calls directly (use App Group to share data)
- Widgets update via timeline (not real-time)
- Must work when app is not running

## Performance
- Keep widget code lightweight
- Avoid complex computations in widget views
- Pre-process data in main app if possible
- Use SF Symbols (already cached by system) instead of custom images
- Minimize SwiftData queries in widget

## Deliverables
1. Working widget extension with all size variants
2. Lock screen widget support (iOS 16+)
3. Widget customization via Configuration Intent
4. Preset themes implemented
5. App Group data sharing working
6. Deep linking to main app
7. Timeline refresh logic (updates at appropriate times)
8. Empty state handling
9. Light and dark mode support
10. Preview providers for development

## Nice-to-Haves (if time permits)
- Animated widget transitions (iOS 17+)
- Widget relevance scores (for Smart Stack)
- Multiple widget configurations (one for day, one for week)
- macOS widget support
- Live Activity for iOS 16+ (to show temporary intention updates)

**Start by creating the widget extension target, implementing a simple systemMedium widget with hardcoded text, then expand to all sizes and add data integration.**
