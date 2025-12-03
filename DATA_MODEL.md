# Data Model Documentation

This document describes the data models and repository layer for the Attunetion app.

## Overview

The app uses SwiftData for local persistence with CloudKit sync support. All models are designed to be CloudKit-compatible and support cross-device synchronization.

## Models

### Intention

Represents a user's intention for a specific time period (day, week, or month).

**Properties:**
- `id: UUID` - Unique identifier
- `text: String` - The intention text content
- `scope: IntentionScope` - Enum: `.day`, `.week`, or `.month`
- `date: Date` - The date this intention applies to
- `createdAt: Date` - Creation timestamp
- `updatedAt: Date` - Last update timestamp
- `themeId: UUID?` - Optional reference to an IntentionTheme
- `customFont: String?` - Optional custom font name
- `aiGenerated: Bool` - Whether this intention was AI-generated
- `aiRephrased: Bool` - Whether this intention was AI-rephrased
- `quote: String?` - Optional AI-generated quote

**IntentionScope Enum:**
- `.day` - Daily intention
- `.week` - Weekly intention
- `.month` - Monthly intention

**Business Logic:**
- Day intentions override week intentions
- Week intentions override month intentions
- When displaying the current intention, the hierarchy is: Day > Week > Month

### IntentionTheme

Represents a visual theme for displaying intentions.

**Properties:**
- `id: UUID` - Unique identifier
- `name: String` - Theme name
- `backgroundColor: String` - Hex color code (e.g., "#FFFFFF")
- `textColor: String` - Hex color code for text
- `accentColor: String?` - Optional hex color code for accents
- `fontName: String?` - Optional font name
- `isPreset: Bool` - Whether this is a built-in preset theme
- `isAIGenerated: Bool` - Whether this theme was AI-generated
- `createdAt: Date` - Creation timestamp

**Preset Themes:**
1. **Serene** - Calm and peaceful (light gray background, dark text)
2. **Vibrant** - Energetic and bold (red background, white text)
3. **Minimal** - Clean and simple (white background, black text)
4. **Sunset** - Warm and cozy (orange background, white text)
5. **Ocean** - Cool and refreshing (blue background, white text)

### UserPreferences

Singleton model storing user preferences and settings. Only one instance should exist.

**Properties:**
- `id: UUID` - Unique identifier (should be consistent)
- `onboardingCompleted: Bool` - Whether user completed onboarding
- `defaultThemeId: UUID?` - Default theme to use
- `defaultFont: String?` - Default font name
- `notificationSettings: NotificationSettings` - Notification configuration

**NotificationSettings Struct:**
- `dailyEnabled: Bool` - Enable daily notifications
- `dailyTime: Date?` - Time for daily notification
- `weeklyEnabled: Bool` - Enable weekly notifications
- `weeklyTime: Date?` - Time for weekly notification
- `weeklyDay: Int` - Day of week (0-6, Sunday=0)
- `monthlyEnabled: Bool` - Enable monthly notifications
- `monthlyTime: Date?` - Time for monthly notification
- `monthlyDay: Int` - Day of month (1-31)

**Note:** `NotificationSettings` is stored as JSON data (`notificationSettingsData`) for CloudKit compatibility.

## Repositories

All repositories are `@MainActor` classes that provide thread-safe access to SwiftData models.

### IntentionRepository

**CRUD Operations:**
- `create(_ intention: Intention) throws` - Create new intention
- `getAll() -> [Intention]` - Get all intentions (sorted by date, newest first)
- `update(_ intention: Intention) throws` - Update existing intention
- `delete(_ intention: Intention) throws` - Delete intention

**Query Methods:**
- `getIntention(for date: Date, scope: IntentionScope) -> Intention?` - Get intention for specific date/scope
- `getCurrentDisplayIntention() -> Intention?` - Get current intention using hierarchy (day > week > month)
- `search(query: String) -> [Intention]` - Search intentions by text
- `getIntentions(from: Date, to: Date) -> [Intention]` - Get intentions in date range
- `getIntentions(scope: IntentionScope) -> [Intention]` - Get all intentions for a scope
- `getIntention(byId id: UUID) -> Intention?` - Get intention by ID

**Date Scoping Logic:**
- **Day**: Exact date match (start of day to start of next day)
- **Week**: Same calendar week (using Calendar.dateInterval)
- **Month**: Same month and year

### ThemeRepository

**CRUD Operations:**
- `create(_ theme: IntentionTheme) throws` - Create new theme
- `getAll() -> [IntentionTheme]` - Get all themes (presets first, then by creation date)
- `update(_ theme: IntentionTheme) throws` - Update existing theme
- `delete(_ theme: IntentionTheme) throws` - Delete theme

**Query Methods:**
- `getPresetThemes() -> [IntentionTheme]` - Get only preset themes
- `getCustomThemes() -> [IntentionTheme]` - Get only custom themes
- `getAIGeneratedThemes() -> [IntentionTheme]` - Get AI-generated themes
- `getTheme(byId id: UUID) -> IntentionTheme?` - Get theme by ID
- `presetThemeExists(name: String) -> Bool` - Check if preset theme exists

### UserPreferencesRepository

**Singleton Management:**
- `getOrCreatePreferences() -> UserPreferences` - Get existing or create new preferences
- `getPreferences() -> UserPreferences?` - Get current preferences (nil if none exist)

**CRUD Operations:**
- `create(_ preferences: UserPreferences) throws` - Create preferences (throws if already exists)
- `update(_ preferences: UserPreferences) throws` - Update preferences
- `delete(_ preferences: UserPreferences) throws` - Delete preferences

**Convenience Methods:**
- `markOnboardingCompleted() throws` - Mark onboarding as complete
- `setDefaultTheme(_ themeId: UUID?) throws` - Set default theme
- `setDefaultFont(_ fontName: String?) throws` - Set default font
- `updateNotificationSettings(_ settings: NotificationSettings) throws` - Update notification settings

## CloudKit Integration

All models are CloudKit-compatible:
- Use `@Model` macro for SwiftData
- Primitive types (UUID, String, Bool, Date) are CloudKit-compatible
- Complex types (NotificationSettings) are stored as JSON data using `@Attribute(.externalStorage)`
- ModelContainer is configured with CloudKit sync in `Daily_IntentionsApp.swift`

## App Groups Support

Repositories work with App Groups for widget data sharing:
- Use shared ModelContainer configuration
- Widget extensions can access the same SwiftData store
- Ensure App Groups capability is enabled in project settings

## Usage Examples

### Creating an Intention

```swift
@MainActor
func createIntention() {
    let repository = IntentionRepository(modelContext: modelContext)
    let intention = Intention(
        text: "Focus on mindfulness today",
        scope: .day,
        date: Date()
    )
    try? repository.create(intention)
}
```

### Getting Current Display Intention

```swift
@MainActor
func getCurrentIntention() -> Intention? {
    let repository = IntentionRepository(modelContext: modelContext)
    return repository.getCurrentDisplayIntention()
}
```

### Populating Preset Themes

```swift
@MainActor
func setupPresetThemes() {
    let themeRepo = ThemeRepository(modelContext: modelContext)
    try? PresetThemes.populatePresetThemes(in: themeRepo)
}
```

### Accessing User Preferences

```swift
@MainActor
func getPreferences() -> UserPreferences {
    let prefsRepo = UserPreferencesRepository(modelContext: modelContext)
    return prefsRepo.getOrCreatePreferences()
}
```

## Testing

Use mock/preset data for testing:
- `PresetThemes.getAll()` provides 5 preset themes
- Create sample intentions with various scopes and dates
- Use in-memory ModelContainer for unit tests

## Thread Safety

All repositories are `@MainActor` classes, ensuring:
- Thread-safe access to ModelContext
- UI updates happen on main thread
- Swift Concurrency compatibility

## Future Considerations

- Add relationships between models (e.g., Intention -> IntentionTheme)
- Consider adding indexes for frequently queried fields
- Add migration support for schema changes
- Implement conflict resolution for CloudKit sync



