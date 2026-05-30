//
//  FirstIntentionPage.swift
//  Daily Intentions
//
//  Created for onboarding experience
//

import SwiftUI
import SwiftData
#if canImport(WidgetKit)
import WidgetKit
#endif

/// Fifth page of onboarding - Create first intention
struct FirstIntentionPage: View {
    @Environment(\.colorScheme) var colorScheme

    let onComplete: () -> Void

    @Environment(\.modelContext) private var modelContext
    @State private var intentionText = ""
    @State private var selectedScope: IntentionScope = .day
    @State private var showingSuggestions = true

    private let suggestions = Array(ExampleIntention.examples.prefix(3))

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Custom background
                AppBackground()

                VStack(spacing: 0) {
                    Spacer()

                    // Main content area
                    VStack(spacing: 24) {
                        Text(String(localized: "Set your first intention"))
                            .font(.system(size: 28, weight: .light, design: .default))
                            .foregroundColor(AppThemeManager.shared.primaryTextColor(for: colorScheme))
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)

                        VStack(alignment: .leading, spacing: 12) {
                            Text(String(localized: "What do you want to focus on?"))
                                .font(.system(size: 15, weight: .light, design: .default))
                                .foregroundColor(AppThemeManager.shared.secondaryTextColor(for: colorScheme))
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(nil)
                                .opacity(0.75)

                            TextField(String(localized: "Enter your intention..."), text: $intentionText, axis: .vertical)
                                #if !os(watchOS)
                                .textFieldStyle(.roundedBorder)
                                #endif
                                .lineLimit(3...5)
                                .multilineTextAlignment(.leading)
                                .onChange(of: intentionText) { oldValue, newValue in
                                    showingSuggestions = newValue.isEmpty
                                }
                        }
                        .padding(.horizontal, 60)
                        .frame(maxWidth: 700)

                        // Scope selector
                        Picker("Scope", selection: $selectedScope) {
                            ForEach(IntentionScope.allCases, id: \.self) { scope in
                                Text(scope.rawValue.capitalized).tag(scope)
                            }
                        }
                        #if !os(watchOS)
                        .pickerStyle(.segmented)
                        #endif
                        .padding(.horizontal, 60)
                        .frame(maxWidth: 700)

                        if showingSuggestions {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(String(localized: "Or try one of these:"))
                                    .font(.system(size: 15, weight: .light, design: .default))
                                    .foregroundColor(AppThemeManager.shared.secondaryTextColor(for: colorScheme))
                                    .fixedSize(horizontal: false, vertical: true)
                                    .lineLimit(nil)
                                    .opacity(0.75)
                                    .padding(.horizontal, 60)

                                ForEach(suggestions.indices, id: \.self) { index in
                                    ExampleIntentionCard(
                                        intention: suggestions[index]
                                    ) {
                                        intentionText = suggestions[index].text
                                        selectedScope = suggestions[index].scope
                                        showingSuggestions = false
                                    }
                                    .padding(.horizontal, 60)
                                }
                            }
                            .frame(maxWidth: 700)
                        }
                    }

                    Spacer()

                    // Action button - always enabled
                    VStack(spacing: 20) {
                        PrimaryButton("Get Started") {
                            createFirstIntention()
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 80)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }

    func createFirstIntention() {
        // Only create intention if user provided text
        let trimmedText = intentionText.trimmingCharacters(in: .whitespacesAndNewlines)

        if !trimmedText.isEmpty {
            let intention = Intention(
                text: trimmedText,
                scope: selectedScope,
                date: Date()
            )

            do {
                modelContext.insert(intention)
                try modelContext.save()
            } catch {
                print("Error creating first intention: \(error)")
                // Continue with onboarding even if intention creation fails
            }
        }

        // Always complete onboarding, even if no intention was created
        OnboardingManager.shared.completeOnboarding()
        onComplete()
    }
}

#Preview {
    FirstIntentionPage(onComplete: { print("Complete") })
        .modelContainer(for: Intention.self, inMemory: true)
}

