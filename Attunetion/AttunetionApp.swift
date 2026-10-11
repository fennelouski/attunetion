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
    @State private var onboardingCompletionID = UUID()
    
    var sharedModelContainer: ModelContainer = {
        // Versioned schema preserves the existing app-private store.
        let cloudKitConfig = ModelConfiguration(
            isStoredInMemoryOnly: false,
            groupContainer: .none,
            cloudKitDatabase: .automatic
        )

        func makeContainer(config: ModelConfiguration) throws -> ModelContainer {
            try ModelContainer(
                for: AttunetionSchemaV1.Intention.self,
                AttunetionSchemaV1.IntentionTheme.self,
                AttunetionSchemaV1.UserPreferences.self,
                AttunetionSchemaV1.UserProfile.self,
                AttunetionSchemaV1.IntentionFeedback.self,
                migrationPlan: AttunetionMigrationPlan.self,
                configurations: config
            )
        }

        do {
            let container = try makeContainer(config: cloudKitConfig)
            
            // Populate preset themes on first launch
            Task { @MainActor in
                let context = container.mainContext
                let themeRepo = ThemeRepository(modelContext: context)
                try? PresetThemes.populatePresetThemes(in: themeRepo)
            }
            
            return container
        } catch {
            // Retry with local-only store so migration can run without CloudKit validation
            do {
                let localConfig = ModelConfiguration(
                    isStoredInMemoryOnly: false,
                    groupContainer: .none,
                    cloudKitDatabase: .none
                )
                let container = try makeContainer(config: localConfig)
                Task { @MainActor in
                    let context = container.mainContext
                    let themeRepo = ThemeRepository(modelContext: context)
                    try? PresetThemes.populatePresetThemes(in: themeRepo)
                }
                return container
            } catch {
                fatalError("Could not open persistent ModelContainer: \(error)")
            }
        }
    }()
    
    init() {
        NotificationHandler.shared.setModelContext(sharedModelContainer.mainContext)
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
                .id(onboardingCompletionID)
                .environmentObject(AppThemeManager(modelContext: sharedModelContainer.mainContext))
                .environmentObject(BackendHealthManager.shared)
                #if os(watchOS) || os(macOS)
                .sheet(isPresented: $showOnboarding) {
                    OnboardingContainerView {
                        showOnboarding = false
                        onboardingCompletionID = UUID()
                    }
                }
                #else
                .fullScreenCover(isPresented: $showOnboarding) {
                    OnboardingContainerView {
                        showOnboarding = false
                        onboardingCompletionID = UUID()
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
    @AppStorage("openNewIntentionFromNotification") private var openNewIntentionFromNotification = false
    
    var body: some View {
        #if os(watchOS)
        WatchOSIntentionsView()
            .onOpenURL { url in
                handleURL(url)
            }
        #else
        IntentionsListView(pendingURL: $pendingURL)
            .onAppear { handleNotificationNavigation() }
            .onChange(of: openNewIntentionFromNotification) { _, _ in handleNotificationNavigation() }
            .onOpenURL { url in
                handleURL(url)
            }
        #endif
    }
    
    private func handleURL(_ url: URL) {
        guard url.scheme == "dailyintentions" else { return }
        pendingURL = url
    }

    private func handleNotificationNavigation() {
        guard openNewIntentionFromNotification else { return }
        pendingURL = URL(string: "dailyintentions://new")
        openNewIntentionFromNotification = false
    }
}
