//
//  IntentionDetailView.swift
//  Daily Intentions
//
//  Created for viewing and editing individual intentions
//

import SwiftUI
import SwiftData

struct IntentionDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme

    let intention: Intention
    @State private var showingEdit = false

    private var dateString: String {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        
        if intention.scope == .month {
            let intentionYear = calendar.component(.year, from: intention.date)
            let intentionMonth = calendar.component(.month, from: intention.date)
            
            // Show year if: not current year OR January OR December
            let shouldShowYear = intentionYear != currentYear || intentionMonth == 1 || intentionMonth == 12
            
            let formatter = DateFormatter()
            if shouldShowYear {
                formatter.dateFormat = "MMMM yyyy"
            } else {
                formatter.dateFormat = "MMMM"
            }
            return formatter.string(from: intention.date)
        } else if intention.scope == .week {
            // Get the week interval (start and end dates)
            guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: intention.date) else {
                // Fallback to single date if we can't get week interval
                let formatter = DateFormatter()
                formatter.dateStyle = .long
                formatter.timeStyle = .none
                return formatter.string(from: intention.date)
            }
            
            let weekStart = weekInterval.start
            let weekEnd = calendar.date(byAdding: .day, value: -1, to: weekInterval.end) ?? weekInterval.end
            
            let startYear = calendar.component(.year, from: weekStart)
            let startMonth = calendar.component(.month, from: weekStart)
            
            let endYear = calendar.component(.year, from: weekEnd)
            let endMonth = calendar.component(.month, from: weekEnd)
            
            let sameMonth = startMonth == endMonth
            let sameYear = startYear == endYear
            
            // Determine if we should show year based on rules
            let shouldShowYear = !sameYear || startYear != currentYear || startMonth == 1 || startMonth == 12 || endMonth == 1 || endMonth == 12
            
            let formatter = DateFormatter()
            
            if !sameYear {
                // Different years: show full dates with years
                formatter.dateFormat = "MMMM d, yyyy"
                let startStr = formatter.string(from: weekStart)
                formatter.dateFormat = "MMMM d, yyyy"
                let endStr = formatter.string(from: weekEnd)
                return "\(startStr) – \(endStr)"
            } else if !sameMonth {
                // Different months, same year
                if shouldShowYear {
                    formatter.dateFormat = "MMMM d"
                    let startStr = formatter.string(from: weekStart)
                    formatter.dateFormat = "MMMM d, yyyy"
                    let endStr = formatter.string(from: weekEnd)
                    return "\(startStr) – \(endStr)"
                } else {
                    formatter.dateFormat = "MMMM d"
                    let startStr = formatter.string(from: weekStart)
                    formatter.dateFormat = "MMMM d"
                    let endStr = formatter.string(from: weekEnd)
                    return "\(startStr) – \(endStr)"
                }
            } else {
                // Same month, same year
                formatter.dateFormat = "MMMM d"
                let startStr = formatter.string(from: weekStart)
                
                if shouldShowYear {
                    formatter.dateFormat = "d, yyyy"
                    let endStr = formatter.string(from: weekEnd)
                    return "\(startStr) – \(endStr)"
                } else {
                    formatter.dateFormat = "d"
                    let endStr = formatter.string(from: weekEnd)
                    return "\(startStr) – \(endStr)"
                }
            }
        } else {
            // Day scope
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .none
            return formatter.string(from: intention.date)
        }
    }

    private var scopeColor: Color {
        switch intention.scope {
        case .day: return AppThemeManager.shared.accentColor(for: colorScheme).opacity(0.8)
        case .week: return AppThemeManager.shared.accentColor(for: colorScheme).opacity(0.9)
        case .month: return AppThemeManager.shared.accentColor(for: colorScheme)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppThemeManager.shared.backgroundColor(for: colorScheme)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Main intention card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text(intention.scope.rawValue.capitalized)
                                    .font(.system(size: 11, weight: .semibold, design: .default))
                                    .foregroundColor(AppThemeManager.shared.buttonTextColor(for: colorScheme))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .fill(scopeColor)
                                    )
                            }

                            Text(intention.text)
                                .font(.system(size: 34, weight: .light, design: .default))
                                .foregroundColor(AppThemeManager.shared.primaryTextColor(for: colorScheme))
                                .lineSpacing(4)

                            Text(dateString)
                                .font(.system(size: 15, weight: .regular, design: .default))
                                .foregroundColor(AppThemeManager.shared.secondaryTextColor(for: colorScheme))
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(
                                    colorScheme == .dark
                                        ? AppThemeManager.shared.secondaryButtonBackground(for: colorScheme).opacity(0.4)
                                        : Color.white.opacity(0.6)
                                )
                        )

                    }
                    .padding()
                }
            }
            .navigationTitle("Intention")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Edit") {
                        showingEdit = true
                    }
                    .foregroundColor(AppThemeManager.shared.secondaryTextColor(for: colorScheme))
                }
            }
            .sheet(isPresented: $showingEdit) {
                EditIntentionView(intention: intention)
            }
            .onChange(of: showingEdit) { oldValue, newValue in
                // When edit sheet is dismissed, check if intention was deleted
                if oldValue && !newValue {
                    checkIfIntentionStillExists()
                }
            }
        }
    }
    
    private func checkIfIntentionStillExists() {
        // Extract the UUID first to avoid predicate closure capture issues
        let intentionId = intention.id
        
        // Try to fetch the intention by its ID to see if it still exists
        let descriptor = FetchDescriptor<Intention>(
            predicate: #Predicate<Intention> { $0.id == intentionId }
        )
        
        if let _ = try? modelContext.fetch(descriptor).first {
            // Intention still exists, do nothing
            return
        } else {
            // Intention was deleted, dismiss the detail view
            dismiss()
        }
    }
}

struct EditIntentionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme

    let intention: Intention

    @State private var text: String
    @State private var scope: IntentionScope
    @State private var date: Date
    @State private var showingDeleteAlert = false

    init(intention: Intention) {
        self.intention = intention
        _text = State(initialValue: intention.text)
        _scope = State(initialValue: intention.scope)
        _date = State(initialValue: intention.date)
    }

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
                
                Section {
                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        HStack {
                            Spacer()
                            Text("Delete Intention")
                                .font(.system(size: 16, weight: .medium, design: .default))
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Edit Intention")
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
                        saveChanges()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.regular)
                    .tint(AppThemeManager.shared.accentColor(for: colorScheme))
                    .foregroundColor(AppThemeManager.shared.buttonTextColor(for: colorScheme))
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .alert("Delete Intention", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    deleteIntention()
                }
            } message: {
                Text("Are you sure you want to delete this intention? This action cannot be undone.")
            }
        }
    }

    private func saveChanges() {
        intention.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        intention.scope = scope
        intention.date = date

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving changes: \(error)")
        }
    }
    
    private func deleteIntention() {
        modelContext.delete(intention)
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error deleting intention: \(error)")
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: Intention.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let intention = Intention(text: "Focus on health and wellness", scope: .week, date: Date())

    NavigationStack {
        IntentionDetailView(intention: intention)
    }
    .modelContainer(container)
}
