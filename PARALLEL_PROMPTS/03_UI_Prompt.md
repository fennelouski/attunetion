# Chat 3: Main App UI (iOS/macOS)

## Your Mission
Build the core user interface for the Daily Intentions app - the main screens users interact with to create, view, search, and manage their intentions.

## Context
You're building a SwiftUI app where users set daily/weekly/monthly intentions. The data layer is being built by another team, so you'll start with mock data and switch to real repositories later. Focus on creating an intuitive, beautiful UI.

## Your Scope - FILES YOU OWN
Create these files in `Daily Intentions/Views/`:
```
Views/
├── Main/
│   ├── IntentionsListView.swift (replace ContentView.swift)
│   ├── IntentionDetailView.swift
│   ├── NewIntentionView.swift
│   └── EditIntentionView.swift
├── Components/
│   ├── IntentionRowView.swift
│   ├── ScopeSelector.swift
│   ├── ThemePickerView.swift
│   ├── FontPickerView.swift
│   └── SearchBar.swift
└── Settings/
    ├── SettingsView.swift
    └── AboutView.swift
```

Create these files in `Daily Intentions/ViewModels/`:
```
ViewModels/
├── IntentionsViewModel.swift
└── ThemeViewModel.swift
```

## What You Need to Build

### 1. IntentionsListView (Main Screen)
Replace ContentView.swift with this as the app's home screen.

Features:
- Show current active intention prominently at top (large card)
  - Display: intention text, scope (Day/Week/Month), date
  - Show theme styling if custom theme applied
- Below: scrollable list of all past/future intentions
- Search bar at top
- Filter buttons: All / Day / Week / Month
- Sort options: Newest First / Oldest First / By Scope
- Add button (FAB or toolbar) to create new intention
- Empty state when no intentions ("Set your first intention")

Design considerations:
- Current intention should be visually distinct (larger, special background)
- Use iOS-style list with swipe actions (edit, delete)
- Pull-to-refresh (even if just for animation)
- Support both iOS and macOS layouts (#if os(macOS))

### 2. NewIntentionView (Sheet/Modal)
Features:
- Large text editor for intention text
- Character count (suggest keeping under 100 chars for widget)
- Scope selector: Day / Week / Month (segmented control or picker)
- Date picker (which day/week/month this is for)
  - Default to today/this week/this month
- Optional: Theme picker (use preset themes)
- Optional: Font picker (3-5 fonts)
- "Generate AI Theme" button (calls backend - can mock for now)
- Preview of how it looks in widget
- Cancel / Save buttons

Validation:
- Text required (min 3 characters)
- Show warning if intention already exists for that date+scope

### 3. IntentionDetailView
Features:
- Show full intention text (scrollable if long)
- Display all metadata: scope, date, created date, updated date
- Show theme (visual preview of colors)
- Show font
- If AI-generated: show badge
- If has quote: display quote in elegant typography
- Edit button (opens EditIntentionView)
- Delete button (with confirmation)
- Share button (share as image or text)

### 4. EditIntentionView
Same as NewIntentionView but pre-filled with existing data.

### 5. Components

#### IntentionRowView
Reusable row component for the list:
- Intention text (truncated if long)
- Scope badge (Day/Week/Month with color coding)
- Date subtitle
- AI badge if AI-generated
- Chevron or disclosure indicator

#### ScopeSelector
Segmented control or custom picker:
```swift
enum IntentionScope: String, CaseIterable {
    case day = "Day"
    case week = "Week"
    case month = "Month"
}
```

#### ThemePickerView
Grid or list of theme options:
- Show preset themes (you can define 3-5)
- Show visual preview (color swatch)
- Allow selection
- "Generate AI Theme" option

Example preset themes:
```swift
- Ocean: Blue/teal gradient
- Sunset: Orange/pink gradient
- Forest: Green/brown tones
- Minimal: Black text on white
- Midnight: White text on dark blue
```

#### FontPickerView
List of 3-5 font options:
- System (SF Pro)
- Serif (New York)
- Rounded (SF Rounded)
- Monospace (SF Mono)
- Display (Avenir or similar)

Show preview of each font.

### 6. SearchBar Component
Standard iOS search bar with:
- Placeholder: "Search intentions..."
- Cancel button
- Real-time filtering (as user types)

### 7. SettingsView
Basic settings screen:
- Notification settings (link to NotificationSettingsView - another team builds this)
- Default theme picker
- Default font picker
- About section (version, credits)
- Export data option (future)

## Mock Data for Development

Since the data team is building repositories in parallel, create mock data:

```swift
// MockData.swift
struct MockData {
    static let intentions: [MockIntention] = [
        MockIntention(
            text: "Be present with family",
            scope: .day,
            date: Date(),
            theme: PresetThemes.ocean
        ),
        MockIntention(
            text: "Focus on health",
            scope: .week,
            date: Date(),
            theme: PresetThemes.forest
        ),
        // ... more examples
    ]
}

struct MockIntention: Identifiable {
    let id = UUID()
    var text: String
    var scope: IntentionScope
    var date: Date
    var theme: ThemePreset?
    var aiGenerated: Bool = false
    var quote: String?
}
```

## ViewModels

### IntentionsViewModel
```swift
@Observable
class IntentionsViewModel {
    var intentions: [MockIntention] = MockData.intentions
    var searchQuery: String = ""
    var selectedScope: IntentionScope?
    var sortOrder: SortOrder = .newestFirst

    var filteredIntentions: [MockIntention] {
        // Filter + sort logic
    }

    var currentIntention: MockIntention? {
        // Get current based on hierarchy
    }

    func addIntention(_ intention: MockIntention) { }
    func updateIntention(_ intention: MockIntention) { }
    func deleteIntention(_ intention: MockIntention) { }
}
```

## Integration Points

### What Others Need From You
- **Widget Team** needs: Your theme picker component
- **Notification Team** needs: Navigation from notifications to detail view

### What You Need From Others
- **Data Team** will provide: Real repositories to replace mock data
- **Backend Team** will provide: AI theme generation API (mock it for now)

### Integration Plan
1. Start with mock data in ViewModel
2. Later: replace with actual repositories
3. Create protocol for data access to make swapping easy:

```swift
protocol IntentionDataSource {
    func getAll() -> [SomeIntention]
    func getCurrent() -> SomeIntention?
    // ...
}

// Use in ViewModel:
var dataSource: IntentionDataSource = MockDataSource()
// Later: = RealRepository()
```

## Platform Support

### iOS Specifics
- Use NavigationStack (iOS 16+)
- Support iPhone and iPad (responsive layout)
- Use sheet for modals
- SwiftUI List with swipe actions

### macOS Specifics
- Use NavigationSplitView for Mac
- Keyboard shortcuts (Cmd+N for new, Cmd+F for search)
- Menu bar commands
- Larger layout on Mac (multi-column where appropriate)

Use conditional compilation:
```swift
#if os(iOS)
    // iOS-specific code
#elseif os(macOS)
    // macOS-specific code
#endif
```

## Design Guidelines
- Use SF Symbols for icons
- Follow Human Interface Guidelines
- Support Dark Mode
- Use native SwiftUI components (List, Form, etc.)
- Smooth animations for navigation
- Haptic feedback on iOS (for button taps, etc.)

## Accessibility
- All buttons need labels
- Use proper heading hierarchy
- Support Dynamic Type (text scaling)
- VoiceOver labels for custom components
- Sufficient color contrast

## Deliverables
1. All view files listed above
2. Working navigation between screens
3. CRUD operations (create, read, update, delete) working with mock data
4. Search and filtering working
5. Theme and font pickers working
6. Responsive design for iPhone, iPad, Mac
7. Dark mode support
8. Preview providers for each view (for Xcode previews)

## Constraints
- SwiftUI only (no UIKit)
- iOS 17+, macOS 14+
- Use Swift 5.9+ features (Observable macro, etc.)
- Must work with mock data initially (no dependencies on data layer)

## Nice-to-Haves (if time permits)
- Animations for list operations
- Custom transitions
- Widget preview in NewIntentionView
- Export intention as image
- Share sheet integration

**Start by updating ContentView.swift to become IntentionsListView with mock data, then build out the other screens one by one.**
