//
//  FirstIntentionPage.swift
//  Daily Intentions
//
//  Created for onboarding experience
//

import SwiftUI
import SwiftData

/// Fifth page of onboarding - Create first intention
struct FirstIntentionPage: View {
    let onComplete: () -> Void
    
    @Environment(\.modelContext) private var modelContext
    @State private var intentionText = ""
    @State private var selectedScope: IntentionScope = .day
    @State private var showingSuggestions = true
    
    private let suggestions = Array(ExampleIntention.examples.prefix(3))
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
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
                    .onChange(of: intentionText) { oldValue, newValue in
                        showingSuggestions = newValue.isEmpty
                    }
            }
            .padding(.horizontal, 32)
            
            // Scope selector
            Picker("Scope", selection: $selectedScope) {
                ForEach(IntentionScope.allCases, id: \.self) { scope in
                    Text(scope.rawValue.capitalized).tag(scope)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 32)
            
            if showingSuggestions {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Or try one of these:")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 32)
                    
                    ForEach(suggestions.indices, id: \.self) { index in
                        ExampleIntentionCard(intention: suggestions[index]) {
                            intentionText = suggestions[index].text
                            selectedScope = suggestions[index].scope
                            showingSuggestions = false
                        }
                        .padding(.horizontal, 32)
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
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
        .padding(.vertical)
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

