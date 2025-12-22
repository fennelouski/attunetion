//
//  AttunetionApp.swift
//  Attunetion
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct DailyIntentionsApp: App {
    @State private var showOnboarding = true

    init() {
        // Check if onboarding should be shown
        showOnboarding = !OnboardingManager.shared.hasCompletedOnboarding
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Intention.self,
            IntentionTheme.self,
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])

            // Populate preset themes on first launch
            Task { @MainActor in
                let context = container.mainContext
                let themeRepo = ThemeRepository(modelContext: context)
                try? PresetThemes.populatePresetThemes(in: themeRepo)
            }

            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentViewWrapper(showOnboarding: $showOnboarding)
        }
        .modelContainer(sharedModelContainer)
    }
}

// Wrapper view to check for existing intentions
struct ContentViewWrapper: View {
    @Binding var showOnboarding: Bool
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        Group {
            if showOnboarding {
                OnboardingContainerView {
                    showOnboarding = false
                }
            } else {
                IntentionsListView()
            }
        }
        .onAppear {
            // Check if user has existing intentions - if so, skip onboarding
            let descriptor = FetchDescriptor<Intention>()
            let existingIntentions = (try? modelContext.fetch(descriptor)) ?? []
            let hasIntentions = !existingIntentions.isEmpty
            
            // If user has intentions, automatically complete onboarding
            if hasIntentions && !OnboardingManager.shared.hasCompletedOnboarding {
                OnboardingManager.shared.completeOnboarding()
            }
            
            // Only show onboarding if not completed AND no existing intentions
            showOnboarding = !OnboardingManager.shared.hasCompletedOnboarding && !hasIntentions
        }
    }
}

