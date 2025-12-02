# Daily Intentions - Parallel Development Prompts

This folder contains detailed prompts for 6 parallel development streams. Each prompt is designed to be completely independent, allowing different developers (or AI assistants) to work simultaneously without conflicts.

## How to Use These Prompts

1. **Start 6 separate chat sessions** (or assign to 6 different developers)
2. **Copy the entire contents** of each prompt file into a separate chat
3. **Each chat works independently** on their assigned module
4. **Coordinate at integration points** (defined in each prompt)

## Recommended Execution Order

### Sprint 1: Foundation (Start These in Parallel)

Start all of these on Day 1:

- **Chat 1**: Data Models & Repository Layer
  - File: `01_DataModels_Prompt.md`
  - Creates: Models, Repositories, CloudKit setup
  - Dependencies: None
  - Estimated time: 2-3 days

- **Chat 2**: Vercel Backend API
  - File: `02_Backend_Prompt.md`
  - Creates: AI endpoints, REST API
  - Dependencies: None (separate project)
  - Estimated time: 2-3 days

- **Chat 3**: Main App UI
  - File: `03_UI_Prompt.md`
  - Creates: All main screens, navigation
  - Dependencies: None (uses mock data initially)
  - Estimated time: 3-4 days

- **Chat 4**: Widget Extensions
  - File: `04_Widget_Prompt.md`
  - Creates: Home screen, lock screen widgets
  - Dependencies: Light dependency on Chat 1 (can use mocks)
  - Estimated time: 2-3 days

### Sprint 2: Features (Start These After Sprint 1)

Start all of these on Day 4:

- **Chat 5**: Notification System
  - File: `05_Notifications_Prompt.md`
  - Creates: Push notifications, inline replies
  - Dependencies: Light dependency on Chat 1
  - Estimated time: 2-3 days

- **Chat 6**: Onboarding Experience
  - File: `06_Onboarding_Prompt.md`
  - Creates: First-launch onboarding flow
  - Dependencies: Light dependencies on Chats 3 & 5
  - Estimated time: 2 days

## Integration Points

After each module is complete, integrate them in this order:

### Integration 1: Data → UI (Day 3-4)
- **Chats Involved**: 1 (Data) + 3 (UI)
- **Action**: Replace mock data in UI with real repositories
- **Test**: CRUD operations work in UI

### Integration 2: Data → Widget (Day 3-4)
- **Chats Involved**: 1 (Data) + 4 (Widget)
- **Action**: Connect widget to shared App Group data
- **Test**: Widget displays real intentions

### Integration 3: Backend → UI (Day 3-4)
- **Chats Involved**: 2 (Backend) + 3 (UI)
- **Action**: Connect AI features to real API endpoints
- **Test**: Theme generation, quote generation work

### Integration 4: Notifications → Data (Day 6-7)
- **Chats Involved**: 5 (Notifications) + 1 (Data)
- **Action**: Wire up inline reply to create real intentions
- **Test**: Creating intention from notification works

### Integration 5: Onboarding → Everything (Day 7-8)
- **Chats Involved**: 6 (Onboarding) + 1, 3, 5
- **Action**: Connect onboarding to real app flow
- **Test**: First launch experience complete

## File Ownership (Avoid Conflicts)

Each chat "owns" specific directories/files. **Never modify files owned by another chat.**

### Chat 1 (Data Models) Owns:
```
Daily Intentions/Models/
Daily Intentions/Services/IntentionRepository.swift
Daily Intentions/Services/ThemeRepository.swift
Daily Intentions/Services/UserPreferencesRepository.swift
```

### Chat 2 (Backend) Owns:
```
daily-intentions-backend/ (entire separate project)
```

### Chat 3 (UI) Owns:
```
Daily Intentions/Views/Main/
Daily Intentions/Views/Components/
Daily Intentions/Views/Settings/SettingsView.swift
Daily Intentions/ViewModels/IntentionsViewModel.swift
Daily Intentions/ViewModels/ThemeViewModel.swift
Daily Intentions/ContentView.swift (will modify this)
```

### Chat 4 (Widget) Owns:
```
IntentionWidget/ (entire widget target)
Daily Intentions.xcodeproj (widget target configuration)
```

### Chat 5 (Notifications) Owns:
```
Daily Intentions/Services/NotificationManager.swift
Daily Intentions/Services/NotificationHandler.swift
Daily Intentions/Views/Settings/NotificationSettingsView.swift
IntentionNotificationService/ (if creating notification service extension)
```

### Chat 6 (Onboarding) Owns:
```
Daily Intentions/Views/Onboarding/
Daily Intentions/Utilities/OnboardingManager.swift
```

## Shared Files (Coordinate Changes)

These files may need to be modified by multiple chats. Coordinate carefully:

- `Daily_IntentionsApp.swift` - App entry point (Chats 1, 5, 6 may modify)
- `Daily_Intentions.entitlements` - Capabilities (Chats 1, 4, 5 may modify)
- `Info.plist` - App configuration (Chats 4, 5 may modify)

**Best Practice**: Have one person/chat make all changes to shared files, or coordinate via Git branches.

## Communication Between Chats

Each prompt includes an "Integration Points" section describing:
- **What Others Need From You**: What you provide to other modules
- **What You Need From Others**: What you depend on

Use these sections to coordinate dependencies and interfaces.

## Testing Strategy

Each module should be tested independently before integration:

1. **Unit Tests**: Each chat writes unit tests for their code
2. **Integration Tests**: Test at integration points
3. **UI Tests**: Chat 3 (UI) writes UI tests for main flows
4. **Widget Tests**: Chat 4 (Widget) tests widget updates
5. **End-to-End Tests**: After all integrations, test complete flows

## Estimated Timeline

**With 6 developers/chats working in parallel:**
- Week 1: Foundation modules (Chats 1-4)
- Week 2: Feature modules (Chats 5-6) + Integrations
- Week 3: Testing, polish, bug fixes
- Week 4: App Store prep, deployment

**With fewer resources** (e.g., 2-3 developers), prioritize:
1. Chat 1 (Data) - Foundation for everything
2. Chat 3 (UI) - Core user experience
3. Chat 4 (Widget) - Key differentiator
4. Chat 2 (Backend) - AI features (can be MVP without these)
5. Chat 5 (Notifications) - Nice to have
6. Chat 6 (Onboarding) - Polish (can launch without this)

## Success Criteria

Each module is "done" when:
- [ ] All features in prompt are implemented
- [ ] Unit tests pass
- [ ] Code is documented
- [ ] No compiler warnings
- [ ] Works on iOS simulator and real device
- [ ] Integration points are clearly defined
- [ ] Handoff documentation written

## Questions?

If any prompt is unclear or you encounter conflicts:
1. Check the main `IMPLEMENTATION_PLAN.md` for context
2. Review the "Integration Points" section in your prompt
3. Coordinate with other chats via shared project communication channel
4. Make reasonable assumptions and document them

## Getting Started

1. Choose which chat you want to start
2. Open the corresponding prompt file
3. Copy the entire contents
4. Paste into a new Claude Code chat session
5. Let the chat read the project and start implementing

**Important**: Each chat should start by reading the existing project files to understand the structure before making changes.

Good luck! 🚀
