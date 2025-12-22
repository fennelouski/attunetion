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
                AppBackground(themeManager: AppThemeManager.shared)

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

struct GuideStep {
    let title: String
    let description: String
    let icon: String
    var scope: IntentionScope? = nil
    var placeholder: String? = nil
    var showExamples: Bool = false
    var isComplete: Bool = false
}

struct IntentionSummaryRow: View {
    @Environment(\.colorScheme) var colorScheme
    let scope: IntentionScope
    let text: String

    private var scopeIcon: String {
        switch scope {
        case .month: return "calendar"
        case .week: return "calendar.badge.clock"
        case .day: return "sun.max.fill"
        }
    }

    private var scopeColor: Color {
        switch scope {
        case .month: return .blue
        case .week: return .green
        case .day: return .orange
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(scopeColor.opacity(0.1))
                    .frame(width: 32, height: 32)

                Image(systemName: scopeIcon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(scopeColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(scope.rawValue.capitalized)
                    .font(.system(size: 14, weight: .medium, design: .default))
                    .foregroundColor(AppThemeManager.shared.primaryTextColor(for: colorScheme))

                Text(text)
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .foregroundColor(AppThemeManager.shared.secondaryTextColor(for: colorScheme))
                    .lineSpacing(2)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppThemeManager.shared.secondaryButtonBackground(for: colorScheme))
        )
    }
}

struct QuickIdeasSection: View {
    let colorScheme: ColorScheme
    let scope: IntentionScope
    @Binding var pageIndex: Int
    @Binding var pages: [[String]]
    let onSelect: (String) -> Void

    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false

    private var currentPage: [String] {
        guard pageIndex >= 0 && pageIndex < pages.count else {
            return []
        }
        return pages[pageIndex]
    }

    var body: some View {
        VStack(spacing: 12) {
            #if os(macOS)
            // Centered layout for macOS
            HStack {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        navigateToPrevious()
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppThemeManager.shared.accentColor(for: colorScheme))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)

                Spacer()

                Text("Quick ideas")
                    .font(.system(size: 13, weight: .medium, design: .default))
                    .foregroundColor(AppThemeManager.shared.secondaryTextColor(for: colorScheme))

                Spacer()

                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        navigateToNext()
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppThemeManager.shared.accentColor(for: colorScheme))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
            }
            #else
            // Original layout for iOS
            HStack {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        navigateToPrevious()
                    }
                    HapticFeedback.light()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppThemeManager.shared.accentColor(for: colorScheme))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)

                Text("Quick ideas:")
                    .font(.system(size: 13, weight: .medium, design: .default))
                    .foregroundColor(AppThemeManager.shared.secondaryTextColor(for: colorScheme))

                Spacer()

                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        navigateToNext()
                    }
                    HapticFeedback.light()
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppThemeManager.shared.accentColor(for: colorScheme))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
            }
            #endif

            // Content with swipe gesture and animation
            VStack(spacing: 12) {
                ForEach(currentPage, id: \.self) { suggestion in
                    Button(action: {
                        onSelect(suggestion)
                        #if os(iOS)
                        HapticFeedback.light()
                        #endif
                    }) {
                        Text(suggestion)
                            .font(.system(size: 13, weight: .regular, design: .default))
                            .foregroundColor(AppThemeManager.shared.accentColor(for: colorScheme))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(AppThemeManager.shared.secondaryButtonBackground(for: colorScheme))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .offset(x: dragOffset)
            .id(pageIndex) // Force view update on page change for animation
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isDragging = true
                        dragOffset = value.translation.width
                    }
                    .onEnded { value in
                        isDragging = false
                        let threshold: CGFloat = 50

                        if abs(value.translation.width) > threshold {
                            if value.translation.width > 0 {
                                // Swipe right - go to previous
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    navigateToPrevious()
                                }
                                #if os(iOS)
                                HapticFeedback.light()
                                #endif
                            } else {
                                // Swipe left - go to next
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    navigateToNext()
                                }
                                #if os(iOS)
                                HapticFeedback.light()
                                #endif
                            }
                        }

                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            dragOffset = 0
                        }
                    }
            )
        }
    }

    private func navigateToNext() {
        let nextIndex = pageIndex + 1

        if nextIndex >= pages.count {
            // Wrap around to beginning
            pageIndex = 0
        } else {
            pageIndex = nextIndex
        }
    }

    private func navigateToPrevious() {
        let prevIndex = pageIndex - 1

        if prevIndex < 0 {
            // Wrap around to end
            pageIndex = pages.count - 1
        } else {
            pageIndex = prevIndex
        }
    }
}

struct InteractiveExampleCard: View {
    let title: String
    let examples: [String]
    @Binding var currentIndex: Int
    @Binding var lastTapTime: Date?
    let isGood: Bool
    let colorScheme: ColorScheme

    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    @State private var tapTask: Task<Void, Never>?

    private var currentExample: String {
        examples[currentIndex]
    }

    private var iconName: String {
        isGood ? "checkmark.circle" : "xmark.circle"
    }

    private var titleFont: Font {
        isGood
            ? .system(size: 13, weight: .semibold, design: .rounded)
            : .system(size: 13, weight: .medium, design: .default)
    }

    private var textFont: Font {
        isGood
            ? .system(size: 14, weight: .regular, design: .rounded)
            : .system(size: 14, weight: .light, design: .default)
    }

    private var iconColor: Color {
        isGood
            ? AppThemeManager.shared.accentColor(for: colorScheme)
            : AppThemeManager.shared.secondaryTextColor(for: colorScheme).opacity(0.6)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: iconName)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(iconColor)
                Text(title)
                    .font(titleFont)
                    .foregroundColor(AppThemeManager.shared.primaryTextColor(for: colorScheme))
            }

            Text(currentExample)
                .font(textFont)
                .foregroundColor(AppThemeManager.shared.secondaryTextColor(for: colorScheme))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    colorScheme == .dark
                        ? AppThemeManager.shared.secondaryButtonBackground(for: colorScheme).opacity(0.4)
                        : Color.white.opacity(0.6)
                )
        )
        .offset(x: dragOffset)
        .simultaneousGesture(
            DragGesture()
                .onChanged { value in
                    isDragging = true
                    dragOffset = value.translation.width
                }
                .onEnded { value in
                    isDragging = false
                    let threshold: CGFloat = 50

                    if abs(value.translation.width) > threshold {
                        if value.translation.width > 0 {
                            // Swipe right - go to previous
                            navigateToPrevious()
                        } else {
                            // Swipe left - go to next
                            navigateToNext()
                        }
                    }

                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        dragOffset = 0
                    }
                }
        )
        .onTapGesture(count: 2) {
            // Double tap - go to previous
            tapTask?.cancel()
            navigateToPrevious()
            #if os(iOS)
            HapticFeedback.light()
            #endif
        }
        .onTapGesture(count: 1) {
            // Single tap - go to next (with delay to detect double tap)
            tapTask?.cancel()
            tapTask = Task {
                try? await Task.sleep(nanoseconds: 200_000_000) // 200ms delay
                if !Task.isCancelled {
                    await MainActor.run {
                        navigateToNext()
                        #if os(iOS)
                        HapticFeedback.light()
                        #endif
                    }
                }
            }
        }
    }

    private func navigateToNext() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            currentIndex = (currentIndex + 1) % examples.count
        }
    }

    private func navigateToPrevious() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            if currentIndex == 0 {
                currentIndex = examples.count - 1
            } else {
                currentIndex -= 1
            }
        }
    }
}

struct IntentionPack: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let monthly: String
    let weekly: String
    let daily: String
}

extension IntentionPack {
    static let packs: [IntentionPack] = [
        IntentionPack(
            name: "Wellness & Balance",
            description: "Focus on health, mindfulness, and self-care",
            monthly: "Prioritize my physical and mental well-being",
            weekly: "Make time for rest and recovery",
            daily: "Nourish my body and mind"
        ),
        IntentionPack(
            name: "Growth & Learning",
            description: "Embrace continuous learning and personal development",
            monthly: "Expand my knowledge and skills",
            weekly: "Dedicate time for learning",
            daily: "Stay curious and open"
        ),
        IntentionPack(
            name: "Relationships & Connection",
            description: "Strengthen bonds with loved ones and community",
            monthly: "Deepen meaningful relationships",
            weekly: "Reach out to family and friends",
            daily: "Show kindness and presence"
        ),
        IntentionPack(
            name: "Creativity & Expression",
            description: "Cultivate artistic expression and imagination",
            monthly: "Make space for creative exploration",
            weekly: "Engage with my creative side",
            daily: "Express myself authentically"
        ),
        IntentionPack(
            name: "Purpose & Contribution",
            description: "Make a positive impact in the world around you",
            monthly: "Align with my values and purpose",
            weekly: "Contribute to something bigger",
            daily: "Be of service to others"
        )
    ]
}

struct IntentionPackCard: View {
    let pack: IntentionPack
    let isSelected: Bool
    let colorScheme: ColorScheme
    let onSelect: () -> Void
    let onPreview: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Button(action: onSelect) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(pack.name)
                            .font(.system(size: 16, weight: .semibold, design: .default))
                            .foregroundColor(AppThemeManager.shared.primaryTextColor(for: colorScheme))

                        Spacer()

                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppThemeManager.shared.accentColor(for: colorScheme))
                        } else {
                            Image(systemName: "circle")
                                .foregroundColor(AppThemeManager.shared.secondaryTextColor(for: colorScheme))
                        }
                    }

                    Text(pack.description)
                        .font(.system(size: 14, weight: .regular, design: .default))
                        .foregroundColor(AppThemeManager.shared.secondaryTextColor(for: colorScheme))
                        .lineSpacing(2)
                }
                .padding(.vertical, 16)
                .padding(.leading, 16)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Divider()
                .frame(width: 1)
                .background(AppThemeManager.shared.secondaryTextColor(for: colorScheme).opacity(0.2))

            Button(action: onPreview) {
                Image(systemName: "eye")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppThemeManager.shared.accentColor(for: colorScheme))
                    .frame(width: 50, height: 50)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(AppThemeManager.shared.secondaryButtonBackground(for: colorScheme))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(
                            isSelected ? AppThemeManager.shared.accentColor(for: colorScheme) : Color.clear,
                            lineWidth: 2
                        )
                )
        )
    }
}

struct CompletionStepContent: View {
    let monthlyIntention: String
    let weeklyIntention: String
    let dailyIntention: String
    @Binding var selectedPack: IntentionPack?
    @Binding var showingAIGenerator: Bool
    @Binding var showingPackPreview: IntentionPack?
    let colorScheme: ColorScheme

    private var hasIntentions: Bool {
        !monthlyIntention.isEmpty || !weeklyIntention.isEmpty || !dailyIntention.isEmpty
    }

    var body: some View {
        VStack(spacing: 24) {
            if hasIntentions {
                // Show created intentions
                VStack(spacing: 20) {
                    Text(String(localized: "You're All Set!"))
                        .font(.system(size: 28, weight: .light, design: .default))
                        .foregroundColor(AppThemeManager.shared.primaryTextColor(for: colorScheme))

                    Text(String(localized: "You've created your first intentions! They'll appear on your home screen and help keep you focused. You can always add more or edit existing ones."))
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .foregroundColor(AppThemeManager.shared.secondaryTextColor(for: colorScheme))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)

                    VStack(spacing: 16) {
                        if !monthlyIntention.isEmpty {
                            IntentionSummaryCard(
                                scope: .month,
                                text: monthlyIntention,
                                colorScheme: colorScheme
                            )
                        }

                        if !weeklyIntention.isEmpty {
                            IntentionSummaryCard(
                                scope: .week,
                                text: weeklyIntention,
                                colorScheme: colorScheme
                            )
                        }

                        if !dailyIntention.isEmpty {
                            IntentionSummaryCard(
                                scope: .day,
                                text: dailyIntention,
                                colorScheme: colorScheme
                            )
                        }
                    }
                }
            } else {
                // Show options for creating intentions
                VStack(spacing: 24) {
                    Image(systemName: "target")
                        .font(.system(size: 64, weight: .ultraLight))
                        .foregroundColor(AppThemeManager.shared.accentColor(for: colorScheme))
                        .symbolEffect(.variableColor.iterative, options: .repeating.speed(0.5))
                        .symbolEffect(.pulse, options: .repeating.speed(0.5))

                    Text(String(localized: "Need Some Ideas?"))
                        .font(.system(size: 28, weight: .light, design: .default))
                        .foregroundColor(AppThemeManager.shared.primaryTextColor(for: colorScheme))

                    Text(String(localized: "If you're not sure where to start, here are some ready-to-use intention packs. You can preview them to see what they include."))
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .foregroundColor(AppThemeManager.shared.secondaryTextColor(for: colorScheme))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)

                    // Intention packs
                    VStack(spacing: 12) {
                        ForEach(IntentionPack.packs, id: \.name) { pack in
                            IntentionPackCard(
                                pack: pack,
                                isSelected: selectedPack?.name == pack.name,
                                colorScheme: colorScheme,
                                onSelect: {
                                    selectedPack = pack
                                    #if os(iOS)
                                    HapticFeedback.light()
                                    #endif
                                },
                                onPreview: {
                                    showingPackPreview = pack
                                    #if os(iOS)
                                    HapticFeedback.light()
                                    #endif
                                }
                            )
                        }
                    }

                    // AI option - simplified for Daily Intentions
                    Button(action: {
                        showingAIGenerator = true
                        #if os(iOS)
                        HapticFeedback.medium()
                        #endif
                    }) {
                        HStack {
                            Image(systemName: "target")
                                .font(.system(size: 16, weight: .medium))
                                .symbolEffect(.variableColor.iterative, options: .repeating.speed(0.5))
                                .symbolEffect(.pulse, options: .repeating.speed(0.5))
                            Text(String(localized: "Or tell us about yourself and we'll create custom intentions"))
                                .font(.system(size: 15, weight: .medium, design: .default))
                        }
                        .foregroundColor(AppThemeManager.shared.accentColor(for: colorScheme))
                        .padding(.vertical, 14)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(AppThemeManager.shared.accentColor(for: colorScheme).opacity(0.1))
                        )
                    }
                }
            }
        }
    }
}

struct IntentionSummaryCard: View {
    let scope: IntentionScope
    let text: String
    let colorScheme: ColorScheme

    private var scopeIcon: String {
        switch scope {
        case .month: return "calendar"
        case .week: return "calendar.badge.clock"
        case .day: return "sun.max.fill"
        }
    }

    private var scopeColor: Color {
        switch scope {
        case .month: return .blue
        case .week: return .green
        case .day: return .orange
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(scopeColor.opacity(0.1))
                    .frame(width: 32, height: 32)

                Image(systemName: scopeIcon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(scopeColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(scope.rawValue.capitalized)
                    .font(.system(size: 14, weight: .medium, design: .default))
                    .foregroundColor(AppThemeManager.shared.primaryTextColor(for: colorScheme))

                Text(text)
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .foregroundColor(AppThemeManager.shared.secondaryTextColor(for: colorScheme))
                    .lineSpacing(2)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppThemeManager.shared.secondaryButtonBackground(for: colorScheme))
        )
    }
}

struct IntentionPackCard: View {
    let pack: IntentionPack
    let isSelected: Bool
    let colorScheme: ColorScheme
    let onSelect: () -> Void
    let onPreview: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Button(action: onSelect) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(pack.name)
                            .font(.system(size: 16, weight: .semibold, design: .default))
                            .foregroundColor(AppThemeManager.shared.primaryTextColor(for: colorScheme))

                        Spacer()

                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppThemeManager.shared.accentColor(for: colorScheme))
                        } else {
                            Image(systemName: "circle")
                                .foregroundColor(AppThemeManager.shared.secondaryTextColor(for: colorScheme))
                        }
                    }

                    Text(pack.description)
                        .font(.system(size: 14, weight: .regular, design: .default))
                        .foregroundColor(AppThemeManager.shared.secondaryTextColor(for: colorScheme))
                        .lineSpacing(2)
                }
                .padding(.vertical, 16)
                .padding(.leading, 16)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Divider()
                .frame(width: 1)
                .background(AppThemeManager.shared.secondaryTextColor(for: colorScheme).opacity(0.2))

            Button(action: onPreview) {
                Image(systemName: "eye")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppThemeManager.shared.accentColor(for: colorScheme))
                    .frame(width: 50, height: 50)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(AppThemeManager.shared.secondaryButtonBackground(for: colorScheme))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(
                            isSelected ? AppThemeManager.shared.accentColor(for: colorScheme) : Color.clear,
                            lineWidth: 2
                        )
                )
        )
    }
}

// Animated Icons
struct AnimatedLightbulbIcon: View {
    let iconIndex: Int
    let icon: String
    let colorScheme: ColorScheme
    @State private var isPulsing = false

    private var primaryColor: Color {
        AppThemeManager.shared.accentColor(for: colorScheme)
    }

    private var secondaryColor: Color {
        // Use a complementary color from the theme
        let accent = AppThemeManager.shared.accentColor(for: colorScheme)
        // Create a slightly lighter/different shade for variety
        return accent.opacity(0.7)
    }

    private var tertiaryColor: Color {
        // Use another complementary color
        let accent = AppThemeManager.shared.accentColor(for: colorScheme)
        return accent.opacity(0.5)
    }

    var body: some View {
        ZStack {
            // Background glow
            Circle()
                .fill(primaryColor.opacity(0.1))
                .frame(width: 80, height: 80)
                .scaleEffect(isPulsing ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 1.5).repeatForever(), value: isPulsing)

            // Icon
            Image(systemName: icon)
                .font(.system(size: 32, weight: .ultraLight))
                .foregroundColor(primaryColor)
                .symbolEffect(.variableColor.iterative, options: .repeating.speed(0.8))
        }
        .onAppear {
            isPulsing = true
        }
    }
}

struct AnimatedCalendarIcon: View {
    let iconIndex: Int
    let colorScheme: ColorScheme

    private var primaryColor: Color {
        AppThemeManager.shared.accentColor(for: colorScheme)
    }

    var body: some View {
        ZStack {
            // Background glow
            Circle()
                .fill(primaryColor.opacity(0.1))
                .frame(width: 80, height: 80)

            // Calendar with animated date
            Image(systemName: "calendar")
                .font(.system(size: 32, weight: .ultraLight))
                .foregroundColor(primaryColor)
                .symbolEffect(.variableColor.iterative, options: .repeating.speed(0.6))
                .overlay(
                    Text("\(iconIndex + 1)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(primaryColor)
                        .offset(y: 2)
                )
        }
    }
}

struct AnimatedWeeklyIcon: View {
    let iconIndex: Int
    let icon: String
    let colorScheme: ColorScheme

    private var primaryColor: Color {
        AppThemeManager.shared.accentColor(for: colorScheme)
    }

    var body: some View {
        ZStack {
            // Background glow
            Circle()
                .fill(primaryColor.opacity(0.1))
                .frame(width: 80, height: 80)

            // Weekly icon
            Image(systemName: icon)
                .font(.system(size: 32, weight: .ultraLight))
                .foregroundColor(primaryColor)
                .symbolEffect(.variableColor.iterative, options: .repeating.speed(0.7))
        }
    }
}

struct AnimatedDailyIcon: View {
    let iconIndex: Int
    let colorScheme: ColorScheme

    private var primaryColor: Color {
        AppThemeManager.shared.accentColor(for: colorScheme)
    }

    private var dailyIcons = ["sunrise", "sun.max", "sunset", "moon.stars"]

    var body: some View {
        ZStack {
            // Background glow
            Circle()
                .fill(primaryColor.opacity(0.1))
                .frame(width: 80, height: 80)

            // Daily icon
            Image(systemName: dailyIcons[iconIndex % dailyIcons.count])
                .font(.system(size: 32, weight: .ultraLight))
                .foregroundColor(primaryColor)
                .symbolEffect(.variableColor.iterative, options: .repeating.speed(0.9))
        }
    }
}

struct CompletionStepContent: View {
    let monthlyIntention: String
    let weeklyIntention: String
    let dailyIntention: String
    @Binding var selectedPack: IntentionPack?
    @Binding var showingAIGenerator: Bool
    @Binding var showingPackPreview: IntentionPack?
    let colorScheme: ColorScheme

    private var hasIntentions: Bool {
        !monthlyIntention.isEmpty || !weeklyIntention.isEmpty || !dailyIntention.isEmpty
    }

    var body: some View {
        VStack(spacing: 24) {
            if hasIntentions {
                // Show created intentions
                VStack(spacing: 20) {
                    Text(String(localized: "You're All Set!"))
                        .font(.system(size: 28, weight: .light, design: .default))
                        .foregroundColor(AppThemeManager.shared.primaryTextColor(for: colorScheme))

                    Text(String(localized: "You've created your first intentions! They'll appear on your home screen and help keep you focused. You can always add more or edit existing ones."))
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .foregroundColor(AppThemeManager.shared.secondaryTextColor(for: colorScheme))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)

                    VStack(spacing: 16) {
                        if !monthlyIntention.isEmpty {
                            IntentionSummaryCard(
                                scope: .month,
                                text: monthlyIntention,
                                colorScheme: colorScheme
                            )
                        }

                        if !weeklyIntention.isEmpty {
                            IntentionSummaryCard(
                                scope: .week,
                                text: weeklyIntention,
                                colorScheme: colorScheme
                            )
                        }

                        if !dailyIntention.isEmpty {
                            IntentionSummaryCard(
                                scope: .day,
                                text: dailyIntention,
                                colorScheme: colorScheme
                            )
                        }
                    }
                }
            } else {
                // Show options for creating intentions
                VStack(spacing: 24) {
                    Image(systemName: "target")
                        .font(.system(size: 64, weight: .ultraLight))
                        .foregroundColor(AppThemeManager.shared.accentColor(for: colorScheme))
                        .symbolEffect(.variableColor.iterative, options: .repeating.speed(0.5))
                        .symbolEffect(.pulse, options: .repeating.speed(0.5))

                    Text(String(localized: "Need Some Ideas?"))
                        .font(.system(size: 28, weight: .light, design: .default))
                        .foregroundColor(AppThemeManager.shared.primaryTextColor(for: colorScheme))

                    Text(String(localized: "If you're not sure where to start, here are some ready-to-use intention packs. You can preview them to see what they include."))
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .foregroundColor(AppThemeManager.shared.secondaryTextColor(for: colorScheme))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)

                    // Intention packs
                    VStack(spacing: 12) {
                        ForEach(IntentionPack.packs, id: \.name) { pack in
                            IntentionPackCard(
                                pack: pack,
                                isSelected: selectedPack?.name == pack.name,
                                colorScheme: colorScheme,
                                onSelect: {
                                    selectedPack = pack
                                    #if os(iOS)
                                    HapticFeedback.light()
                                    #endif
                                },
                                onPreview: {
                                    showingPackPreview = pack
                                    #if os(iOS)
                                    HapticFeedback.light()
                                    #endif
                                }
                            )
                        }
                    }

                    // AI option - simplified for Daily Intentions
                    Button(action: {
                        showingAIGenerator = true
                        #if os(iOS)
                        HapticFeedback.medium()
                        #endif
                    }) {
                        HStack {
                            Image(systemName: "target")
                                .font(.system(size: 16, weight: .medium))
                                .symbolEffect(.variableColor.iterative, options: .repeating.speed(0.5))
                                .symbolEffect(.pulse, options: .repeating.speed(0.5))
                            Text(String(localized: "Or tell us about yourself and we'll create custom intentions"))
                                .font(.system(size: 15, weight: .medium, design: .default))
                        }
                        .foregroundColor(AppThemeManager.shared.accentColor(for: colorScheme))
                        .padding(.vertical, 14)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(AppThemeManager.shared.accentColor(for: colorScheme).opacity(0.1))
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: Intention.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    IntentionGuideView(modelContext: container.mainContext)
        .modelContainer(container)
}