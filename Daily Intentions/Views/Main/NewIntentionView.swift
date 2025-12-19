//
import SwiftUI
import SwiftData

struct NewIntentionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var text = ""
    @State private var scope: IntentionScope = .day
    @State private var date = Date()

    var body: some View {
        NavigationStack {
            Form {
                Section("Intention") {
                    TextField("What do you want to focus on?", text: $text, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Scope") {
                    Picker("Scope", selection: $scope) {
                        Text("Day").tag(IntentionScope.day)
                        Text("Week").tag(IntentionScope.week)
                        Text("Month").tag(IntentionScope.month)
                    }
                    .pickerStyle(.segmented)
                }

                Section("Date") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
            }
            .navigationTitle("New Intention")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Theme.textSecondary)
                }

                ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            saveIntention()
                        }
                        .foregroundColor(Theme.buttonText)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(Theme.buttonBackground)
                        .cornerRadius(8)
                        .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func saveIntention() {
        let intention = Intention(
            text: text.trimmingCharacters(in: .whitespacesAndNewlines),
            scope: scope,
            date: date
        )

        modelContext.insert(intention)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving intention: \(error)")
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: Intention.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    NewIntentionView()
        .modelContainer(container)
}
