//
//  IntentionsListView.swift
//  Daily Intentions
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI
import SwiftData

struct IntentionsListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: IntentionsViewModel?
    @State private var showingNewIntention = false
    @State private var sortOrder: SortOrder = .newestFirst
    
    var body: some View {
        Group {
            if let viewModel = viewModel {
                NavigationStack {
                    VStack(spacing: 0) {
                        // Search bar
                        SearchBar(text: Binding(
                            get: { viewModel.searchQuery },
                            set: { viewModel.searchQuery = $0 }
                        ))
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                        // Scope filter
                        ScrollView(.horizontal, showsIndicators: false) {
                            ScopeSelector(selectedScope: Binding(
                                get: { viewModel.selectedScope },
                                set: { viewModel.selectedScope = $0 }
                            ))
                                .padding(.horizontal)
                        }
                        .padding(.vertical, 8)
                
                        // Content
                        if viewModel.filteredIntentions.isEmpty && viewModel.currentIntention == nil {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("Set your first intention")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Create a daily, weekly, or monthly intention to get started")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding()
                        } else {
                            ScrollView {
                                VStack(spacing: 16) {
                                    // Current intention card
                                    if let current = viewModel.currentIntention {
                                        NavigationLink(value: current.id) {
                                            CurrentIntentionCard(intention: current, viewModel: viewModel)
                                                .padding(.horizontal)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    
                                    // Past and future intentions
                                    if !viewModel.pastAndFutureIntentions.isEmpty {
                                        VStack(alignment: .leading, spacing: 8) {
                                            HStack {
                                                Text("All Intentions")
                                                    .font(.headline)
                                                
                                                Spacer()
                                                
                                                Menu {
                                                    ForEach(SortOrder.allCases, id: \.self) { order in
                                                        Button(action: {
                                                            sortOrder = order
                                                            viewModel.sortOrder = order
                                                        }) {
                                                            HStack {
                                                                Text(order.rawValue)
                                                                if sortOrder == order {
                                                                    Image(systemName: "checkmark")
                                                                }
                                                            }
                                                        }
                                                    }
                                                } label: {
                                                    HStack {
                                                        Text("Sort")
                                                        Image(systemName: "arrow.up.arrow.down")
                                                    }
                                                    .font(.subheadline)
                                                }
                                            }
                                            .padding(.horizontal)
                                            
                                            ForEach(viewModel.pastAndFutureIntentions) { intention in
                                                NavigationLink(value: intention.id) {
                                                    IntentionRowView(intention: intention)
                                                        .padding(.horizontal)
                                                }
                                                .buttonStyle(.plain)
                                            }
                                        }
                                    }
                                }
                                .padding(.vertical)
                            }
                        }
                    }
                    .navigationTitle("Daily Intentions")
                    .navigationDestination(for: UUID.self) { id in
                        if let intention = viewModel.intentions.first(where: { $0.id == id }) {
                            IntentionDetailView(intention: intention, viewModel: viewModel)
                        }
                    }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showingNewIntention = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .automatic) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                    }
                }
            }
                    .sheet(isPresented: $showingNewIntention) {
                        if let viewModel = viewModel {
                            NewIntentionView(viewModel: viewModel)
                        }
                    }
                    .onAppear {
                        if viewModel == nil {
                            viewModel = IntentionsViewModel(modelContext: modelContext)
                        }
                    }
                }
            } else {
                ProgressView()
                    .onAppear {
                        viewModel = IntentionsViewModel(modelContext: modelContext)
                    }
            }
        }
    }
}

struct CurrentIntentionCard: View {
    let intention: Intention
    let viewModel: IntentionsViewModel
    
    private var theme: IntentionTheme? {
        viewModel.getTheme(for: intention)
    }
    
    private var scopeColor: Color {
        switch intention.scope {
        case .day: return .blue
        case .week: return .green
        case .month: return .purple
        }
    }
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: intention.date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Current")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(scopeColor)
                    .cornerRadius(6)
                
                Spacer()
                
                if intention.aiGenerated {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                        Text("AI")
                    }
                    .font(.caption)
                    .foregroundColor(.orange)
                }
            }
            
            Text(intention.text)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(theme?.textColorValue ?? .primary)
            
            Text("\(intention.scope.rawValue.capitalized) • \(dateString)")
                .font(.subheadline)
                .foregroundColor(theme?.textColorValue.opacity(0.8) ?? .secondary)
            
            if let quote = intention.quote {
                Divider()
                Text(quote)
                    .font(.subheadline)
                    .italic()
                    .foregroundColor(theme?.textColorValue.opacity(0.9) ?? .secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Group {
                if let theme = theme {
                    LinearGradient(
                        colors: [theme.backgroundColorValue, theme.accentColorValue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                } else {
                    Color(.systemGray6)
                }
            }
        )
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    let container = try! ModelContainer(for: [Intention.self, IntentionTheme.self, UserPreferences.self], configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    return IntentionsListView()
        .modelContainer(container)
}

