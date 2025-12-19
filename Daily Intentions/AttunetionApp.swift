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
struct AttunetionApp: App {
    @State private var showOnboarding = true

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
            IntentionsListView()
                .sheet(isPresented: $showOnboarding) {
                    WelcomePage(
                        onContinue: { showOnboarding = false },
                        onSkip: { showOnboarding = false }
                    )
                }
        }
        .modelContainer(sharedModelContainer)
    }
}


