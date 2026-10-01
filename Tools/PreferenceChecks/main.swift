import Foundation
import SwiftData

@main
struct PreferenceChecks {
    @MainActor static func main() throws {
        let folder = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
        let schema = Schema([Intention.self, IntentionTheme.self, UserPreferences.self,
                             UserProfile.self, IntentionFeedback.self])
        let container = try ModelContainer(for: schema, configurations: ModelConfiguration(
            schema: schema, url: folder.appendingPathComponent("preferences.store"), cloudKitDatabase: .none
        ))
        let context = container.mainContext
        context.autosaveEnabled = false
        let selection = PreferenceSelection(context)
        let themes = ThemeRepository(modelContext: context)
        let oceanID = UUID(uuidString: "00000000-0000-0000-0000-000000000005")!
        let minimalID = UUID(uuidString: "00000000-0000-0000-0000-000000000003")!
        let sunsetID = UUID(uuidString: "00000000-0000-0000-0000-000000000004")!

        switch CommandLine.arguments[2] {
        case "write":
            try PresetThemes.populatePresetThemes(in: themes)
            context.insert(UserPreferences())
            context.insert(Intention(text: "Existing synthetic intention", scope: .month,
                                     date: Date(), themeId: minimalID, customFont: "monospace"))
            try context.save()
            selection.saveDefaultTheme(themes.getTheme(byId: oceanID))
            for font in ["system", "serif", "monospace", "rounded"] {
                selection.saveDefaultFont(font)
                precondition(selection.preferences?.defaultFont == font)
            }
            precondition(selection.preferenceSaveError == nil)
            print("PASS: Actual Settings save bodies persist a real catalog UUID and every supported font ID")
        case "read":
            precondition(selection.preferences?.defaultThemeId == oceanID)
            precondition(selection.preferences?.defaultFont == "rounded")
            let draft = NewDraft(context)
            draft.loadAppearanceDefaults()
            precondition(draft.selectedTheme?.id == oceanID && draft.selectedFont == "rounded")
            let next = draft.makeIntention()
            precondition(next.themeId == oceanID && next.customFont == "rounded")
            print("PASS: A new process reopens the saved defaults; actual new-draft loader and constructor use them")

            draft.selectedTheme = nil
            draft.selectedFont = nil
            selection.saveDefaultTheme(themes.getTheme(byId: sunsetID))
            selection.saveDefaultFont("serif")
            draft.loadAppearanceDefaults()
            let noTheme = draft.makeIntention()
            precondition(noTheme.themeId == nil && noTheme.customFont == nil)
            let nextDraft = NewDraft(context)
            nextDraft.loadAppearanceDefaults()
            precondition(nextDraft.selectedTheme?.id == sunsetID && nextDraft.selectedFont == "serif")
            nextDraft.selectedTheme = themes.getTheme(byId: oceanID)
            nextDraft.selectedFont = "monospace"
            nextDraft.loadAppearanceDefaults()
            let overridden = nextDraft.makeIntention()
            precondition(overridden.themeId == oceanID && overridden.customFont == "monospace")
            let existing = try context.fetch(FetchDescriptor<Intention>()).first!
            precondition(existing.themeId == minimalID && existing.customFont == "monospace")
            print("PASS: Explicit None and draft overrides survive repeated appearances/default changes; existing intentions stay unchanged")

            let readOnly = try ModelContainer(for: schema, configurations: ModelConfiguration(
                schema: schema, url: folder.appendingPathComponent("preferences.store"),
                allowsSave: false, cloudKitDatabase: .none
            ))
            readOnly.mainContext.autosaveEnabled = false
            let failed = PreferenceSelection(readOnly.mainContext)
            failed.saveDefaultTheme(themes.getTheme(byId: oceanID))
            precondition(failed.preferenceSaveError != nil && failed.preferences?.defaultThemeId == sunsetID)
            failed.preferenceSaveError = nil
            failed.saveDefaultFont("rounded")
            precondition(failed.preferenceSaveError != nil && failed.preferences?.defaultFont == "serif")
            print("PASS: Real read-only save failures restore the prior fields and produce a save error")
        case "clear":
            selection.saveDefaultTheme(nil)
            selection.saveDefaultFont(nil)
            precondition(selection.preferenceSaveError == nil)
        case "verify-clear":
            precondition(selection.preferences?.defaultThemeId == nil && selection.preferences?.defaultFont == nil)
            let draft = NewDraft(context)
            draft.loadAppearanceDefaults()
            let next = draft.makeIntention()
            precondition(next.themeId == nil && next.customFont == nil)
            print("PASS: Explicit None/System Default persist through another process and seed the next draft")
        case "post-delete-theme":
            try LocalUserDataDeletion.delete(from: context)
            precondition(selection.preferences == nil)
            selection.saveDefaultTheme(themes.getTheme(byId: oceanID))
            precondition(selection.preferenceSaveError == nil && selection.preferences?.defaultThemeId == oceanID)
            print("PASS: Actual deletion leaves no preference row; the next theme choice creates and saves one")
        case "verify-theme-and-delete-font":
            precondition(selection.preferences?.defaultThemeId == oceanID)
            try LocalUserDataDeletion.delete(from: context)
            selection.saveDefaultFont("serif")
            precondition(selection.preferenceSaveError == nil && selection.preferences?.defaultFont == "serif")
            print("PASS: Post-delete theme choice survives a fresh process; a first font choice also creates and saves a row")
        case "verify-font-and-delete-nil":
            precondition(selection.preferences?.defaultFont == "serif")
            try LocalUserDataDeletion.delete(from: context)
            selection.saveDefaultTheme(nil)
            selection.saveDefaultFont(nil)
            precondition(selection.preferenceSaveError == nil && selection.preferences != nil)
            print("PASS: Post-delete font choice survives a fresh process; explicit nil choices can create a preference row")
        case "verify-nil-and-fail":
            precondition(selection.preferences != nil)
            precondition(selection.preferences?.defaultThemeId == nil && selection.preferences?.defaultFont == nil)
            try LocalUserDataDeletion.delete(from: context)
            let readOnly = try ModelContainer(for: schema, configurations: ModelConfiguration(
                schema: schema, url: folder.appendingPathComponent("preferences.store"),
                allowsSave: false, cloudKitDatabase: .none
            ))
            readOnly.mainContext.autosaveEnabled = false
            let failed = PreferenceSelection(readOnly.mainContext)
            precondition(failed.preferences == nil)
            let pending = Intention(text: "Unsaved failure-check draft", scope: .day, date: Date())
            readOnly.mainContext.insert(pending)
            failed.saveDefaultTheme(themes.getTheme(byId: oceanID))
            precondition(failed.preferenceSaveError != nil && failed.preferences == nil)
            failed.preferenceSaveError = nil
            failed.saveDefaultFont("rounded")
            precondition(failed.preferenceSaveError != nil && failed.preferences == nil)
            let persistedCount = try ModelContext(readOnly).fetchCount(FetchDescriptor<UserPreferences>())
            precondition(persistedCount == 0)
            let pendingDrafts = try readOnly.mainContext.fetch(FetchDescriptor<Intention>())
            precondition(pendingDrafts.contains { $0.id == pending.id && $0.text == "Unsaved failure-check draft" })
            print("PASS: Post-delete nil choices reopen; actual new-row save failures report errors and remove only their unsaved rows while preserving another pending draft")
        case "verify-no-row":
            precondition(selection.preferences == nil)
            let draft = NewDraft(context)
            draft.loadAppearanceDefaults()
            precondition(draft.selectedTheme == nil && draft.selectedFont == nil)
            print("PASS: Another fresh process confirms failed creation persisted no bogus preference row")
        default:
            fatalError("Unknown check stage")
        }
        print("Only temporary disk stores used; actual widget code compiled but not invoked. No UI, app, network, notification, CloudKit, or real preference writes.")
    }
}
