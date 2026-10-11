import Foundation
import SwiftData

@main
struct MigrationChecks {
    @MainActor static func main() throws {
        let url = URL(fileURLWithPath: CommandLine.arguments[1]).appendingPathComponent("legacy.store")
        let schema = Schema([Intention.self, IntentionTheme.self, UserPreferences.self, UserProfile.self, IntentionFeedback.self])
        let config = ModelConfiguration(schema: schema, url: url, cloudKitDatabase: .none)
        #if LEGACY
        let container = try ModelContainer(for: schema, configurations: [config])
        let context = container.mainContext
        let theme = IntentionTheme(name: "Synthetic legacy theme", backgroundColor: "#101010", textColor: "#EFEFEF")
        let intention = Intention(text: "Synthetic legacy intention", scope: .season, date: Date(timeIntervalSince1970: 1_700_000_000), themeId: theme.id)
        let prefs = UserPreferences(onboardingCompleted: true, defaultThemeId: theme.id, defaultFont: "synthetic-font")
        let profile = UserProfile(userInfo: "Synthetic legacy profile", hasAcceptedTerms: true)
        let feedback = IntentionFeedback(intentionId: intention.id, isApproved: true, feedbackText: "Synthetic legacy feedback")
        context.insert(theme); context.insert(intention); context.insert(prefs); context.insert(profile); context.insert(feedback)
        try context.save()
        print("PASS: Seeded five unversioned legacy entities in a synthetic temporary store")
        #else
        let container = try ModelContainer(for: Intention.self, IntentionTheme.self, UserPreferences.self, UserProfile.self, IntentionFeedback.self, migrationPlan: AttunetionMigrationPlan.self, configurations: config)
        let context = container.mainContext
        let intentions = try context.fetch(FetchDescriptor<Intention>())
        let themes = try context.fetch(FetchDescriptor<IntentionTheme>())
        let prefs = try context.fetch(FetchDescriptor<UserPreferences>())
        let profiles = try context.fetch(FetchDescriptor<UserProfile>())
        let feedback = try context.fetch(FetchDescriptor<IntentionFeedback>())
        precondition(intentions.count == 1 && intentions[0].text == "Synthetic legacy intention" && intentions[0].scope == .season)
        precondition(themes.count == 1 && themes[0].name == "Synthetic legacy theme")
        precondition(intentions[0].themeId == themes[0].id)
        let verifyNewFields = CommandLine.arguments.count > 2
        precondition(prefs.count == 1 && prefs[0].onboardingCompleted && prefs[0].defaultThemeId == themes[0].id && prefs[0].defaultFont == "synthetic-font")
        precondition(profiles.count == 1 && profiles[0].hasAcceptedTerms && profiles[0].userInfo == "Synthetic legacy profile")
        precondition(feedback.count == 1 && feedback[0].intentionId == intentions[0].id && feedback[0].isApproved)
        if verifyNewFields {
            precondition(themes[0].backgroundImageURL == "https://images.unsplash.com/synthetic.jpg")
            precondition(intentions[0].themeSetAt == Date(timeIntervalSince1970: 1_750_000_000))
            print("PASS: A second reader process reopens the migrated store and preserves legacy entities plus saved new fields")
            return
        }
        precondition(intentions[0].themeSetAt == nil && themes[0].backgroundImageURL == nil)
        themes[0].backgroundImageURL = "https://images.unsplash.com/synthetic.jpg"
        intentions[0].themeSetAt = Date(timeIntervalSince1970: 1_750_000_000)
        try context.save()
        print("PASS: Unversioned → V1 migration preserves all five entities, links, consent and appearance defaults; new theme properties save")
        #endif
    }
}
