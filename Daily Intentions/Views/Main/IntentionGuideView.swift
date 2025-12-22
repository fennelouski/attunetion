//
//  IntentionGuideView.swift
//  Daily Intentions
//
//  Created by Nathan Fennel on 12/19/25.
//  Interactive guide that walks users through creating good intentions
//

import SwiftUI
import SwiftData

/// Interactive guide that walks users through creating good intentions
struct IntentionGuideView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme

    @State private var viewModel: IntentionsViewModel

    @State private var currentStep = 0
    @State private var monthlyIntention: String = ""
    @State private var weeklyIntention: String = ""
    @State private var dailyIntention: String = ""
    @State private var showingNewIntention = false
    @State private var newIntentionScope: IntentionScope = .day
    @State private var newIntentionText: String = ""
    @State private var lightbulbIconIndex = 0
    @State private var calendarIconIndex = 0
    @State private var weeklyIconIndex = 0
    @State private var dailyIconIndex = 0

    private let weeklyIcons = ["7.lane", "7.square", "7.circle", "7.square.fill", "7.circle.fill"]
    @State private var goodExampleIndex = 0
    @State private var badExampleIndex = 0
    @State private var lastGoodTapTime: Date?
    @State private var lastBadTapTime: Date?
    @State private var quickIdeasPageIndex: [IntentionScope: Int] = [.month: 0, .week: 0, .day: 0]
    @State private var quickIdeasPages: [IntentionScope: [[String]]] = [:]
    @State private var selectedIntentionPack: IntentionPack? = nil
    @State private var showingAIGenerator = false
    @State private var showingPackPreview: IntentionPack? = nil

    init(modelContext: ModelContext) {
        _viewModel = State(initialValue: IntentionsViewModel(modelContext: modelContext))
        _quickIdeasPages = State(initialValue: [:])
        _quickIdeasPageIndex = State(initialValue: [.month: 0, .week: 0, .day: 0])
    }

    private let lightbulbIcons = ["lightbulb", "lightbulb.min", "lightbulb.max", "lightbulb.max.fill", "lightbulb.min.fill", "lightbulb.fill"]

    private var goodExamples: [String] {
        [
            String(localized: "Practice gratitude by reflecting on what I'm thankful for"),
            String(localized: "Move my body regularly throughout the week"),
            String(localized: "End my day with reading"),
            String(localized: "Connect with friends and family daily"),
            String(localized: "Start each morning with intention"),
            String(localized: "Focus on what matters most before distractions"),
            String(localized: "Connect with nature during breaks"),
            String(localized: "Create space for reflection each evening"),
            String(localized: "Show kindness to others"),
            String(localized: "Be fully present with my partner"),
            String(localized: "Stay open to learning and new ideas"),
            String(localized: "Return to my breath when I feel stressed")
        ]
    }

    private var badExamples: [String] {
        [
            String(localized: "Be happy"),
            String(localized: "Work harder"),
            String(localized: "Be better"),
            String(localized: "Do more"),
            String(localized: "Change everything"),
            String(localized: "Fix my life"),
            String(localized: "Stop being lazy"),
            String(localized: "Be perfect"),
            String(localized: "Never make mistakes"),
            String(localized: "Always be positive"),
            String(localized: "Have no stress"),
            String(localized: "Be successful")
        ]
    }

    private var steps: [GuideStep] {
        [
            GuideStep(
                title: String(localized: "What Makes a Good Intention?"),
                description: String(localized: "Intentions are personal commitments that guide your actions. They work best when they're:\n\n  • Specific and actionable\n  • Positive and meaningful to you\n  • Realistic for the timeframe\n  • Focused on what you can control"),
                icon: "lightbulb.fill",
                showExamples: true
            ),
            GuideStep(
                title: String(localized: "Set Your Monthly Intention"),
                description: String(localized: "Think big picture. What do you want to focus on this month? This is your overarching theme that guides your weekly and daily intentions."),
                icon: "calendar",
                scope: .month,
                placeholder: String(localized: "e.g., Build healthier habits")
            ),
            GuideStep(
                title: String(localized: "Set Your Weekly Intention"),
                description: String(localized: "Break down your monthly intention into weekly focus. What will you prioritize this week?"),
                icon: "calendar.badge.clock",
                scope: .week,
                placeholder: String(localized: "e.g., Move my body regularly")
            ),
            GuideStep(
                title: String(localized: "Set Your Daily Intention"),
                description: String(localized: "Make it present and meaningful today. What will you focus on today?"),
                icon: "sun.max.fill",
                scope: .day,
                placeholder: String(localized: "e.g., Move my body")
            ),
            GuideStep(
                title: String(localized: "You're All Set!"),
                description: String(localized: "You've created your first intentions! They'll appear on your home screen and help keep you focused. You can always add more or edit existing ones."),
                icon: "checkmark.circle.fill",
                isComplete: true
            )
        ]
    }

    private var currentGuideStep: GuideStep {
        steps[currentStep]
    }

    private var progress: Double {
        Double(currentStep + 1) / Double(steps.count)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                VStack(spacing: 0) {
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(AppThemeManager.shared.secondaryTextColor(for: colorScheme).opacity(0.2))

                            Rectangle()
                                .fill(AppThemeManager.shared.accentColor(for: colorScheme))
                                .frame(width: geometry.size.width * progress)
                        }
                    }
                    .frame(height: 4)
                    #if os(macOS)
                    .padding(.top, 20)
                    #endif

                    // Content with gradient fade
                    ZStack {
                        ScrollView {
                            VStack(spacing: 32) {
                            // Icon and title
                            VStack(spacing: 16) {
                                if currentStep == 0 {
                                    AnimatedLightbulbIcon(
                                        iconIndex: lightbulbIconIndex,
                                        icon: lightbulbIcons[lightbulbIconIndex],
                                        colorScheme: colorScheme
                                    )
                                } else if currentStep == 1 {
                                    // Monthly intention step - use calendar icons
                                    AnimatedCalendarIcon(
                                        iconIndex: calendarIconIndex,
                                        colorScheme: colorScheme
                                    )
                                } else if currentStep == 2 {
                                    // Weekly intention step - use 7-based icons
                                    AnimatedWeeklyIcon(
                                        iconIndex: weeklyIconIndex,
                                        icon: weeklyIcons[weeklyIconIndex],
                                        colorScheme: colorScheme
                                    )
                                } else if currentStep == 3 {
                                    // Daily intention step - use sunrise/sunset icons
                                    AnimatedDailyIcon(
                                        iconIndex: dailyIconIndex,
                                        colorScheme: colorScheme
                                    )
                                } else {
                                    Image(systemName: currentGuideStep.icon)
                                        .font(.system(size: 64, weight: .ultraLight))
                                        .foregroundColor(AppThemeManager.shared.accentColor(for: colorScheme))
                                        .frame(width: 64, height: 64)
                                }

                                Text(currentGuideStep.title)
                                    .font(.system(size: 24, weight: .light, design: .default))
                                    .foregroundColor(AppThemeManager.shared.primaryTextColor(for: colorScheme))
                                    .multilineTextAlignment(.center)

                                Text(currentGuideStep.description)
                                    .font(.system(size: 14, weight: .regular, design: .default))
                                    .foregroundColor(AppThemeManager.shared.secondaryTextColor(for: colorScheme))
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(4)
                                    .padding(.horizontal, 40)
                            }
                            .padding(.top, 40)

                            // Examples (for step 0)
                            if currentStep == 0 && currentGuideStep.showExamples {
                                VStack(alignment: .leading, spacing: 16) {
                                    InteractiveExampleCard(
                                        title: String(localized: "Good Example"),
                                        examples: goodExamples,
                                        currentIndex: $goodExampleIndex,
                                        lastTapTime: $lastGoodTapTime,
                                        isGood: true,
                                        colorScheme: colorScheme
                                    )

                                    InteractiveExampleCard(
                                        title: String(localized: "Too Vague"),
                                        examples: badExamples,
                                        currentIndex: $badExampleIndex,
                                        lastTapTime: $lastBadTapTime,
                                        isGood: false,
                                        colorScheme: colorScheme
                                    )
                                }
                                .padding(.horizontal, 40)
                            }

                            // Intention input (for steps 1-3)
                            if let scope = currentGuideStep.scope, currentStep >= 1 && currentStep <= 3 {
                                VStack(spacing: 16) {
                                    TextField(
                                        currentGuideStep.placeholder ?? String(localized: "Enter your intention..."),
                                        text: bindingForScope(scope),
                                        axis: .vertical
                                    )
                                    #if !os(watchOS)
                                    .textFieldStyle(.roundedBorder)
                                    #endif
                                    .lineLimit(3...5)
                                    .multilineTextAlignment(.leading)
                                    .tint(AppThemeManager.shared.accentColor(for: colorScheme))
                                    .padding(.horizontal, 40)

                                    // Quick suggestions (always visible)
                                    QuickIdeasSection(
                                        colorScheme: colorScheme,
                                        scope: scope,
                                        pageIndex: Binding(
                                            get: { quickIdeasPageIndex[scope] ?? 0 },
                                            set: { quickIdeasPageIndex[scope] = $0 }
                                        ),
                                        pages: Binding(
                                            get: { quickIdeasPages[scope] ?? [] },
                                            set: { quickIdeasPages[scope] = $0 }
                                        ),
                                        onSelect: { suggestion in
                                            setTextForScope(scope, suggestion)
#if os(iOS)
                                            HapticFeedback.light()
#endif
                                        }
                                    )
                                    .padding(.horizontal, 40)
                                }
                            }

                            // Completion summary (for step 4)
                            if currentStep == 4 {
                                CompletionStepContent(
                                    monthlyIntention: monthlyIntention,
                                    weeklyIntention: weeklyIntention,
                                    dailyIntention: dailyIntention,
                                    selectedPack: $selectedIntentionPack,
                                    showingAIGenerator: $showingAIGenerator,
                                    showingPackPreview: $showingPackPreview,
                                    colorScheme: colorScheme
                                )
                                .padding(.horizontal, 40)
                            }

                            Spacer(minLength: 10)
                            }
                        }

                        // Gradient fade overlay at edges
                        VStack(spacing: 0) {
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    AppThemeManager.shared.backgroundColor(for: colorScheme),
                                    AppThemeManager.shared.backgroundColor(for: colorScheme).opacity(0)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 4)
                            .allowsHitTesting(false)

                            Spacer()

                            LinearGradient(
                                gradient: Gradient(colors: [
                                    AppThemeManager.shared.backgroundColor(for: colorScheme).opacity(0),
                                    AppThemeManager.shared.backgroundColor(for: colorScheme)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 4)
                            .allowsHitTesting(false)
                        }
                        .ignoresSafeArea()
                    }

                    // Bottom buttons
                    VStack(spacing: 16) {
                        if currentStep < steps.count - 1 {
                            HStack(spacing: 12) {
                                // Back button (only show if not on first step)
                                if currentStep > 0 {
                                    SecondaryButton("Back") {
                                        handleBack()
                                    }
                                }

                                PrimaryButton(
                                    currentStep == 0 ? "Get Started" : "Continue"
                                ) {
                                    handleContinue()
                                }
                            }
                            .padding(.horizontal, 20)
                        } else {
                            HStack(spacing: 12) {
                                SecondaryButton("Back") {
                                    handleBack()
                                }

                                let hasIntentions = !monthlyIntention.isEmpty || !weeklyIntention.isEmpty || !dailyIntention.isEmpty

                                PrimaryButton(
                                    hasIntentions ? "Create Intentions" : "Done"
                                ) {
                                    createAllIntentions()
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Getting Started")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
            }
            .task {
                // Initialize quick ideas pages
                if quickIdeasPages.isEmpty {
                    initializeQuickIdeasPages()
                }
            }
            .task(id: currentStep) {
                // Update animated icons when step changes
                switch currentStep {
                case 0:
                    startLightbulbAnimation()
                case 1:
                    startCalendarAnimation()
                case 2:
                    startWeeklyAnimation()
                case 3:
                    startDailyAnimation()
                default:
                    break
                }
            }
        }
    }

    private func handleContinue() {
        if currentStep < steps.count - 1 {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                currentStep += 1
            }
        }
    }

    private func handleBack() {
        if currentStep > 0 {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                currentStep -= 1
            }
        }
    }

    private func createAllIntentions() {
        let calendar = Calendar.current
        let today = Date()

        if !monthlyIntention.isEmpty {
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: today)) ?? today
            let intention = Intention(
                text: monthlyIntention.trimmingCharacters(in: .whitespacesAndNewlines),
                scope: .month,
                date: monthStart
            )
            _ = try? viewModel.addIntention(intention)
        }

        if !weeklyIntention.isEmpty {
            let weekStart = calendar.startOfDay(for: today)
            let intention = Intention(
                text: weeklyIntention.trimmingCharacters(in: .whitespacesAndNewlines),
                scope: .week,
                date: weekStart
            )
            _ = try? viewModel.addIntention(intention)
        }

        if !dailyIntention.isEmpty {
            let intention = Intention(
                text: dailyIntention.trimmingCharacters(in: .whitespacesAndNewlines),
                scope: .day,
                date: today
            )
            _ = try? viewModel.addIntention(intention)
        }

        dismiss()
    }

    private func bindingForScope(_ scope: IntentionScope) -> Binding<String> {
        switch scope {
        case .month: return $monthlyIntention
        case .week: return $weeklyIntention
        case .day: return $dailyIntention
        }
    }

    private func setTextForScope(_ scope: IntentionScope, _ text: String) {
        switch scope {
        case .month: monthlyIntention = text
        case .week: weeklyIntention = text
        case .day: dailyIntention = text
        }
    }

    private func startLightbulbAnimation() {
        Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 800_000_000) // 0.8 seconds
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        lightbulbIconIndex = (lightbulbIconIndex + 1) % lightbulbIcons.count
                    }
                }
            }
        }
    }

    private func startCalendarAnimation() {
        Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_200_000_000) // 1.2 seconds
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        calendarIconIndex = (calendarIconIndex + 1) % 12
                    }
                }
            }
        }
    }

    private func startWeeklyAnimation() {
        Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1.0 seconds
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        weeklyIconIndex = (weeklyIconIndex + 1) % weeklyIcons.count
                    }
                }
            }
        }
    }

    private func startDailyAnimation() {
        Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 900_000_000) // 0.9 seconds
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        dailyIconIndex = (dailyIconIndex + 1) % 4
                    }
                }
            }
        }
    }

    private func suggestionsForScope(_ scope: IntentionScope) -> [String] {
        switch scope {
        case .month:
            return [
                "Build healthier habits",
                "Focus on personal growth",
                "Strengthen relationships",
                "Show up fully in my career",
                "Practice mindfulness daily",
                "Stay open to learning",
                "Create work-life balance",
                "Be mindful with my finances",
                "Engage with books regularly",
                "Spend quality time with family",
                "Explore new interests",
                "Manage stress with care",
                "Nourish my body well",
                "Prioritize restful sleep",
                "Stay curious and open",
                "Give back to others",
                "Explore new places",
                "Create meaningful routines",
                "Focus on mental health",
                "Show up for my body",
                "Communicate with intention",
                "Create order in my space",
                "Practice self-care",
                "Be intentional with money",
                "Build confidence",
                "Explore cooking",
                "Spend time in nature",
                "Be mindful of screen time",
                "Practice patience",
                "Be more present",
                "Express gratitude daily",
                "Take breaks when needed",
                "Engage with language learning",
                "Create space for reflection",
                "Build better habits",
                "Focus on creativity",
                "Be mindful of my body",
                "Stay hydrated",
                "Practice deep breathing",
                "Set boundaries",
                "Be kinder to myself",
                "Focus on what matters",
                "Show up despite resistance",
                "Build resilience",
                "Practice forgiveness",
                "Create order intentionally",
                "Focus on solutions",
                "Celebrate small wins",
                "Learn from mistakes",
                "Be more intentional"
            ]
        case .week:
            return [
                "Prioritize movement",
                "Connect with friends and loved ones",
                "Work with focus and purpose",
                "Stay open to learning",
                "Practice gratitude regularly",
                "Cook nourishing meals",
                "Create space for reading",
                "Move mindfully each day",
                "Reach out to family",
                "Practice acts of kindness",
                "Make meditation part of my routine",
                "Create space for reflection",
                "Try new recipes",
                "Spend time outdoors",
                "Show up fully for my work",
                "Engage with my hobbies",
                "Prioritize restful sleep",
                "Be mindful of social media use",
                "Express creativity",
                "Spend quality time with my partner",
                "Stay curious and open",
                "Practice deep breathing",
                "Create order in my space",
                "Plan nourishing meals",
                "Move my body regularly",
                "Read for enjoyment",
                "Take regular breaks",
                "Practice mindfulness",
                "Do things that bring me joy",
                "Focus on what matters most",
                "Spend time in nature",
                "Prioritize self-care",
                "Connect with the natural world",
                "Show kindness to others",
                "Practice patience",
                "Practice gratitude",
                "Be fully present in conversations",
                "Capture meaningful moments",
                "Cultivate gratitude",
                "Stay active",
                "Carve out time for myself",
                "Help others",
                "Stay open to new skills",
                "Manage stress mindfully",
                "Be compassionate with myself",
                "Focus on progress over perfection",
                "Celebrate small achievements",
                "Reflect and learn from experiences",
                "Use my time intentionally",
                "Find balance in my life"
            ]
        case .day:
            return [
                "Move my body mindfully",
                "Connect with a family member",
                "Create space for reading",
                "Show kindness to someone",
                "Take time to meditate",
                "Reflect on what I'm grateful for",
                "Stay hydrated",
                "Nourish my body well",
                "Return to my breath when stressed",
                "Spend time outside",
                "Show up despite resistance",
                "Engage with a hobby",
                "Connect with a friend",
                "Express creativity",
                "Prioritize movement",
                "Create conditions for restful sleep",
                "Be mindful of phone use",
                "Cook a nourishing meal",
                "Stay open to learning",
                "Practice mindfulness",
                "Help someone",
                "Spend time in nature",
                "Practice self-care",
                "Be present in the moment",
                "Express gratitude",
                "Take breaks when needed",
                "Do something fun",
                "Practice patience",
                "Be kind to myself",
                "Focus on what matters most",
                "Work with intention",
                "Practice deep breathing",
                "Move my body",
                "Spend quality time with someone",
                "Engage with learning",
                "Manage stress with care",
                "Be intentional",
                "Celebrate a small win",
                "Learn from today",
                "Practice balance",
                "Do something I enjoy",
                "Be present",
                "Practice gratitude",
                "Take care of myself",
                "Focus on progress",
                "Be patient",
                "Practice kindness",
                "Be mindful",
                "Do my best",
                "Be present today"
            ]
        }
    }

    private func initializeQuickIdeasPages() {
        let allSuggestions = [
            IntentionScope.month: suggestionsForScope(.month),
            IntentionScope.week: suggestionsForScope(.week),
            IntentionScope.day: suggestionsForScope(.day)
        ]

        // Create 10 pages of 5 suggestions each for each scope
        var pagesDict: [IntentionScope: [[String]]] = [:]

        for scope in [IntentionScope.month, .week, .day] {
            let suggestions = allSuggestions[scope] ?? []
            var scopePages: [[String]] = []

            for i in 0..<10 {
                let startIndex = i * 5
                let endIndex = min(startIndex + 5, suggestions.count)
                if startIndex < suggestions.count {
                    scopePages.append(Array(suggestions[startIndex..<endIndex]))
                } else {
                    // Wrap around if we run out
                    let wrapped = Array(suggestions.prefix(5))
                    scopePages.append(wrapped)
                }
            }

            // Shuffle pages for randomization
            scopePages.shuffle()
            pagesDict[scope] = scopePages
            // Randomize starting page for this scope
            quickIdeasPageIndex[scope] = Int.random(in: 0..<10)
        }

        quickIdeasPages = pagesDict
    }
}

#Preview {
    let container = try! ModelContainer(for: Intention.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    IntentionGuideView(modelContext: container.mainContext)
        .modelContainer(container)
}
