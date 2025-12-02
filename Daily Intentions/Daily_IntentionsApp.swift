//
//  Daily_IntentionsApp.swift
//  Daily Intentions
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct Daily_IntentionsApp: App {
    @State private var showOnboarding = !OnboardingManager.shared.hasCompletedOnboarding
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Intention.self,
            IntentionTheme.self,
            UserPreferences.self,
        ])
        
        // Configure for CloudKit sync
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
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
    
    init() {
        // Set up notification delegate
        UNUserNotificationCenter.current().delegate = NotificationHandler.shared
        
        // Set model context on notification handler
        Task { @MainActor in
            NotificationHandler.shared.setModelContext(sharedModelContainer.mainContext)
        }
        
        // Setup notification categories
        Task {
            await NotificationManager.shared.setupNotificationCategories()
        }
    }

    var body: some Scene {
        WindowGroup {
            IntentionsListView()
                #if !os(watchOS)
                .fullScreenCover(isPresented: $showOnboarding) {
                    OnboardingContainerView {
                        showOnboarding = false
                    }
                }
                #else
                .sheet(isPresented: $showOnboarding) {
                    OnboardingContainerView {
                        showOnboarding = false
                    }
                }
                #endif
                .onAppear {
                    showOnboarding = !OnboardingManager.shared.hasCompletedOnboarding
                    
                    // Set model context on notification handler once app is ready
                    NotificationHandler.shared.setModelContext(sharedModelContainer.mainContext)
                    
                    // Reschedule notifications based on saved preferences
                    Task { @MainActor in
                        let context = sharedModelContainer.mainContext
                        let prefsRepo = UserPreferencesRepository(modelContext: context)
                        if let prefs = prefsRepo.getPreferences() {
                            let settings = prefs.notificationSettings
                            await NotificationManager.shared.scheduleAllNotifications(settings: settings)
                        }
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
