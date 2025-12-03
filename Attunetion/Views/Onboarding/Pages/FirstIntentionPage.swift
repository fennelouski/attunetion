//
//  FirstIntentionPage.swift
//  Attunetion
//
//  Created for onboarding experience
//

import SwiftUI
import SwiftData

/// Fifth page of onboarding - Create first intention
struct FirstIntentionPage: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager: AppThemeManager
    
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
                AppBackground(themeManager: themeManager)
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Main content area
                    VStack(spacing: 24) {
                        Text("Set your first intention")
                            .font(.system(size: 28, weight: .light, design: .default))
                            .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("What do you want to focus on?")
                                .font(.system(size: 15, weight: .light, design: .default))
                                .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                                .opacity(0.75)
                            
                            TextField("Enter your intention...", text: $intentionText, axis: .vertical)
                                #if !os(watchOS)
                                .textFieldStyle(.roundedBorder)
                                #endif
                                .lineLimit(3...5)
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
                                Text("Or try one of these:")
                                    .font(.system(size: 15, weight: .light, design: .default))
                                    .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                                    .opacity(0.75)
                                    .padding(.horizontal, 60)
                                
                                ForEach(suggestions.indices, id: \.self) { index in
                                    ExampleIntentionCard(
                                        intention: suggestions[index],
                                        themeManager: themeManager
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
                    
                    // Action button
                    VStack(spacing: 20) {
                        if intentionText.isEmpty {
                            Button(action: {}) {
                                Text("Get Started")
                                    .font(.system(size: 17, weight: .semibold, design: .default))
                                    .foregroundColor(themeManager.buttonTextColor(for: colorScheme).toSwiftUIColor())
                                    .frame(maxWidth: 400)
                                    .frame(height: 50)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(themeManager.buttonBackgroundColor(for: colorScheme).toSwiftUIColor().opacity(0.5))
                                    )
                            }
                            .disabled(true)
                        } else {
                            PrimaryButton("Get Started", themeManager: themeManager) {
                                createFirstIntention()
                            }
                            .frame(maxWidth: 400)
                        }
                    }
                    .padding(.bottom, 80)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
    
    func createFirstIntention() {
        guard !intentionText.isEmpty else { return }
        
        let intention = Intention(
            text: intentionText.trimmingCharacters(in: .whitespacesAndNewlines),
            scope: selectedScope,
            date: Date()
        )
        
        do {
            let repository = IntentionRepository(modelContext: modelContext)
            try repository.create(intention)
            
            // Sync widget data after creating first intention
            WidgetDataService.shared.updateWidgetDataFromSwiftData(modelContext: modelContext)
            
            OnboardingManager.shared.completeOnboarding()
            onComplete()
        } catch {
            print("Error creating first intention: \(error)")
            // Still complete onboarding even if intention creation fails
            OnboardingManager.shared.completeOnboarding()
            onComplete()
        }
    }
}

#Preview {
    FirstIntentionPage(onComplete: { print("Complete") })
        .modelContainer(for: Intention.self, inMemory: true)
}

