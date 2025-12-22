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
    // On macOS, skip onboarding - users can use the help button instead
    // Initialize to true (safe default) - will be set correctly in onAppear
    // This avoids accessing @MainActor OnboardingManager during property initialization
    @State private var showOnboarding = true
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Intention.self,
            IntentionTheme.self,
            UserPreferences.self,
            UserProfile.self,
            IntentionFeedback.self,
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
        
        // Setup notification categories
        Task {
            await NotificationManager.shared.setupNotificationCategories()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AppThemeManager(modelContext: sharedModelContainer.mainContext))
                .environmentObject(BackendHealthManager.shared)
                #if os(watchOS) || os(macOS)
                .sheet(isPresented: $showOnboarding) {
                    OnboardingContainerView {
                        showOnboarding = false
                    }
                }
                #else
                .fullScreenCover(isPresented: $showOnboarding) {
                    OnboardingContainerView {
                        showOnboarding = false
                    }
                }
                #endif
                .onAppear {
                    #if os(macOS)
                    // On macOS, automatically mark onboarding as completed
                    // Users can access help via the "How to create good intentions" button
                    if !OnboardingManager.shared.hasCompletedOnboarding {
                        OnboardingManager.shared.setModelContext(sharedModelContainer.mainContext)
                        OnboardingManager.shared.completeOnboarding()
                    }
                    showOnboarding = false
                    #else
                    // Set model context for OnboardingManager
                    OnboardingManager.shared.setModelContext(sharedModelContainer.mainContext)
                    
                    // Check if user has existing intentions - if so, skip onboarding
                    let context = sharedModelContainer.mainContext
                    let intentionRepo = IntentionRepository(modelContext: context)
                    let existingIntentions = intentionRepo.getAll()
                    let hasIntentions = !existingIntentions.isEmpty
                    
                    // If user has intentions, automatically complete onboarding
                    if hasIntentions && !OnboardingManager.shared.hasCompletedOnboarding {
                        OnboardingManager.shared.completeOnboarding()
                    }
                    
                    // Only show onboarding if not completed AND no existing intentions
                    showOnboarding = !OnboardingManager.shared.hasCompletedOnboarding && !hasIntentions
                    #endif
                    
                    // Set model context on notification handler once app is ready
                    NotificationHandler.shared.setModelContext(sharedModelContainer.mainContext)
                    
                    // Check backend health on app launch
                    Task { @MainActor in
                        await BackendHealthManager.shared.checkBackendHealth()
                    }
                    
                    // Reschedule notifications based on saved preferences
                    Task { @MainActor in
                        let context = sharedModelContainer.mainContext
                        let prefsRepo = UserPreferencesRepository(modelContext: context)
                        if let prefs = prefsRepo.getPreferences() {
                            let settings = prefs.notificationSettings
                            await NotificationManager.shared.scheduleAllNotifications(settings: settings)
                        }
                        
                        // Sync widget data on app launch
                        WidgetDataService.shared.updateWidgetDataFromSwiftData(modelContext: context)
                        
                        // Check if auto-generation is needed
                        let intentionRepo = IntentionRepository(modelContext: context)
                        let profileRepo = UserProfileRepository(modelContext: context)
                        let autoService = AutoIntentionService(
                            apiClient: .shared,
                            intentionRepository: intentionRepo,
                            userProfileRepository: profileRepo,
                            modelContext: context
                        )
                        
                        if autoService.shouldGenerateIntentions() {
                            // Generate intentions in background (don't block UI)
                            Task {
                                do {
                                    try await autoService.generateCurrentWeekIntentions()
                                    // Reload widget after generating
                                    WidgetDataService.shared.updateWidgetDataFromSwiftData(modelContext: context)
                                } catch {
                                    // Silently fail - user can manually generate if needed
                                    print("Auto-generation failed: \(error.localizedDescription)")
                                }
                            }
                        }
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
}

// Wrapper view to inject theme manager
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var themeManager: AppThemeManager
    @State private var pendingURL: URL?
    
    var body: some View {
        #if os(watchOS)
        WatchOSIntentionsView()
            .onOpenURL { url in
                handleURL(url)
            }
        #else
        IntentionsListView(pendingURL: $pendingURL)
            .onOpenURL { url in
                handleURL(url)
            }
        #endif
    }
    
    private func handleURL(_ url: URL) {
        guard url.scheme == "dailyintentions" else { return }
        
        if url.host == "new" {
            // Open new intention view
            pendingURL = url
        } else if url.host == "intention" {
            // Open specific intention (could navigate to detail view)
            // For now, just open new intention view
            pendingURL = URL(string: "dailyintentions://new")
        }
    }
}

