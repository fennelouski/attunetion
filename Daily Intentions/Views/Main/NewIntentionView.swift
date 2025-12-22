//
import SwiftUI
import SwiftData

struct NewIntentionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme

    @State private var text = ""
    @State private var scope: IntentionScope = .day
    @State private var date = Date()
    @State private var showingGuide = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Intention") {
                    TextField("What do you want to focus on?", text: $text, axis: .vertical)
                        .lineLimit(3...6)

                    // Guide button (only show when text is empty)
                    if text.isEmpty {
                        Button(action: {
                            showingGuide = true
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.system(size: 14, weight: .medium))
                                Text("Need inspiration?")
                                    .font(.system(size: 14, weight: .medium, design: .default))
                            }
                            .foregroundColor(AppThemeManager.shared.accentColor(for: colorScheme))
                        }
                        .padding(.top, 8)
                    }
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
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppThemeManager.shared.secondaryTextColor(for: colorScheme))
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveIntention()
                    }
                    .background(AppThemeManager.shared.accentColor(for: colorScheme))
                    .foregroundColor(AppThemeManager.shared.buttonTextColor(for: colorScheme))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .cornerRadius(8)
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .sheet(isPresented: $showingGuide) {
                IntentionGuideView(modelContext: modelContext)
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
