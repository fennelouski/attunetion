import Foundation
import SwiftData

@main
struct FlowChecks {
    @MainActor static func main() throws {
        let folder = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
        let schema = Schema([Intention.self])
        let container = try ModelContainer(for: schema, configurations: ModelConfiguration(
            schema: schema, url: folder.appendingPathComponent("flow.store"), cloudKitDatabase: .none
        ))
        let context = container.mainContext
        context.autosaveEnabled = false
        let repository = IntentionRepository(modelContext: context)
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        try repository.create(IntentionScope.allCases.map {
            Intention(text: "Synthetic \($0.rawValue)", scope: $0, date: today)
        })
        precondition(repository.getAll().count == 3)
        precondition(repository.search(query: "Synthetic").count == 3)
        precondition(repository.getIntentions(from: today, to: tomorrow).count == 3)
        for scope in IntentionScope.allCases {
            precondition(repository.getIntention(for: today, scope: scope)?.scope == scope)
            precondition(repository.getIntentions(scope: scope).count == 1)
        }
        print("PASS: Whole guide persists; date/scope queries and the main context see all three records")
        do {
            try repository.create([
                Intention(text: "Must not partially persist", scope: .day, date: tomorrow),
                Intention(text: "Duplicate week", scope: .week, date: today)
            ])
            fatalError("Duplicate guide unexpectedly saved")
        } catch IntentionSaveError.alreadyExists {
            precondition(repository.getAll().count == 3)
            let persistedCount = try ModelContext(container).fetchCount(FetchDescriptor<Intention>())
            precondition(persistedCount == 3)
        }
        let existing = repository.getIntention(for: today, scope: .day)!
        existing.text = "Pending edit preserved"
        try repository.create(Intention(text: "Tomorrow", scope: .day, date: tomorrow))
        let checkContext = ModelContext(container)
        let reloaded = try checkContext.fetch(FetchDescriptor<Intention>())
        precondition(reloaded.count == 4 && reloaded.contains { $0.text == "Pending edit preserved" })
        precondition(repository.getIntention(byId: existing.id)?.id == existing.id)
        print("PASS: Duplicate batch rejected without partial inserts; existing pending edits survive the next save")

        let readOnly = try ModelContainer(for: schema, configurations: ModelConfiguration(
            schema: schema, url: folder.appendingPathComponent("flow.store"), allowsSave: false, cloudKitDatabase: .none
        ))
        let readOnlyContext = readOnly.mainContext
        readOnlyContext.autosaveEnabled = false
        let future = Calendar.current.date(byAdding: .year, value: 1, to: today)!
        do {
            try IntentionRepository(modelContext: readOnlyContext).create(IntentionScope.allCases.map {
                Intention(text: "Must not save", scope: $0, date: future)
            })
            fatalError("Read-only save unexpectedly succeeded")
        } catch {
            let preservedCount = try readOnlyContext.fetchCount(FetchDescriptor<Intention>())
            precondition(preservedCount == 4)
            precondition(!readOnlyContext.hasChanges)
        }
        print("PASS: Actual read-only store failure leaves all prior records and no partial guide")

        let id = UUID()
        precondition(IntentionLink(url: URL(string: "dailyintentions://new")!) == .new)
        precondition(IntentionLink(url: URL(string: "dailyintentions://intention/\(id)")!) == .existing(id))
        for invalid in ["https://intention/\(id)", "dailyintentions://intention/no-id", "dailyintentions://intention/\(id)/extra", "dailyintentions://new/extra", "dailyintentions://new?text=ignored", "dailyintentions://user@new", "dailyintentions://unknown"] {
            precondition(IntentionLink(url: URL(string: invalid)!) == nil)
        }
        print("PASS: Existing/new widget routes accepted; foreign, malformed and extra-payload routes rejected")
        print("Only synthetic temporary stores used. UI, notification delivery and installed widget taps still require device validation.")
    }
}
