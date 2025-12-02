# Chat 6: Onboarding Experience

## Your Mission
Create a delightful first-launch onboarding experience that teaches users how to use the app, shows example intentions, and guides them through initial setup.

## Context
When users first open the app, they should see a brief onboarding flow (3-5 screens) that explains the app's value, demonstrates how intentions work, and helps them create their first intention. Make it skippable and never show it again.

## Your Scope - FILES YOU OWN

Create these files in `Daily Intentions/Views/Onboarding/`:
```
Views/Onboarding/
├── OnboardingContainerView.swift (main coordinator)
├── OnboardingPageView.swift (generic page template)
├── Pages/
│   ├── WelcomePage.swift
│   ├── HowItWorksPage.swift
│   ├── WidgetSetupPage.swift
│   ├── NotificationPermissionPage.swift
│   └── FirstIntentionPage.swift
└── Components/
    ├── OnboardingPageIndicator.swift
    └── ExampleIntentionCard.swift
```

Create `Daily Intentions/Utilities/`:
```
Utilities/
└── OnboardingManager.swift
```

## What You Need to Build

### 1. Onboarding Flow (5 Pages)

#### Page 1: Welcome
```
┌──────────────────────────────────┐
│                                  │
│         [App Icon/Logo]          │
│                                  │
│     Daily Intentions             │
│                                  │
│   Set intentions. Stay focused.  │
│   Build a meaningful life.       │
│                                  │
│         [Continue] [Skip]        │
│              • ○ ○ ○ ○           │
└──────────────────────────────────┘
```
- App icon or custom illustration
- Tagline explaining app value
- Continue button (goes to next page)
- Skip button (goes straight to app)
- Page indicator at bottom

#### Page 2: How It Works
```
┌──────────────────────────────────┐
│                                  │
│   [Illustration: Calendar]       │
│                                  │
│   Set intentions for your        │
│   day, week, or month            │
│                                  │
│   ┌────────────────────────┐    │
│   │ DAY: Be present        │    │
│   ├────────────────────────┤    │
│   │ WEEK: Focus on health  │    │
│   ├────────────────────────┤    │
│   │ MONTH: Practice growth │    │
│   └────────────────────────┘    │
│                                  │
│         [Continue] [Skip]        │
│              ○ • ○ ○ ○           │
└──────────────────────────────────┘
```
- Explain three scopes: Day, Week, Month
- Show example intentions in cards
- Explain hierarchy (Day overrides Week overrides Month)
- Visual examples

#### Page 3: Widget Setup
```
┌──────────────────────────────────┐
│                                  │
│   [Image: Widget on home screen] │
│                                  │
│   Your intention,                │
│   always visible                 │
│                                  │
│   Add a widget to your home      │
│   screen or lock screen to keep  │
│   your intention in sight        │
│                                  │
│         [Continue] [Skip]        │
│              ○ ○ • ○ ○           │
└──────────────────────────────────┘
```
- Screenshot or mockup of widget
- Explain widget value (always visible reminder)
- Optional: "Add Widget" button (opens widget gallery)
- Mention customization options (themes, fonts)

#### Page 4: Notification Permission
```
┌──────────────────────────────────┐
│                                  │
│   [Icon: Bell]                   │
│                                  │
│   Stay on track with reminders   │
│                                  │
│   Get gentle reminders to set    │
│   your daily, weekly, or monthly │
│   intentions                     │
│                                  │
│   [Enable Notifications]         │
│   [Maybe Later]                  │
│                                  │
│              ○ ○ ○ • ○           │
└──────────────────────────────────┘
```
- Request notification permission
- Explain value of reminders
- "Enable Notifications" button (calls system permission dialog)
- "Maybe Later" button (skips, can enable later in settings)

#### Page 5: Create First Intention
```
┌──────────────────────────────────┐
│                                  │
│   Set your first intention       │
│                                  │
│   ┌────────────────────────────┐│
│   │ What do you want to focus  ││
│   │ on today?                  ││
│   │                            ││
│   │ [Text field...]            ││
│   │                            ││
│   └────────────────────────────┘│
│                                  │
│   [Day] [Week] [Month]           │
│                                  │
│   [Get Started]                  │
│                                  │
│              ○ ○ ○ ○ •           │
└──────────────────────────────────┘
```
- Simple text field for first intention
- Scope selector (default to Day)
- "Get Started" button (saves intention and completes onboarding)
- Optional: Example suggestions below ("Tap to use")

### 2. Onboarding Manager

```swift
@Observable
class OnboardingManager {
    static let shared = OnboardingManager()

    private let hasSeenOnboardingKey = "hasSeenOnboarding"

    var hasCompletedOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: hasSeenOnboardingKey) }
        set { UserDefaults.standard.set(newValue, forKey: hasSeenOnboardingKey) }
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
    }

    func resetOnboarding() {
        // For testing - reset onboarding
        hasCompletedOnboarding = false
    }
}
```

### 3. OnboardingContainerView

```swift
struct OnboardingContainerView: View {
    @State private var currentPage = 0
    @Environment(\.dismiss) private var dismiss

    let pages: [any View] = [
        WelcomePage(),
        HowItWorksPage(),
        WidgetSetupPage(),
        NotificationPermissionPage(),
        FirstIntentionPage()
    ]

    var body: some View {
        ZStack {
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    AnyView(pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            VStack {
                HStack {
                    Spacer()
                    Button("Skip") {
                        completeOnboarding()
                    }
                    .padding()
                }
                Spacer()
            }

            VStack {
                Spacer()
                OnboardingPageIndicator(
                    currentPage: currentPage,
                    pageCount: pages.count
                )
                .padding(.bottom, 40)
            }
        }
    }

    func nextPage() {
        if currentPage < pages.count - 1 {
            withAnimation {
                currentPage += 1
            }
        } else {
            completeOnboarding()
        }
    }

    func completeOnboarding() {
        OnboardingManager.shared.completeOnboarding()
        dismiss()
    }
}
```

### 4. Example Intention Cards

Show inspiring examples throughout onboarding:

```swift
struct ExampleIntention {
    let text: String
    let scope: IntentionScope
    let category: String
}

extension ExampleIntention {
    static let examples = [
        // Personal Growth
        ExampleIntention(text: "Practice gratitude daily", scope: .day, category: "Growth"),
        ExampleIntention(text: "Read for 30 minutes", scope: .day, category: "Learning"),
        ExampleIntention(text: "Be present with loved ones", scope: .day, category: "Relationships"),

        // Health & Wellness
        ExampleIntention(text: "Move my body joyfully", scope: .day, category: "Health"),
        ExampleIntention(text: "Choose nourishing foods", scope: .week, category: "Health"),
        ExampleIntention(text: "Prioritize rest and recovery", scope: .week, category: "Wellness"),

        // Productivity
        ExampleIntention(text: "Focus on deep work", scope: .day, category: "Productivity"),
        ExampleIntention(text: "Complete one important task", scope: .day, category: "Productivity"),
        ExampleIntention(text: "Launch my project", scope: .month, category: "Goals"),

        // Mindfulness
        ExampleIntention(text: "Start the day with meditation", scope: .day, category: "Mindfulness"),
        ExampleIntention(text: "Practice mindful breathing", scope: .week, category: "Mindfulness"),
        ExampleIntention(text: "Cultivate inner peace", scope: .month, category: "Mindfulness"),

        // Creativity
        ExampleIntention(text: "Create something new", scope: .day, category: "Creativity"),
        ExampleIntention(text: "Explore a creative hobby", scope: .week, category: "Creativity"),
        ExampleIntention(text: "Finish my creative project", scope: .month, category: "Creativity"),
    ]
}

struct ExampleIntentionCard: View {
    let intention: ExampleIntention
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(intention.scope.rawValue.uppercased())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(intention.category)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(intention.text)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}
```

### 5. Notification Permission Page Logic

```swift
struct NotificationPermissionPage: View {
    @State private var permissionGranted = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "bell.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue)

            Text("Stay on track with reminders")
                .font(.title2)
                .fontWeight(.bold)

            Text("Get gentle reminders to set your daily, weekly, or monthly intentions")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    requestNotificationPermission()
                } label: {
                    Text("Enable Notifications")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }

                Button("Maybe Later") {
                    // Continue without notifications
                    // Can enable later in settings
                }
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
        }
    }

    func requestNotificationPermission() {
        Task {
            let granted = await NotificationManager.shared.requestAuthorization()
            permissionGranted = granted

            if granted {
                // Auto-advance to next page after brief delay
                try? await Task.sleep(nanoseconds: 500_000_000)
                // Trigger next page navigation
            }
        }
    }
}
```

### 6. First Intention Page

```swift
struct FirstIntentionPage: View {
    @State private var intentionText = ""
    @State private var selectedScope: IntentionScope = .day
    @State private var showingSuggestions = true

    let suggestions = Array(ExampleIntention.examples.prefix(3))

    var body: some View {
        VStack(spacing: 24) {
            Text("Set your first intention")
                .font(.title2)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 12) {
                Text("What do you want to focus on?")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                TextField("Enter your intention...", text: $intentionText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...5)
                    .onChange(of: intentionText) {
                        showingSuggestions = intentionText.isEmpty
                    }
            }
            .padding(.horizontal)

            // Scope selector
            Picker("Scope", selection: $selectedScope) {
                ForEach(IntentionScope.allCases, id: \.self) { scope in
                    Text(scope.rawValue).tag(scope)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            if showingSuggestions {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Or try one of these:")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)

                    ForEach(suggestions, id: \.text) { suggestion in
                        ExampleIntentionCard(intention: suggestion) {
                            intentionText = suggestion.text
                            selectedScope = suggestion.scope
                        }
                        .padding(.horizontal)
                    }
                }
            }

            Spacer()

            Button {
                createFirstIntention()
            } label: {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(intentionText.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(12)
            }
            .disabled(intentionText.isEmpty)
            .padding(.horizontal)
        }
        .padding(.vertical)
    }

    func createFirstIntention() {
        // Create intention using repository
        // Complete onboarding
        OnboardingManager.shared.completeOnboarding()
        // Dismiss and show main app
    }
}
```

### 7. App Integration

In `Daily_IntentionsApp.swift`:
```swift
@main
struct Daily_IntentionsApp: App {
    @State private var showOnboarding = !OnboardingManager.shared.hasCompletedOnboarding

    var body: some Scene {
        WindowGroup {
            ContentView()
                .fullScreenCover(isPresented: $showOnboarding) {
                    OnboardingContainerView()
                }
        }
    }
}
```

### 8. Animations & Transitions

Add smooth transitions between pages:
```swift
.transition(.asymmetric(
    insertion: .move(edge: .trailing),
    removal: .move(edge: .leading)
))
```

Add subtle animations for elements:
```swift
.onAppear {
    withAnimation(.easeIn(duration: 0.5)) {
        // Fade in content
    }
}
```

## Integration Points

### What Others Need From You
- **UI Team** needs: OnboardingContainerView to show on first launch
- **Notification Team** needs: Coordinate on permission request page

### What You Need From Others
- **Data Team** will provide: Repository to save first intention
- **Notification Team** will provide: NotificationManager for permission request
- **UI Team** will provide: Navigation flow after onboarding completes

## Testing

### Test Cases
- [ ] Onboarding shows on first launch
- [ ] Onboarding doesn't show on subsequent launches
- [ ] Skip button works from any page
- [ ] Page indicator updates correctly
- [ ] Swiping between pages works
- [ ] Notification permission dialog appears
- [ ] First intention saves correctly
- [ ] Example intentions populate text field on tap
- [ ] Can't submit empty intention
- [ ] Onboarding dismisses after completion
- [ ] Onboarding can be reset (for testing)

### Visual Testing
- Test on different device sizes (iPhone SE, Pro Max, iPad)
- Test in light and dark mode
- Test with different text sizes (accessibility)
- Test landscape orientation (should work or be locked to portrait)

## Constraints
- Keep onboarding under 2 minutes (user attention span)
- Make every page skippable
- Don't require any actions (optional onboarding)
- Support iOS 17+, macOS 14+
- Graceful degradation if permissions denied

## Deliverables
1. Complete 5-page onboarding flow
2. OnboardingManager for persistence
3. Example intention library (15-20 examples)
4. Smooth page transitions and animations
5. Notification permission integration
6. First intention creation
7. Skip functionality
8. Light/dark mode support
9. Responsive layouts for all devices
10. Test/reset functionality for development

## Design Guidelines
- Use SF Symbols for icons
- Consistent spacing and padding
- Clear typography hierarchy
- Subtle animations (not distracting)
- Keep text concise (under 20 words per section)
- Use illustrations or screenshots where helpful
- Warm, friendly tone in copy

## Nice-to-Haves (if time permits)
- Animated illustrations
- Interactive elements (swipe gestures, taps)
- Confetti animation when completing onboarding
- Video demo instead of static images
- Personalization (ask user's name)
- More example intentions (50+)
- Category-based example filtering
- Preview of widget customization

**Start by building the page structure and navigation flow, then fill in content for each page, and finally add polish with animations and example intentions.**
