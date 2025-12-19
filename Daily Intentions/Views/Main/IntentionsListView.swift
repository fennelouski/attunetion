//
import SwiftUI
import SwiftData

struct IntentionsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var intentions: [Intention]
    @State private var showingNewIntention = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.gray.opacity(0.1)
                    .ignoresSafeArea()

                VStack {
                    if intentions.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 64, weight: .ultraLight))
                                .foregroundColor(Theme.primary)

                            Text("No intentions yet")
                                .font(.title2)
                                .foregroundColor(Theme.textSecondary)

                            Button("Create Your First Intention") {
                                showingNewIntention = true
                            }
                            .font(.headline)
                            .foregroundColor(Theme.buttonText)
                            .padding()
                            .background(Theme.buttonBackground)
                            .cornerRadius(12)
                        }
                        .padding()
                    } else {
                        List(intentions) { intention in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(intention.text)
                                    .font(.headline)
                                    .foregroundColor(Theme.textPrimary)

                                HStack {
                                    Text(intention.scope.rawValue.capitalized)
                                        .font(.subheadline)
                                        .foregroundColor(Theme.textSecondary)

                                    Spacer()

                                    Text(intention.date, style: .date)
                                        .font(.caption)
                                        .foregroundColor(Theme.textSecondary)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
            .navigationTitle("Daily Intentions")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingNewIntention = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewIntention) {
                NewIntentionView()
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: Intention.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    IntentionsListView()
        .modelContainer(container)
}