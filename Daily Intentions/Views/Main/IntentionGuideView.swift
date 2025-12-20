//
//  IntentionGuideView.swift
//  Daily Intentions
//
//  Created by Nathan Fennel on 12/19/25.
//  Simple guide that walks users through creating good intentions
//

import SwiftUI
import SwiftData

/// Simple guide that walks users through creating good intentions
struct IntentionGuideView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme

    @State private var viewModel: IntentionsViewModel

    @State private var currentStep = 0
    @State private var monthlyIntention: String = ""
    @State private var weeklyIntention: String = ""
    @State private var dailyIntention: String = ""
    @State private var quickIdeasPageIndex: [IntentionScope: Int] = [.month: 0, .week: 0, .day: 0]
    @State private var quickIdeasPages: [IntentionScope: [[String]]] = [:]

    init(modelContext: ModelContext) {
        _viewModel = State(initialValue: IntentionsViewModel(modelContext: modelContext))
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
                description: String(localized: "Think big picture. What do you want to focus on this month?"),
                icon: "calendar",
                scope: .month,
                placeholder: String(localized: "e.g., Build healthier habits")
            ),
            GuideStep(
                title: String(localized: "Set Your Weekly Intention"),
                description: String(localized: "Break down your monthly intention into weekly focus."),
                icon: "calendar.badge.clock",
                scope: .week,
                placeholder: String(localized: "e.g., Move my body regularly")
            ),
            GuideStep(
                title: String(localized: "Set Your Daily Intention"),
                description: String(localized: "Make it present and meaningful today."),
                icon: "sun.max.fill",
                scope: .day,
                placeholder: String(localized: "e.g., Move my body")
            ),
            GuideStep(
                title: String(localized: "You're All Set!"),
                description: String(localized: "You've created your first intentions! You can always add more or edit existing ones."),
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

    private var goodExamples: [String] {
        [
            String(localized: "Practice gratitude daily"),
            String(localized: "Move my body regularly"),
            String(localized: "Connect with friends and family"),
            String(localized: "Focus on what matters most")
        ]
    }

    private var badExamples: [String] {
        [
            String(localized: "Be happy"),
            String(localized: "Work harder"),
            String(localized: "Be perfect"),
            String(localized: "Do more")
        ]
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppThemeManager.shared.backgroundColor(for: colorScheme)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
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

                    ScrollView {
                        VStack(spacing: 32) {
                            // Icon and title
                            VStack(spacing: 16) {
                                Image(systemName: currentGuideStep.icon)
                                    .font(.system(size: 48, weight: .ultraLight))
                                    .foregroundColor(AppThemeManager.shared.accentColor(for: colorScheme))
                                    .frame(width: 48, height: 48)

                                Text(currentGuideStep.title)
                                    .font(.system(size: 24, weight: .light))
                                    .foregroundColor(AppThemeManager.shared.primaryTextColor(for: colorScheme))
                                    .multilineTextAlignment(.center)

                                Text(currentGuideStep.description)
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(AppThemeManager.shared.secondaryTextColor(for: colorScheme))
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(4)
                                    .padding(.horizontal, 20)
                            }

                            // Examples (for step 0)
                            if currentStep == 0 && currentGuideStep.showExamples {
                                VStack(alignment: .leading, spacing: 16) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Image(systemName: "checkmark.circle")
                                                .foregroundColor(.green)
                                            Text("Good Examples")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(AppThemeManager.shared.primaryTextColor(for: colorScheme))
                                        }
                                        ForEach(goodExamples, id: \.self) { example in
                                            Text("• \(example)")
                                                .font(.system(size: 14))
                                                .foregroundColor(AppThemeManager.shared.secondaryTextColor(for: colorScheme))
                                        }
                                    }

                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Image(systemName: "xmark.circle")
                                                .foregroundColor(.red)
                                            Text("Too Vague")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(AppThemeManager.shared.primaryTextColor(for: colorScheme))
                                        }
                                        ForEach(badExamples, id: \.self) { example in
                                            Text("• \(example)")
                                                .font(.system(size: 14))
                                                .foregroundColor(AppThemeManager.shared.secondaryTextColor(for: colorScheme))
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }

                            // Intention input (for steps 1-3)
                            if let scope = currentGuideStep.scope, currentStep >= 1 && currentStep <= 3 {
                                VStack(spacing: 16) {
                                    TextField(
                                        currentGuideStep.placeholder ?? "Enter your intention...",
                                        text: bindingForScope(scope),
                                        axis: .vertical
                                    )
                                    .textFieldStyle(.roundedBorder)
                                    .lineLimit(3...5)
                                    .padding(.horizontal, 20)

                                    // Quick suggestions
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
                                    .padding(.horizontal, 20)
                                }
                            }

                            // Completion summary (for step 4)
                            if currentStep == 4 {
                                VStack(spacing: 16) {
                                    if !monthlyIntention.isEmpty || !weeklyIntention.isEmpty || !dailyIntention.isEmpty {
                                        Text("Your intentions:")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(AppThemeManager.shared.primaryTextColor(for: colorScheme))

                                        VStack(spacing: 12) {
                                            if !monthlyIntention.isEmpty {
                                                IntentionSummaryRow(scope: .month, text: monthlyIntention)
                                            }
                                            if !weeklyIntention.isEmpty {
                                                IntentionSummaryRow(scope: .week, text: weeklyIntention)
                                            }
                                            if !dailyIntention.isEmpty {
                                                IntentionSummaryRow(scope: .day, text: dailyIntention)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }

                            Spacer()
                        }
                        .padding(.vertical, 20)
                    }

                    // Bottom buttons
                    VStack(spacing: 16) {
                        if currentStep < steps.count - 1 {
                            HStack(spacing: 12) {
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
                                    if hasIntentions {
                                        createAllIntentions()
                                    } else {
                                        dismiss()
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.vertical, 16)

                    // Page indicator
                    PageIndicator(
                        currentPage: currentStep,
                        pageCount: steps.count
                    )
                    .padding(.bottom, 8)
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

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: scopeIcon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(AppThemeManager.shared.accentColor(for: colorScheme))
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(scope.rawValue.capitalized)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppThemeManager.shared.secondaryTextColor(for: colorScheme))

                Text(text)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(AppThemeManager.shared.primaryTextColor(for: colorScheme))
            }

            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
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

#Preview {
    let container = try! ModelContainer(for: Intention.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    IntentionGuideView(modelContext: container.mainContext)
        .modelContainer(container)
}
