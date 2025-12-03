# Chat 1: Data Models & Repository Layer

## Your Mission
Build the complete data layer for the Attunetion app using SwiftData with CloudKit sync support.

## Context
You're working on a multi-platform app (iOS/macOS/watchOS) where users track daily/weekly/monthly intentions. The app needs local persistence with SwiftData and cloud sync with CloudKit. Other teams are building the UI and backend API in parallel.

## Your Scope - FILES YOU OWN
Create these files in `Attunetion/Models/`:
- `Intention.swift`
- `IntentionTheme.swift`
- `UserPreferences.swift`

Create these files in `Attunetion/Services/`:
- `IntentionRepository.swift`
- `ThemeRepository.swift`
- `UserPreferencesRepository.swift`

## What You Need to Build

### 1. Intention Model
```swift
// Properties needed:
- id: UUID
- text: String (the actual intention text)
- scope: enum (day/week/month)
- date: Date (which day/week/month this is for)
- createdAt: Date
- updatedAt: Date
- themeId: UUID? (reference to IntentionTheme)
- customFont: String?
- aiGenerated: Bool (was this AI-generated?)
- aiRephrased: Bool (was this AI-rephrased?)
- quote: String? (AI-generated quote, if any)
```

### 2. IntentionTheme Model
```swift
// Properties needed:
- id: UUID
- name: String
- backgroundColor: String (hex color)
- textColor: String (hex color)
- accentColor: String? (hex color, optional)
- fontName: String?
- isPreset: Bool (is this a built-in theme?)
- isAIGenerated: Bool
- createdAt: Date
```

### 3. UserPreferences Model
```swift
// Properties needed:
- id: UUID (should only ever be one instance)
- onboardingCompleted: Bool
- defaultThemeId: UUID?
- defaultFont: String?
- notificationSettings: Codable struct with:
  - dailyEnabled: Bool
  - dailyTime: Date?
  - weeklyEnabled: Bool
  - weeklyTime: Date?
  - weeklyDay: Int (0-6 for Sun-Sat)
  - monthlyEnabled: Bool
  - monthlyTime: Date?
  - monthlyDay: Int (1-31)
```

### 4. Repository Pattern
Create repository classes that provide:
- CRUD operations (Create, Read, Update, Delete)
- Queries (e.g., get intentions for specific date, get current active intention)
- Business logic (e.g., determine which intention to show based on hierarchy)

Example methods needed in IntentionRepository:
```swift
- func create(_ intention: Intention)
- func getAll() -> [Intention]
- func getIntention(for date: Date, scope: IntentionScope) -> Intention?
- func getCurrentDisplayIntention() -> Intention? // respects hierarchy
- func search(query: String) -> [Intention]
- func getIntentions(from: Date, to: Date) -> [Intention]
- func update(_ intention: Intention)
- func delete(_ intention: Intention)
```

## Important Business Logic

### Intention Hierarchy
Day overrides Week, Week overrides Month. When getting the "current intention to display":
1. Check if there's a day intention for today → use it
2. Else check if there's a week intention for this week → use it
3. Else check if there's a month intention for this month → use it
4. Else return nil

### Date Scoping
- Day: exact date match
- Week: same week (use Calendar to determine week boundaries)
- Month: same month and year

## CloudKit Setup
- Mark all models with `@Model` (SwiftData)
- The app already has CloudKit enabled in entitlements
- Configure models to sync via CloudKit (use SwiftData's built-in CloudKit support)
- Don't implement full sync logic yet - just ensure models are CloudKit-compatible

## Integration Points

### What Others Need From You
- **UI Team** needs: Repository classes with async methods
- **Widget Team** needs: Repositories must work with App Groups
- **Backend Team** needs: Model structure documented (they'll mirror it)

### What You Need From Others
- Nothing! You can work completely independently
- The existing `Item.swift` can be deleted once you're done

## Testing
Create preview/mock data for:
- 3-5 preset themes
- Sample intentions for testing
- Helper to reset/populate test data

## Constraints
- Use SwiftData (already initialized in the project)
- Support iOS 17+, macOS 14+, watchOS 10+
- All async operations should use Swift Concurrency
- Thread-safe repository access

## Deliverables
1. Three model files with SwiftData models
2. Three repository files with CRUD + query methods
3. Document the model structure in a `DATA_MODEL.md` file
4. Create a `PresetThemes.swift` with 5 built-in themes
5. Ensure App Groups capability for widget data sharing

## Questions?
If you have questions about requirements, make reasonable assumptions and document them. Focus on building a clean, testable data layer.

**Start by reading the existing project files to understand the structure, then build the models and repositories.**
