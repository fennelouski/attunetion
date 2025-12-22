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
            if showOnboarding {
                OnboardingContainerView { [self] in
                    showOnboarding = false
                }
            } else {
                IntentionsListView()
            }
        }
        .modelContainer(sharedModelContainer)
    }
}


