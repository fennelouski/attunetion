# Daily Intentions App - Parallelizable Implementation Plan

## Project Overview
A multi-platform app (iOS, macOS, watchOS, iPadOS) for tracking daily/weekly/monthly intentions with widgets, AI features, and cross-device sync.

## Tech Stack
- **Frontend**: SwiftUI + SwiftData (already initialized)
- **Sync**: CloudKit (already enabled in entitlements)
- **Backend**: Vercel (for AI features and API endpoints)
- **Widgets**: WidgetKit
- **Notifications**: UserNotifications + NotificationService extension

---

## Phase 1: Foundation (Week 1)
These modules can be built in parallel by different developers/teams.

### Module A1: Core Data Models
**Dependencies**: None
**Team**: Backend/Data Team

- [ ] Create `Intention` model (SwiftData)
  - Properties: id, text, scope (day/week/month), date, createdAt, updatedAt
  - Properties: customTheme, customFont, aiGenerated flags
- [ ] Create `IntentionTheme` model
  - Properties: id, backgroundColor, textColor, fontName, isCustom
- [ ] Create `UserPreferences` model
  - Properties: notificationSettings, defaultTheme, defaultFont, onboardingCompleted
- [ ] Add CloudKit sync capability to models
- [ ] Create data repositories/managers for CRUD operations

**Outputs**: Data layer ready for consumption

---

### Module A2: Vercel Backend - Core API
**Dependencies**: None
**Team**: Backend Team

- [ ] Initialize Vercel project with TypeScript
- [ ] Set up environment variables (OpenAI API key, etc.)
- [ ] Create `/api/intentions` endpoints
  - POST `/api/intentions` - Create intention
  - GET `/api/intentions/:userId` - Get user intentions
  - PUT `/api/intentions/:id` - Update intention
  - DELETE `/api/intentions/:id` - Delete intention
- [ ] Set up database (Vercel Postgres or similar) for backup/sync
- [ ] Add authentication middleware (JWT or similar)
- [ ] CORS configuration for Apple platforms

**Outputs**: REST API ready for client integration

---

### Module A3: Basic UI Foundation
**Dependencies**: Module A1 (light dependency - can use mock data)
**Team**: iOS Team

- [ ] Replace ContentView with main IntentionsListView
- [ ] Create IntentionRowView component
- [ ] Implement navigation structure (NavigationStack)
- [ ] Create IntentionDetailView for viewing single intention
- [ ] Create NewIntentionView with text input
- [ ] Add scope selector (Day/Week/Month)
- [ ] Implement search functionality
- [ ] Add filter/sort options (by date, by scope)

**Outputs**: Basic app navigation and CRUD UI

---

### Module A4: Widget Extensions Setup
**Dependencies**: Module A1
**Team**: iOS Team (can be different person from A3)

- [ ] Create WidgetExtension target in Xcode
- [ ] Create Widget configuration (small, medium, large)
- [ ] Create TimelineProvider for widget updates
- [ ] Implement basic widget view (just text for now)
- [ ] Set up App Groups for data sharing
- [ ] Implement widget configuration intent
- [ ] Create lock screen widget variants (iOS 16+)

**Outputs**: Widget infrastructure ready

---

## Phase 2: Features (Week 2-3)
These modules build on Phase 1 but are still largely independent.

### Module B1: AI Integration - Theme Generation
**Dependencies**: Module A2
**Team**: Backend Team + AI Specialist

- [ ] Vercel API: POST `/api/ai/generate-theme`
  - Input: intention text
  - Uses OpenAI to analyze mood/content
  - Returns color palette (background, text, accent colors)
- [ ] Client: Create AIThemeService
- [ ] Client: Add "Generate AI Theme" button in NewIntentionView
- [ ] Client: Theme preview component
- [ ] Store AI-generated themes in IntentionTheme model

**Outputs**: AI theme generation feature

---

### Module B2: AI Integration - Quote Generation
**Dependencies**: Module A2
**Team**: Backend Team + AI Specialist

- [ ] Vercel API: POST `/api/ai/generate-quote`
  - Input: intention text
  - Returns relevant inspirational quote
- [ ] Client: Create QuoteService
- [ ] Client: Add quote display in widget
- [ ] Client: Quote refresh mechanism (optional/configurable)
- [ ] Cache quotes to reduce API calls

**Outputs**: AI quote feature

---

### Module B3: AI Integration - Rephrase & Auto-generate
**Dependencies**: Module A2
**Team**: Backend Team + AI Specialist

- [ ] Vercel API: POST `/api/ai/rephrase-intention`
  - Input: intention text
  - Returns rephrased version (keeping core meaning)
- [ ] Vercel API: POST `/api/ai/generate-monthly-intention`
  - Input: array of previous month intentions
  - Returns new intention for upcoming month
- [ ] Client: Scheduled job to check for empty months
- [ ] Client: Auto-populate with AI suggestion
- [ ] Client: Show "AI suggested" badge

**Outputs**: Auto-rephrasing and auto-generation

---

### Module B4: Advanced Widget Styling
**Dependencies**: Module A4, Module B1
**Team**: iOS Design Team

- [ ] Implement theme switcher in widget
- [ ] Create 3-5 preset themes
- [ ] Add font selector (3-5 font options)
- [ ] Widget customization UI in main app
- [ ] Preview widget in app
- [ ] Apply AI-generated themes to widget
- [ ] Animate widget updates (if appropriate)

**Outputs**: Beautiful, customizable widgets

---

### Module B5: Notification System
**Dependencies**: Module A1
**Team**: iOS Team

- [ ] Request notification permissions
- [ ] Create NotificationService
- [ ] Schedule daily/weekly/monthly reminder notifications
- [ ] Implement notification settings UI
  - Toggle on/off for each frequency
  - Time picker for each notification
  - Custom message templates
- [ ] Add NotificationService extension
- [ ] Implement inline reply to set intention
- [ ] Handle notification actions
- [ ] Deep linking from notifications

**Outputs**: Full notification system

---

### Module B6: Cross-Platform Support
**Dependencies**: Module A1, A3
**Team**: Multi-platform Team

- [ ] Create watchOS target
  - Simple list view of current intention
  - Complication support
  - Quick add intention via dictation
- [ ] Optimize for iPad
  - Multi-column layout
  - Drag & drop support
  - Keyboard shortcuts
- [ ] Optimize for macOS
  - Menu bar widget
  - Keyboard shortcuts
  - macOS widget support

**Outputs**: Full cross-platform support

---

## Phase 3: Polish & Advanced Features (Week 4)

### Module C1: Onboarding
**Dependencies**: Module A3
**Team**: iOS Team + Designer

- [ ] Design onboarding flow (3-5 screens)
- [ ] Create example intentions
- [ ] Explain scope hierarchy (day > week > month)
- [ ] Widget setup walkthrough
- [ ] Notification setup
- [ ] Skip option
- [ ] Track onboarding completion in UserPreferences

**Outputs**: User onboarding experience

---

### Module C2: CloudKit Sync
**Dependencies**: Module A1
**Team**: Backend/Sync Team

- [ ] Configure CloudKit container in Apple Developer
- [ ] Set up CloudKit schema (mirror SwiftData models)
- [ ] Implement CloudKit sync manager
- [ ] Handle conflict resolution (last-write-wins or merge)
- [ ] Sync on app launch
- [ ] Background sync
- [ ] Sync status indicators in UI
- [ ] Handle offline mode gracefully

**Outputs**: Seamless cross-device sync

---

### Module C3: Advanced Search & History
**Dependencies**: Module A3
**Team**: iOS Team

- [ ] Full-text search across all intentions
- [ ] Filter by date range
- [ ] Filter by scope (day/week/month)
- [ ] Search results highlighting
- [ ] Archive old intentions (optional)
- [ ] Export intentions (JSON, CSV, or text)
- [ ] Infinite scroll/pagination for large datasets

**Outputs**: Powerful search and history

---

### Module C4: Analytics & Insights (Optional)
**Dependencies**: Module A1, A2
**Team**: Data Team

- [ ] Track intention creation patterns
- [ ] Show streaks (consecutive days/weeks with intentions)
- [ ] Word cloud of common themes
- [ ] Monthly summary view
- [ ] Privacy-first analytics (on-device or anonymized)

**Outputs**: User insights

---

## Parallel Execution Strategy

### Sprint 1 (Days 1-3)
**In Parallel**:
- Module A1: Core Data Models
- Module A2: Vercel Backend - Core API
- Module A3: Basic UI Foundation
- Module A4: Widget Extensions Setup

### Sprint 2 (Days 4-7)
**In Parallel**:
- Module B1: AI Theme Generation
- Module B2: AI Quote Generation
- Module B4: Advanced Widget Styling
- Module B5: Notification System

### Sprint 3 (Days 8-12)
**In Parallel**:
- Module B3: AI Rephrase & Auto-generate
- Module B6: Cross-Platform Support
- Module C1: Onboarding
- Module C2: CloudKit Sync

### Sprint 4 (Days 13-15)
**In Parallel**:
- Module C3: Advanced Search & History
- Module C4: Analytics & Insights (if desired)
- Bug fixes and polish
- App Store preparation

---

## Key Integration Points

### Integration Point 1: Data Layer → UI
- Once Module A1 is complete, Module A3 switches from mock data to real data
- No code changes needed if proper abstraction is in place

### Integration Point 2: Backend → Client
- Once Module A2 is complete, client modules (B1, B2, B3) connect to real API
- Use environment variables for API URL (local dev vs production)

### Integration Point 3: Widget → Main App
- Module A4 needs Module A1 for shared data models
- Use App Groups to share SwiftData container

### Integration Point 4: CloudKit → SwiftData
- Module C2 wraps around Module A1
- SwiftData can work independently before CloudKit is ready

---

## Testing Strategy (Per Module)

Each module should include:
- Unit tests for business logic
- UI tests for user-facing features (iOS modules)
- API tests for backend endpoints
- Widget preview tests
- Notification tests (using notification simulator)

---

## Deployment Checklist

### Vercel Backend
- [ ] Environment variables configured
- [ ] Rate limiting on AI endpoints
- [ ] Error logging (Sentry or similar)
- [ ] Production domain configured

### iOS App
- [ ] App Store Connect setup
- [ ] Screenshots for all device sizes
- [ ] App privacy details filled out
- [ ] TestFlight beta testing
- [ ] App Review preparation (demo video/account if needed)

### CloudKit
- [ ] Production CloudKit container enabled
- [ ] CloudKit Dashboard schema deployed
- [ ] Subscription setup for push notifications

---

## Open Questions to Resolve

1. **AI Rephrasing Frequency**: Daily rephrase for all intentions or just weekly/monthly?
2. **Placeholder Intentions**: Should they be AI-generated immediately or after 1 week?
3. **Theme Sharing**: Can users share custom themes with others?
4. **Subscription Model**: Are AI features free or premium?
5. **Data Retention**: How long to keep intention history (forever or configurable)?
6. **Widget Update Frequency**: How often should widget timeline refresh?

---

## File Structure (Proposed)

```
Daily Intentions/
├── Models/
│   ├── Intention.swift
│   ├── IntentionTheme.swift
│   └── UserPreferences.swift
├── ViewModels/
│   ├── IntentionsViewModel.swift
│   ├── WidgetViewModel.swift
│   └── NotificationViewModel.swift
├── Views/
│   ├── Main/
│   │   ├── IntentionsListView.swift
│   │   ├── IntentionDetailView.swift
│   │   └── NewIntentionView.swift
│   ├── Components/
│   │   ├── IntentionRowView.swift
│   │   ├── ThemePickerView.swift
│   │   └── ScopeSelector.swift
│   ├── Onboarding/
│   │   └── OnboardingView.swift
│   └── Settings/
│       ├── SettingsView.swift
│       └── NotificationSettingsView.swift
├── Services/
│   ├── CloudKitSyncManager.swift
│   ├── NotificationManager.swift
│   ├── AIService.swift
│   └── IntentionRepository.swift
├── Widgets/
│   ├── IntentionWidget.swift
│   ├── IntentionWidgetProvider.swift
│   └── IntentionWidgetEntryView.swift
├── Extensions/
│   └── NotificationService/
└── Supporting Files/
    ├── Theme.swift
    └── Constants.swift
```

---

## Estimated Complexity

**Total Development Time**: 3-4 weeks (with 2-3 developers working in parallel)
**High Risk Areas**:
- CloudKit sync conflict resolution
- Widget refresh reliability
- AI API cost management
- Cross-platform testing

**Low Risk Areas**:
- Basic CRUD operations
- UI development (SwiftUI is well-documented)
- Notification setup
