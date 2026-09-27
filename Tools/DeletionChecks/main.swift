import Foundation
import SwiftData

@main
struct DeletionChecks {
    @MainActor static func schema() -> Schema {
        Schema([Intention.self, IntentionTheme.self, UserPreferences.self,
                UserProfile.self, IntentionFeedback.self])
    }

    @MainActor static func seed(_ context: ModelContext) throws -> UUID {
        let preset = IntentionTheme(name: "Bundled preset", backgroundColor: "#FFFFFF", textColor: "#000000", isPreset: true)
        context.insert(preset)
        // Include duplicate singleton records left by older versions or a merge.
        for index in 0..<2 {
            let theme = IntentionTheme(name: "Custom \(index)", backgroundColor: "#FFFFFF", textColor: "#000000")
            context.insert(theme)
            let intention = Intention(text: "Synthetic deletion check \(index)", scope: .day, date: Date(), themeId: theme.id)
            context.insert(intention)
            context.insert(UserProfile(userInfo: "Synthetic profile \(index)", hasAcceptedTerms: true))
            context.insert(UserPreferences(onboardingCompleted: true, defaultThemeId: theme.id))
            context.insert(IntentionFeedback(intentionId: intention.id, isApproved: true, feedbackText: "Synthetic feedback"))
        }
        try context.save()
        return preset.id
    }

    @MainActor static func counts(_ context: ModelContext) throws -> [Int] {
        [try context.fetch(FetchDescriptor<Intention>()).count,
         try context.fetch(FetchDescriptor<UserProfile>()).count,
         try context.fetch(FetchDescriptor<UserPreferences>()).count,
         try context.fetch(FetchDescriptor<IntentionFeedback>()).count,
         try context.fetch(FetchDescriptor<IntentionTheme>()).count]
    }

    static func requireCounts(_ actual: [Int], _ expected: [Int], line: Int = #line) {
        guard actual == expected else { fatalError("Counts at line \(line): \(actual), expected \(expected)") }
    }

    @MainActor static func main() throws {
        let folder = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
        let writable = try ModelContainer(for: schema(), configurations: ModelConfiguration(
            schema: schema(), url: folder.appendingPathComponent("delete.store"), cloudKitDatabase: .none
        ))
        let context = writable.mainContext
        context.autosaveEnabled = false
        let presetID = try seed(context)
        context.insert(Intention(text: "Unsaved synthetic intention", scope: .day, date: Date()))
        try LocalUserDataDeletion.delete(from: context)
        try requireCounts(counts(context), [0, 0, 0, 0, 1])
        let remaining = try context.fetch(FetchDescriptor<IntentionTheme>())
        precondition(remaining[0].id == presetID && remaining[0].isPreset)
        let verification = ModelContext(writable)
        try requireCounts(counts(verification), [0, 0, 0, 0, 1])
        print("PASS: All user records across five model types and pending edits deleted; bundled preset identity preserved and deletion persisted")
        try LocalUserDataDeletion.delete(from: context)
        try requireCounts(counts(context), [0, 0, 0, 0, 1])
        print("PASS: Repeating deletion is safe")

        let readOnlyURL = folder.appendingPathComponent("readonly.store")
        do {
            let seedContainer = try ModelContainer(for: schema(), configurations: ModelConfiguration(
                schema: schema(), url: readOnlyURL, cloudKitDatabase: .none
            ))
            seedContainer.mainContext.autosaveEnabled = false
            _ = try seed(seedContainer.mainContext)
        }
        let readOnly = try ModelContainer(for: schema(), configurations: ModelConfiguration(
            schema: schema(), url: readOnlyURL, allowsSave: false, cloudKitDatabase: .none
        ))
        let readOnlyContext = readOnly.mainContext
        readOnlyContext.autosaveEnabled = false
        do {
            try LocalUserDataDeletion.delete(from: readOnlyContext)
            fatalError("Deletion on a read-only store unexpectedly succeeded")
        } catch {
            try requireCounts(counts(readOnlyContext), [2, 2, 2, 2, 3])
            precondition(!readOnlyContext.hasChanges)
            try requireCounts(counts(ModelContext(readOnly)), [2, 2, 2, 2, 3])
            print("PASS: Real read-only save failure is reported, restores every model, and leaves stored data unchanged")
        }

        let standardName = "AttunetionDeletionCheck.Standard.\(UUID().uuidString)"
        let widgetName = "AttunetionDeletionCheck.Widget.\(UUID().uuidString)"
        let standard = UserDefaults(suiteName: standardName)!
        let widgets = UserDefaults(suiteName: widgetName)!
        defer {
            standard.removePersistentDomain(forName: standardName)
            widgets.removePersistentDomain(forName: widgetName)
        }
        let standardKeys = ["hasSeenOnboarding", "intentionListStyle"]
        let widgetKeys = ["currentIntentionData", "currentThemeData", "defaultIntentionFrequency", "widgetUserState", "widgetThemePreference"]
        for key in standardKeys { standard.set("synthetic preference", forKey: key) }
        for key in widgetKeys { widgets.set("synthetic widget value", forKey: key) }
        standard.set("preserved test endpoint", forKey: "APIBaseURL")
        widgets.set("unrelated", forKey: "unrelated")
        LocalUserDataDeletion.clearPreferences(standard: standard, widgets: widgets)
        precondition(standardKeys.allSatisfy { standard.object(forKey: $0) == nil })
        precondition(widgetKeys.allSatisfy { widgets.object(forKey: $0) == nil })
        precondition(standard.string(forKey: "APIBaseURL") == "preserved test endpoint")
        precondition(widgets.string(forKey: "unrelated") == "unrelated")
        print("PASS: Personal preferences and all widget copies clear in isolated suites; unrelated configuration is preserved")
        print("No app launch, real user store, real preferences, notifications, widgets, or network used by these checks")
    }
}
