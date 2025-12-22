//
import SwiftUI
import SwiftData

struct IntentionsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Query private var intentions: [Intention]
    @State private var showingNewIntention = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppThemeManager.shared.backgroundColor(for: colorScheme)
                    .ignoresSafeArea()

                VStack {
                    if intentions.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 64, weight: .ultraLight))
                                .foregroundColor(AppThemeManager.shared.accentColor(for: colorScheme))

                            Text("No intentions yet")
                                .font(.title2)
                                .foregroundColor(AppThemeManager.shared.secondaryTextColor(for: colorScheme))

                            Button("Create Your First Intention") {
                                showingNewIntention = true
                            }
                            .font(.headline)
                            .foregroundColor(AppThemeManager.shared.buttonTextColor(for: colorScheme))
                            .padding()
                            .background(AppThemeManager.shared.accentColor(for: colorScheme))
                            .cornerRadius(12)
                        }
                        .padding()
                    } else {
                        List(intentions) { intention in
                            NavigationLink(destination: IntentionDetailView(intention: intention)) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(intention.text)
                                        .font(.headline)
                                        .foregroundColor(AppThemeManager.shared.primaryTextColor(for: colorScheme))

                                    HStack {
                                        Text(intention.scope.rawValue.capitalized)
                                            .font(.subheadline)
                                            .foregroundColor(AppThemeManager.shared.secondaryTextColor(for: colorScheme))

                                        Spacer()

                                        Text(intention.date, style: .date)
                                            .font(.caption)
                                            .foregroundColor(AppThemeManager.shared.secondaryTextColor(for: colorScheme))
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        .listStyle(.plain)
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