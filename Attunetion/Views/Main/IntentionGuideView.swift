//
//  IntentionGuideView.swift
//  Attunetion
//
//  Created for interactive intention creation guide
//

import SwiftUI
import SwiftData
#if os(macOS)
import AppKit
#endif

/// Interactive guide that walks users through creating good intentions
struct IntentionGuideView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager: AppThemeManager
    
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
    
    private let weeklyIcons = ["7.lane", "7.square", "7.calendar", "7.circle", "7.square.fill", "7.circle.fill"]
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
    
    private let goodExamples = [
        "Practice gratitude by writing 3 things I'm thankful for each day",
        "Exercise for 30 minutes, 3 times this week",
        "Read for 20 minutes before bed each night",
        "Call or text one friend or family member daily",
        "Spend 10 minutes each morning planning my day",
        "Complete one important task before checking email",
        "Take a 15-minute walk outside during lunch break",
        "Write in my journal for 5 minutes each evening",
        "Do one act of kindness for someone else today",
        "Spend quality time with my partner without phones",
        "Learn something new for 15 minutes each day",
        "Practice deep breathing for 5 minutes when stressed"
    ]
    
    private let badExamples = [
        "Be happy",
        "Work harder",
        "Be better",
        "Do more",
        "Change everything",
        "Fix my life",
        "Stop being lazy",
        "Be perfect",
        "Never make mistakes",
        "Always be positive",
        "Have no stress",
        "Be successful"
    ]
    
    private let steps = [
        GuideStep(
            title: "What Makes a Good Intention?",
            description: "Intentions are personal commitments that guide your actions. They work best when they're:\n\n  • Specific and actionable\n  • Positive and meaningful to you\n  • Realistic for the timeframe\n  • Focused on what you can control",
            icon: "lightbulb.fill",
            showExamples: true
        ),
        GuideStep(
            title: "Set Your Monthly Intention",
            description: "Think big picture. What do you want to focus on this month? This is your overarching theme that guides your weekly and daily intentions.",
            icon: "calendar",
            scope: .month,
            placeholder: "e.g., Build healthier habits"
        ),
        GuideStep(
            title: "Set Your Weekly Intention",
            description: "Break down your monthly goal into weekly actions. What specific step will you take this week?",
            icon: "calendar.badge.clock",
            scope: .week,
            placeholder: "e.g., Exercise 3 times this week"
        ),
        GuideStep(
            title: "Set Your Daily Intention",
            description: "Make it concrete and achievable today. What one thing will you do today to move toward your goals?",
            icon: "sun.max.fill",
            scope: .day,
            placeholder: "e.g., Go for a 20-minute walk"
        ),
        GuideStep(
            title: "You're All Set!",
            description: "You've created your first intentions! They'll appear on your home screen and help keep you focused. You can always add more or edit existing ones.",
            icon: "checkmark.circle.fill",
            isComplete: true
        )
    ]
    
    private var currentGuideStep: GuideStep {
        steps[currentStep]
    }
    
    private var progress: Double {
        Double(currentStep + 1) / Double(steps.count)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground(themeManager: themeManager)
                
                VStack(spacing: 0) {
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.2))
                            
                            Rectangle()
                                .fill(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                                .frame(width: geometry.size.width * progress)
                        }
                    }
                    .frame(height: 4)
                    
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
                                        themeManager: themeManager,
                                        colorScheme: colorScheme
                                    )
                                } else if currentStep == 1 {
                                    // Monthly intention step - use calendar icons
                                    AnimatedCalendarIcon(
                                        iconIndex: calendarIconIndex,
                                        themeManager: themeManager,
                                        colorScheme: colorScheme
                                    )
                                } else if currentStep == 2 {
                                    // Weekly intention step - use 7-based icons
                                    AnimatedWeeklyIcon(
                                        iconIndex: weeklyIconIndex,
                                        icon: weeklyIcons[weeklyIconIndex],
                                        themeManager: themeManager,
                                        colorScheme: colorScheme
                                    )
                                } else if currentStep == 3 {
                                    // Daily intention step - use sunrise/sunset icons
                                    AnimatedDailyIcon(
                                        iconIndex: dailyIconIndex,
                                        themeManager: themeManager,
                                        colorScheme: colorScheme
                                    )
                                } else {
                                    Image(systemName: currentGuideStep.icon)
                                        .font(.system(size: 64, weight: .ultraLight))
                                        .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                                        .frame(width: 64, height: 64)
                                }
                                
                                Text(currentGuideStep.title)
                                    .font(.system(size: 28, weight: .light, design: .default))
                                    .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                                    .multilineTextAlignment(.center)
                                
                                Text(currentGuideStep.description)
                                    .font(.system(size: 16, weight: .regular, design: .default))
                                    .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(4)
                                    .padding(.horizontal, 40)
                            }
                            .padding(.top, 40)
                            
                            // Examples (for step 0)
                            if currentStep == 0 && currentGuideStep.showExamples {
                                VStack(alignment: .leading, spacing: 16) {
                                    InteractiveExampleCard(
                                        themeManager: themeManager,
                                        title: "Good Example",
                                        examples: goodExamples,
                                        currentIndex: $goodExampleIndex,
                                        lastTapTime: $lastGoodTapTime,
                                        isGood: true
                                    )
                                    
                                    InteractiveExampleCard(
                                        themeManager: themeManager,
                                        title: "Too Vague",
                                        examples: badExamples,
                                        currentIndex: $badExampleIndex,
                                        lastTapTime: $lastBadTapTime,
                                        isGood: false
                                    )
                                }
                                .padding(.horizontal, 40)
                            }
                            
                            // Intention input (for steps 1-3)
                            if let scope = currentGuideStep.scope, currentStep >= 1 && currentStep <= 3 {
                                VStack(spacing: 16) {
                                    TextField(
                                        currentGuideStep.placeholder ?? "Enter your intention...",
                                        text: bindingForScope(scope),
                                        axis: .vertical
                                    )
                                    #if !os(watchOS)
                                    .textFieldStyle(.roundedBorder)
                                    #endif
                                    .lineLimit(3...5)
                                    .tint(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                                    .padding(.horizontal, 40)
                                    
                                    // Quick suggestions (always visible)
                                    QuickIdeasSection(
                                        themeManager: themeManager,
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
                                    themeManager: themeManager,
                                    colorScheme: colorScheme
                                )
                                .padding(.horizontal, 40)
                            }
                            
                            Spacer(minLength: 40)
                            }
                        }
                        
                        // Gradient fade overlay at edges
                        VStack(spacing: 0) {
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    themeManager.backgroundColor(for: colorScheme).toSwiftUIColor(),
                                    themeManager.backgroundColor(for: colorScheme).toSwiftUIColor().opacity(0)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 4)
                            .allowsHitTesting(false)
                            
                            Spacer()
                            
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    themeManager.backgroundColor(for: colorScheme).toSwiftUIColor().opacity(0),
                                    themeManager.backgroundColor(for: colorScheme).toSwiftUIColor()
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
                                    SecondaryButton("Back", themeManager: themeManager) {
                                        handleBack()
                                    }
                                }
                                
                                // Continue button (always enabled - users can skip intentions)
                                PrimaryButton(
                                    currentStep == 0 ? "Get Started" : "Continue",
                                    themeManager: themeManager
                                ) {
                                    handleContinue()
                                }
                            }
                            .padding(.horizontal, 40)
                        } else {
                            HStack(spacing: 12) {
                                // Back button on final step
                                SecondaryButton("Back", themeManager: themeManager) {
                                    handleBack()
                                }
                                
                                // Dynamic button based on whether intentions were created
                                let hasIntentions = !monthlyIntention.isEmpty || !weeklyIntention.isEmpty || !dailyIntention.isEmpty
                                let hasPack = selectedIntentionPack != nil
                                
                                PrimaryButton(
                                    hasIntentions || hasPack ? "Create Intentions" : "Done",
                                    themeManager: themeManager
                                ) {
                                    if hasIntentions || hasPack {
                                        createAllIntentions()
                                    } else {
                                        dismiss()
                                    }
                                }
                            }
                            .padding(.horizontal, 40)
                        }
                    }
                    .padding(.vertical, 24)
                    
                    // Page indicator
                    OnboardingPageIndicator(
                        currentPage: currentStep,
                        pageCount: steps.count,
                        themeManager: themeManager
                    )
                    .padding(.bottom, 16)
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
                    .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                }
            }
            .sheet(isPresented: $showingNewIntention) {
                NewIntentionView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingAIGenerator) {
                AIIntentionGeneratorView(
                    onComplete: { monthly, weekly, daily in
                        monthlyIntention = monthly
                        weeklyIntention = weekly
                        dailyIntention = daily
                        selectedIntentionPack = nil
                        showingAIGenerator = false
                    },
                    themeManager: themeManager
                )
            }
            .sheet(item: $showingPackPreview) { pack in
                IntentionPackPreviewView(
                    pack: pack,
                    themeManager: themeManager
                )
            }
            .task(id: currentStep) {
                if currentStep == 0 {
                    // Animate lightbulb icons with pulse animation
                    // Pulse twice (takes ~1.6 seconds at 0.8 speed), then pause, then change icon
                    // Slowed down by factor of 4: 2.4s * 4 = 9.6s
                    while currentStep == 0 {
                        // Wait for pulse animation to complete (2 pulses at ~0.8s each = ~1.6s)
                        // Then add a pause before changing
                        try? await Task.sleep(nanoseconds: 9_600_000_000) // 9.6 seconds total (slowed by 4x)
                        if currentStep == 0 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                lightbulbIconIndex = (lightbulbIconIndex + 1) % lightbulbIcons.count
                            }
                        }
                    }
                } else if currentStep == 1 {
                    // Animate calendar icons for monthly step
                    // Slowed down by factor of 4: 2.4s * 4 = 9.6s
                    while currentStep == 1 {
                        try? await Task.sleep(nanoseconds: 9_600_000_000) // 9.6 seconds total (slowed by 4x)
                        if currentStep == 1 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                calendarIconIndex = (calendarIconIndex + 1) % 2
                            }
                        }
                    }
                } else if currentStep == 2 {
                    // Animate weekly icons (7-based icons)
                    // Slowed down by factor of 4: 2.4s * 4 = 9.6s
                    while currentStep == 2 {
                        try? await Task.sleep(nanoseconds: 9_600_000_000) // 9.6 seconds total (slowed by 4x)
                        if currentStep == 2 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                weeklyIconIndex = (weeklyIconIndex + 1) % weeklyIcons.count
                            }
                        }
                    }
                } else if currentStep == 3 {
                    // Animate sunrise/sunset icons for daily step
                    // Slowed down by factor of 4: 2.4s * 4 = 9.6s
                    while currentStep == 3 {
                        try? await Task.sleep(nanoseconds: 9_600_000_000) // 9.6 seconds total (slowed by 4x)
                        if currentStep == 3 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                dailyIconIndex = (dailyIconIndex + 1) % 2
                            }
                        }
                    }
                } else {
                    lightbulbIconIndex = 0
                    calendarIconIndex = 0
                    weeklyIconIndex = 0
                    dailyIconIndex = 0
                }
            }
            .onAppear {
                // Initialize quick ideas pages
                if quickIdeasPages.isEmpty {
                    initializeQuickIdeasPages()
                }
            }
        }
    }
    
    private func handleContinue() {
        #if os(iOS)
        HapticFeedback.medium()
        #endif
        
        if currentStep < steps.count - 1 {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                currentStep += 1
            }
        }
    }
    
    private func handleBack() {
        #if os(iOS)
        HapticFeedback.light()
        #endif
        
        if currentStep > 0 {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                currentStep -= 1
            }
        }
    }
    
    private func createAllIntentions() {
        #if os(iOS)
        HapticFeedback.success()
        #endif
        
        let calendar = Calendar.current
        let today = Date()
        
        // Create intentions from pack if selected
        if let pack = selectedIntentionPack {
            if !pack.monthly.isEmpty {
                let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: today)) ?? today
                let intention = Intention(
                    text: pack.monthly,
                    scope: .month,
                    date: monthStart,
                    aiGenerated: false
                )
                _ = try? viewModel.addIntention(intention)
            }
            
            if !pack.weekly.isEmpty {
                let weekStart = calendar.startOfDay(for: today)
                let intention = Intention(
                    text: pack.weekly,
                    scope: .week,
                    date: weekStart,
                    aiGenerated: false
                )
                _ = try? viewModel.addIntention(intention)
            }
            
            if !pack.daily.isEmpty {
                let intention = Intention(
                    text: pack.daily,
                    scope: .day,
                    date: today,
                    aiGenerated: false
                )
                _ = try? viewModel.addIntention(intention)
            }
        } else {
            // Create user-entered intentions
            if !monthlyIntention.isEmpty {
                let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: today)) ?? today
                let intention = Intention(
                    text: monthlyIntention.trimmingCharacters(in: .whitespacesAndNewlines),
                    scope: .month,
                    date: monthStart,
                    aiGenerated: false
                )
                _ = try? viewModel.addIntention(intention)
            }
            
            if !weeklyIntention.isEmpty {
                let weekStart = calendar.startOfDay(for: today)
                let intention = Intention(
                    text: weeklyIntention.trimmingCharacters(in: .whitespacesAndNewlines),
                    scope: .week,
                    date: weekStart,
                    aiGenerated: false
                )
                _ = try? viewModel.addIntention(intention)
            }
            
            if !dailyIntention.isEmpty {
                let intention = Intention(
                    text: dailyIntention.trimmingCharacters(in: .whitespacesAndNewlines),
                    scope: .day,
                    date: today,
                    aiGenerated: false
                )
                _ = try? viewModel.addIntention(intention)
            }
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
    
    private func textForScope(_ scope: IntentionScope) -> String {
        switch scope {
        case .month: return monthlyIntention
        case .week: return weeklyIntention
        case .day: return dailyIntention
        }
    }
    
    private func setTextForScope(_ scope: IntentionScope, _ text: String) {
        switch scope {
        case .month: monthlyIntention = text
        case .week: weeklyIntention = text
        case .day: dailyIntention = text
        }
    }
    
    private func suggestionsForScope(_ scope: IntentionScope) -> [String] {
        switch scope {
        case .month:
            return [
                "Build healthier habits",
                "Focus on personal growth",
                "Strengthen relationships",
                "Advance in my career",
                "Practice mindfulness daily",
                "Develop a new skill",
                "Improve work-life balance",
                "Save money for a goal",
                "Read more books",
                "Spend quality time with family",
                "Start a new hobby",
                "Reduce stress and anxiety",
                "Eat more nutritious meals",
                "Get better sleep",
                "Learn something new",
                "Volunteer or give back",
                "Travel to new places",
                "Build better routines",
                "Focus on mental health",
                "Achieve a fitness goal",
                "Improve communication",
                "Declutter and organize",
                "Practice self-care",
                "Set financial goals",
                "Build confidence",
                "Learn to cook",
                "Spend time in nature",
                "Reduce screen time",
                "Practice patience",
                "Be more present",
                "Express gratitude daily",
                "Take more breaks",
                "Learn a language",
                "Start journaling",
                "Build better habits",
                "Focus on creativity",
                "Improve posture",
                "Drink more water",
                "Practice deep breathing",
                "Set boundaries",
                "Be kinder to myself",
                "Focus on what matters",
                "Reduce procrastination",
                "Build resilience",
                "Practice forgiveness",
                "Be more organized",
                "Focus on solutions",
                "Celebrate small wins",
                "Learn from mistakes",
                "Be more intentional"
            ]
        case .week:
            return [
                "Make time for regular exercise",
                "Connect with friends and loved ones",
                "Focus on completing important tasks",
                "Dedicate time to learning",
                "Practice gratitude regularly",
                "Cook nourishing meals",
                "Make reading a priority",
                "Take daily walks",
                "Reach out to family",
                "Practice acts of kindness",
                "Make meditation part of my routine",
                "Write in my journal",
                "Try new recipes",
                "Spend time outdoors",
                "Complete work projects thoughtfully",
                "Engage with my hobbies",
                "Prioritize restful sleep",
                "Be mindful of social media use",
                "Express creativity",
                "Spend quality time with my partner",
                "Learn something new",
                "Practice deep breathing",
                "Declutter and organize my space",
                "Plan nourishing meals",
                "Move my body regularly",
                "Read for enjoyment",
                "Take regular breaks",
                "Practice mindfulness",
                "Do things that bring me joy",
                "Focus on meaningful goals",
                "Spend time in nature",
                "Prioritize self-care",
                "Connect with the natural world",
                "Show kindness to others",
                "Practice patience",
                "Be fully present in conversations",
                "Capture meaningful moments",
                "Cultivate gratitude",
                "Stay active",
                "Carve out time for myself",
                "Help others",
                "Develop new skills",
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
                "Go for a 20-minute walk",
                "Call a family member",
                "Read for 15 minutes",
                "Do one act of kindness",
                "Take 5 minutes to meditate",
                "Write 3 things I'm grateful for",
                "Drink 8 glasses of water",
                "Eat 2 servings of vegetables",
                "Take 3 deep breaths when stressed",
                "Spend 10 minutes outside",
                "Do one thing I've been putting off",
                "Practice a hobby for 30 minutes",
                "Connect with a friend",
                "Do something creative",
                "Exercise for 20 minutes",
                "Get 8 hours of sleep",
                "Limit phone use to essentials",
                "Cook a healthy meal",
                "Learn something new",
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
                "Focus on one goal",
                "Complete one important task",
                "Practice deep breathing",
                "Do something active",
                "Spend quality time with someone",
                "Practice a skill",
                "Reduce stress",
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

struct AnimatedWeeklyIcon: View {
    let iconIndex: Int
    let icon: String
    @ObservedObject var themeManager: AppThemeManager
    let colorScheme: ColorScheme
    @State private var isPulsing = false
    
    private var primaryColor: Color {
        themeManager.accentColor(for: colorScheme).toSwiftUIColor()
    }
    
    private var secondaryColor: Color {
        let accent = themeManager.accentColor(for: colorScheme).toSwiftUIColor()
        return accent.opacity(0.7)
    }
    
    private var tertiaryColor: Color {
        let accent = themeManager.accentColor(for: colorScheme).toSwiftUIColor()
        return accent.opacity(0.5)
    }
    
    var body: some View {
        Image(systemName: icon)
            .symbolRenderingMode(.palette)
            .foregroundStyle(
                primaryColor,
                secondaryColor,
                tertiaryColor
            )
            .font(.system(size: 64, weight: .ultraLight))
            .symbolEffect(.pulse, options: .repeat(2).speed(0.8), value: isPulsing)
            .frame(width: 64, height: 64) // Fixed size to prevent content shift
            .id(iconIndex) // Force view update on icon change
            .onAppear {
                // Start pulsing when view appears
                isPulsing = true
            }
            .onChange(of: iconIndex) { oldValue, newValue in
                // Reset and restart pulse animation when icon changes
                isPulsing = false
                // Small delay to ensure smooth transition
                Task {
                    try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                    await MainActor.run {
                        isPulsing = true
                    }
                }
            }
    }
}

struct AnimatedDailyIcon: View {
    let iconIndex: Int
    @ObservedObject var themeManager: AppThemeManager
    let colorScheme: ColorScheme
    @State private var isPulsing = false
    
    private var iconName: String {
        iconIndex == 0 ? "sunrise.fill" : "sunset.fill"
    }
    
    private var primaryColor: Color {
        themeManager.accentColor(for: colorScheme).toSwiftUIColor()
    }
    
    private var secondaryColor: Color {
        let accent = themeManager.accentColor(for: colorScheme).toSwiftUIColor()
        return accent.opacity(0.7)
    }
    
    private var tertiaryColor: Color {
        let accent = themeManager.accentColor(for: colorScheme).toSwiftUIColor()
        return accent.opacity(0.5)
    }
    
    var body: some View {
        Image(systemName: iconName)
            .symbolRenderingMode(.palette)
            .foregroundStyle(
                primaryColor,
                secondaryColor,
                tertiaryColor
            )
            .font(.system(size: 64, weight: .ultraLight))
            .symbolEffect(.pulse, options: .repeat(2).speed(0.8), value: isPulsing)
            .frame(width: 64, height: 64) // Fixed size to prevent content shift
            .id(iconIndex) // Force view update on icon change
            .onAppear {
                // Start pulsing when view appears
                isPulsing = true
            }
            .onChange(of: iconIndex) { oldValue, newValue in
                // Reset and restart pulse animation when icon changes
                isPulsing = false
                // Small delay to ensure smooth transition
                Task {
                    try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                    await MainActor.run {
                        isPulsing = true
                    }
                }
            }
    }
}

struct AnimatedCalendarIcon: View {
    let iconIndex: Int
    @ObservedObject var themeManager: AppThemeManager
    let colorScheme: ColorScheme
    @State private var isPulsing = false
    
    private var currentDay: Int {
        Calendar.current.component(.day, from: Date())
    }
    
    private var iconName: String {
        iconIndex == 0 ? "calendar" : "\(currentDay).calendar"
    }
    
    private var primaryColor: Color {
        themeManager.accentColor(for: colorScheme).toSwiftUIColor()
    }
    
    private var secondaryColor: Color {
        let accent = themeManager.accentColor(for: colorScheme).toSwiftUIColor()
        return accent.opacity(0.7)
    }
    
    private var tertiaryColor: Color {
        let accent = themeManager.accentColor(for: colorScheme).toSwiftUIColor()
        return accent.opacity(0.5)
    }
    
    var body: some View {
        Image(systemName: iconName)
            .symbolRenderingMode(.palette)
            .foregroundStyle(
                primaryColor,
                secondaryColor,
                tertiaryColor
            )
            .font(.system(size: 64, weight: .ultraLight))
            .symbolEffect(.pulse, options: .repeat(2).speed(0.8), value: isPulsing)
            .frame(width: 64, height: 64) // Fixed size to prevent content shift
            .id(iconIndex) // Force view update on icon change
            .onAppear {
                // Start pulsing when view appears
                isPulsing = true
            }
            .onChange(of: iconIndex) { oldValue, newValue in
                // Reset and restart pulse animation when icon changes
                isPulsing = false
                // Small delay to ensure smooth transition
                Task {
                    try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                    await MainActor.run {
                        isPulsing = true
                    }
                }
            }
    }
}

struct AnimatedLightbulbIcon: View {
    let iconIndex: Int
    let icon: String
    @ObservedObject var themeManager: AppThemeManager
    let colorScheme: ColorScheme
    @State private var isPulsing = false
    
    private var primaryColor: Color {
        themeManager.accentColor(for: colorScheme).toSwiftUIColor()
    }
    
    private var secondaryColor: Color {
        // Use a complementary color from the theme
        let accent = themeManager.accentColor(for: colorScheme).toSwiftUIColor()
        // Create a slightly lighter/different shade for variety
        return accent.opacity(0.7)
    }
    
    private var tertiaryColor: Color {
        // Use another complementary color
        let accent = themeManager.accentColor(for: colorScheme).toSwiftUIColor()
        return accent.opacity(0.5)
    }
    
    var body: some View {
        Image(systemName: icon)
            .symbolRenderingMode(.palette)
            .foregroundStyle(
                primaryColor,
                secondaryColor,
                tertiaryColor
            )
            .font(.system(size: 64, weight: .ultraLight))
            .symbolEffect(.pulse, options: .repeat(2).speed(0.8), value: isPulsing)
            .frame(width: 64, height: 64) // Fixed size to prevent content shift
            .id(iconIndex) // Force view update on icon change
            .onAppear {
                // Start pulsing when view appears
                isPulsing = true
            }
            .onChange(of: iconIndex) { oldValue, newValue in
                // Reset and restart pulse animation when icon changes
                isPulsing = false
                // Small delay to ensure smooth transition
                Task {
                    try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                    await MainActor.run {
                        isPulsing = true
                    }
                }
            }
    }
}

struct QuickIdeasSection: View {
    @ObservedObject var themeManager: AppThemeManager
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
            HStack {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        navigateToPrevious()
                    }
                    #if os(iOS)
                    HapticFeedback.light()
                    #endif
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                        .frame(width: 32, height: 32)
                }
                
                Text("Quick ideas:")
                    .font(.system(size: 14, weight: .medium, design: .default))
                    .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        navigateToNext()
                    }
                    #if os(iOS)
                    HapticFeedback.light()
                    #endif
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                        .frame(width: 32, height: 32)
                }
            }
            
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
                            .font(.system(size: 14, weight: .regular, design: .default))
                            .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(themeManager.accentColor(for: colorScheme).toSwiftUIColor().opacity(0.1))
                            )
                    }
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
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var themeManager: AppThemeManager
    let title: String
    let examples: [String]
    @Binding var currentIndex: Int
    @Binding var lastTapTime: Date?
    let isGood: Bool
    
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
            ? .system(size: 14, weight: .semibold, design: .rounded)
            : .system(size: 14, weight: .medium, design: .default)
    }
    
    private var textFont: Font {
        isGood
            ? .system(size: 15, weight: .regular, design: .rounded)
            : .system(size: 15, weight: .light, design: .default)
    }
    
    private var iconColor: Color {
        isGood
            ? themeManager.accentColor(for: colorScheme).toSwiftUIColor()
            : themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.6)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: iconName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(iconColor)
                Text(title)
                    .font(titleFont)
                    .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
            }
            
            Text(currentExample)
                .font(textFont)
                .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    colorScheme == .dark
                        ? themeManager.currentTheme.darkSecondaryButtonBackground.toSwiftUIColor().opacity(0.4)
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
            daily: "Take care of my body and mind"
        ),
        IntentionPack(
            name: "Growth & Learning",
            description: "Develop new skills and expand knowledge",
            monthly: "Focus on personal and professional growth",
            weekly: "Dedicate time to learning",
            daily: "Learn something new or practice a skill"
        ),
        IntentionPack(
            name: "Connection & Relationships",
            description: "Strengthen bonds with others",
            monthly: "Nurture meaningful relationships",
            weekly: "Connect with friends and family",
            daily: "Show appreciation to someone I care about"
        ),
        IntentionPack(
            name: "Productivity & Focus",
            description: "Achieve goals and stay organized",
            monthly: "Make meaningful progress on my goals",
            weekly: "Complete important tasks thoughtfully",
            daily: "Focus on what matters most"
        )
    ]
}

struct CompletionStepContent: View {
    let monthlyIntention: String
    let weeklyIntention: String
    let dailyIntention: String
    @Binding var selectedPack: IntentionPack?
    @Binding var showingAIGenerator: Bool
    @Binding var showingPackPreview: IntentionPack?
    @ObservedObject var themeManager: AppThemeManager
    let colorScheme: ColorScheme
    
    private var hasIntentions: Bool {
        !monthlyIntention.isEmpty || !weeklyIntention.isEmpty || !dailyIntention.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 24) {
            if hasIntentions {
                // Show created intentions
                VStack(spacing: 20) {
                    Text("You're All Set!")
                        .font(.system(size: 28, weight: .light, design: .default))
                        .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                    
                    Text("You've created your first intentions! They'll appear on your home screen and help keep you focused. You can always add more or edit existing ones.")
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                    
                    VStack(spacing: 16) {
                        if !monthlyIntention.isEmpty {
                            IntentionSummaryCard(
                                scope: .month,
                                text: monthlyIntention,
                                themeManager: themeManager
                            )
                        }
                        
                        if !weeklyIntention.isEmpty {
                            IntentionSummaryCard(
                                scope: .week,
                                text: weeklyIntention,
                                themeManager: themeManager
                            )
                        }
                        
                        if !dailyIntention.isEmpty {
                            IntentionSummaryCard(
                                scope: .day,
                                text: dailyIntention,
                                themeManager: themeManager
                            )
                        }
                    }
                }
            } else {
                // Show options for creating intentions
                VStack(spacing: 24) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 64, weight: .ultraLight))
                        .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                    
                    Text("Need Some Ideas?")
                        .font(.system(size: 28, weight: .light, design: .default))
                        .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                    
                    Text("If you're not sure where to start, here are some ready-to-use intention packs. You can preview them to see what they include.")
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                    
                    // Intention packs
                    VStack(spacing: 12) {
                        ForEach(IntentionPack.packs, id: \.name) { pack in
                            IntentionPackCard(
                                pack: pack,
                                isSelected: selectedPack?.name == pack.name,
                                themeManager: themeManager,
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
                    
                    // AI option
                    Button(action: {
                        showingAIGenerator = true
                        #if os(iOS)
                        HapticFeedback.medium()
                        #endif
                    }) {
                        HStack {
                            Image(systemName: "sparkles")
                                .font(.system(size: 16, weight: .medium))
                            Text("Or tell us about yourself and we'll create custom intentions")
                                .font(.system(size: 15, weight: .medium, design: .default))
                        }
                        .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                        .padding(.vertical, 14)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(themeManager.accentColor(for: colorScheme).toSwiftUIColor().opacity(0.1))
                        )
                    }
                }
            }
        }
    }
}

struct IntentionPackCard: View {
    let pack: IntentionPack
    let isSelected: Bool
    @ObservedObject var themeManager: AppThemeManager
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
                            .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                        
                        Spacer()
                        
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                        }
                    }
                    
                    Text(pack.description)
                        .font(.system(size: 14, weight: .regular, design: .default))
                        .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            
            // Preview button
            Button(action: onPreview) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
        }
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    isSelected
                        ? themeManager.accentColor(for: colorScheme).toSwiftUIColor().opacity(0.1)
                        : (colorScheme == .dark
                            ? themeManager.currentTheme.darkSecondaryButtonBackground.toSwiftUIColor().opacity(0.4)
                            : Color.white.opacity(0.6))
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(
                    isSelected
                        ? themeManager.accentColor(for: colorScheme).toSwiftUIColor()
                        : themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.1),
                    lineWidth: isSelected ? 2 : 1
                )
        )
    }
}

struct IntentionSummaryCard: View {
    @Environment(\.colorScheme) var colorScheme
    let scope: IntentionScope
    let text: String
    @ObservedObject var themeManager: AppThemeManager
    
    private var scopeIcon: String {
        switch scope {
        case .month: return "calendar"
        case .week: return "calendar.badge.clock"
        case .day: return "sun.max.fill"
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: scopeIcon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(scope.rawValue.capitalized)
                    .font(.system(size: 12, weight: .semibold, design: .default))
                    .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                
                Text(text)
                    .font(.system(size: 15, weight: .regular, design: .default))
                    .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    colorScheme == .dark
                        ? themeManager.currentTheme.darkSecondaryButtonBackground.toSwiftUIColor().opacity(0.4)
                        : Color.white.opacity(0.6)
                )
        )
    }
}

struct AIIntentionGeneratorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    let onComplete: (String, String, String) -> Void
    
    @State private var userInfo: String = ""
    @State private var isGenerating = false
    @State private var generatedMonthly: String = ""
    @State private var generatedWeekly: String = ""
    @State private var generatedDaily: String = ""
    @ObservedObject var themeManager: AppThemeManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground(themeManager: themeManager)
                
                ScrollView {
                    VStack(spacing: 24) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 48, weight: .ultraLight))
                            .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                        
                        Text("Generate Personalized Intentions")
                            .font(.system(size: 24, weight: .light, design: .default))
                            .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                        
                        Text("Tell us a bit about yourself, your goals, or what you'd like to focus on, and we'll create personalized intentions for you.")
                            .font(.system(size: 16, weight: .regular, design: .default))
                            .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                        
                        TextEditor(text: $userInfo)
                            .frame(minHeight: 120)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(
                                        colorScheme == .dark
                                            ? themeManager.currentTheme.darkSecondaryButtonBackground.toSwiftUIColor().opacity(0.4)
                                            : Color.white.opacity(0.6)
                                    )
                            )
                            .overlay(
                                Group {
                                    if userInfo.isEmpty {
                                        Text("e.g., I want to focus on health, build better relationships, and advance in my career...")
                                            .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                                            .padding(.top, 16)
                                            .padding(.leading, 12)
                                            .allowsHitTesting(false)
                                    }
                                },
                                alignment: .topLeading
                            )
                        
                        if isGenerating {
                            ProgressView()
                                .tint(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                        } else {
                            PrimaryButton("Generate Intentions", themeManager: themeManager) {
                                generateIntentions()
                            }
                            .disabled(userInfo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                    .padding(40)
                }
            }
            .navigationTitle("AI Generator")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                }
            }
        }
    }
    
    private func generateIntentions() {
        isGenerating = true
        
        // TODO: Integrate with actual AI API
        // For now, create placeholder intentions based on user input
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000) // Simulate API call
            
            await MainActor.run {
                // Simple placeholder generation
                let keywords = userInfo.lowercased()
                
                if keywords.contains("health") || keywords.contains("fitness") || keywords.contains("wellness") {
                    generatedMonthly = "Prioritize my physical and mental well-being"
                    generatedWeekly = "Make time for regular exercise and rest"
                    generatedDaily = "Take care of my body and mind"
                } else if keywords.contains("career") || keywords.contains("work") || keywords.contains("professional") {
                    generatedMonthly = "Focus on professional growth and development"
                    generatedWeekly = "Complete important work tasks thoughtfully"
                    generatedDaily = "Make progress on my career goals"
                } else if keywords.contains("relationship") || keywords.contains("family") || keywords.contains("friend") {
                    generatedMonthly = "Nurture meaningful relationships"
                    generatedWeekly = "Connect with friends and family"
                    generatedDaily = "Show appreciation to someone I care about"
                } else {
                    generatedMonthly = "Focus on personal growth and development"
                    generatedWeekly = "Make time for what matters most"
                    generatedDaily = "Be intentional with my actions"
                }
                
                isGenerating = false
                onComplete(generatedMonthly, generatedWeekly, generatedDaily)
                dismiss()
            }
        }
    }
}

struct IntentionPackPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    let pack: IntentionPack
    @ObservedObject var themeManager: AppThemeManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground(themeManager: themeManager)
                
                ScrollView {
                    VStack(spacing: 24) {
                        Text("Preview")
                            .font(.system(size: 20, weight: .light, design: .default))
                            .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                        
                        Text(pack.name)
                            .font(.system(size: 24, weight: .light, design: .default))
                            .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                        
                        Text(pack.description)
                            .font(.system(size: 16, weight: .regular, design: .default))
                            .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                            .multilineTextAlignment(.center)
                        
                        VStack(spacing: 16) {
                            IntentionSummaryCard(
                                scope: .month,
                                text: pack.monthly,
                                themeManager: themeManager
                            )
                            
                            IntentionSummaryCard(
                                scope: .week,
                                text: pack.weekly,
                                themeManager: themeManager
                            )
                            
                            IntentionSummaryCard(
                                scope: .day,
                                text: pack.daily,
                                themeManager: themeManager
                            )
                        }
                    }
                    .padding(40)
                }
            }
            .navigationTitle("Pack Preview")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                }
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: Intention.self, IntentionTheme.self, UserPreferences.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    IntentionGuideView(modelContext: container.mainContext)
        .modelContainer(container)
        .environmentObject(AppThemeManager())
}

