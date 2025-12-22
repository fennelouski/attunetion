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
    @State private var showingDeleteAlert = false

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: intention.date)
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

                        // Actions
                        VStack(spacing: 12) {
                            PrimaryButton("Edit Intention", action: {
                                showingEdit = true
                            })

                            SecondaryButton("Delete Intention", action: {
                                showingDeleteAlert = true
                            })
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Intention")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Back") {
                        dismiss()
                    }
                    .foregroundColor(AppThemeManager.shared.secondaryTextColor(for: colorScheme))
                }
            }
            .sheet(isPresented: $showingEdit) {
                EditIntentionView(intention: intention)
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

struct EditIntentionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme

    let intention: Intention

    @State private var text: String
    @State private var scope: IntentionScope
    @State private var date: Date

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
                    .foregroundColor(AppThemeManager.shared.buttonTextColor(for: colorScheme))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(AppThemeManager.shared.accentColor(for: colorScheme))
                    .cornerRadius(8)
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
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
}

#Preview {
    let container = try! ModelContainer(for: Intention.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let context = container.mainContext
    let intention = Intention(text: "Focus on health and wellness", scope: .week, date: Date())

    NavigationStack {
        IntentionDetailView(intention: intention)
    }
    .modelContainer(container)
}
