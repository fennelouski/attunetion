//
//  WatchOSEditIntentionView.swift
//  Attunetion
//
//  Created for watchOS-specific intention editing with keyboard support
//

import SwiftUI
import SwiftData

#if os(watchOS)
import WatchKit
/// watchOS-specific view for editing or creating intentions with keyboard support
struct WatchOSEditIntentionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager: AppThemeManager
    
    let scope: IntentionScope
    let intention: Intention?
    let viewModel: IntentionsViewModel
    
    @State private var intentionText: String = ""
    @State private var selectedDate: Date = Date()
    @State private var showingValidationAlert = false
    @State private var validationMessage = ""
    @FocusState private var isTextFieldFocused: Bool
    
    private var isEditing: Bool {
        intention != nil
    }
    
    private var characterCount: Int {
        intentionText.count
    }
    
    private var defaultDateForScope: Date {
        let calendar = Calendar.current
        switch scope {
        case .day:
            return Date()
        case .week:
            return calendar.startOfDay(for: Date())
        case .month:
            return calendar.date(from: calendar.dateComponents([.year, .month], from: Date())) ?? Date()
        }
    }
    
    init(scope: IntentionScope, intention: Intention?, viewModel: IntentionsViewModel) {
        self.scope = scope
        self.intention = intention
        self.viewModel = viewModel
        _intentionText = State(initialValue: intention?.text ?? "")
        _selectedDate = State(initialValue: intention?.date ?? Date())
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground(themeManager: themeManager)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: WatchOSSpacing.large) {
                        // Header
                        VStack(spacing: WatchOSSpacing.small) {
                            Text(isEditing ? "Edit Intention" : "New \(scope.rawValue.capitalized) Intention")
                                .font(WatchOSFonts.headline)
                                .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                            
                            Text(scope.rawValue.capitalized)
                                .font(WatchOSFonts.caption)
                                .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(themeManager.accentColor(for: colorScheme).toSwiftUIColor().opacity(0.2))
                                )
                        }
                        .padding(.top, WatchOSSpacing.medium)
                        
                        // Text input with watchOS keyboard
                        VStack(alignment: .leading, spacing: WatchOSSpacing.small) {
                            TextField(
                                "Enter your intention",
                                text: $intentionText,
                                axis: .vertical
                            )
                            .focused($isTextFieldFocused)
                            .lineLimit(3...8)
                            .font(WatchOSFonts.body)
                            .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                            .padding(WatchOSSpacing.medium)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(
                                        colorScheme == .dark
                                            ? themeManager.currentTheme.darkSecondaryButtonBackground.toSwiftUIColor().opacity(0.3)
                                            : Color.white.opacity(0.2)
                                    )
                            )
                            
                            // Character count
                            HStack {
                                Spacer()
                                Text("\(characterCount)/100")
                                    .font(WatchOSFonts.caption)
                                    .foregroundColor(
                                        characterCount > 100
                                            ? .red
                                            : themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor()
                                    )
                            }
                        }
                        .padding(.horizontal, WatchOSSpacing.medium)
                        
                        // Date picker (simplified for watchOS)
                        VStack(alignment: .leading, spacing: WatchOSSpacing.small) {
                            Text("Date")
                                .font(WatchOSFonts.caption)
                                .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                            
                            DatePicker(
                                "",
                                selection: $selectedDate,
                                displayedComponents: [.date]
                            )
                            .datePickerStyle(.compact)
                            .labelsHidden()
                        }
                        .padding(.horizontal, WatchOSSpacing.medium)
                        
                        // Action buttons
                        VStack(spacing: WatchOSSpacing.medium) {
                            // Save button
                            Button(action: {
                                WKInterfaceDevice.current().play(.success)
                                saveIntention()
                            }) {
                                HStack {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .semibold))
                                    Text("Save")
                                        .font(WatchOSFonts.headline)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, WatchOSSpacing.medium)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(
                                            intentionText.trimmingCharacters(in: .whitespacesAndNewlines).count >= 3
                                                ? themeManager.accentColor(for: colorScheme).toSwiftUIColor()
                                                : themeManager.accentColor(for: colorScheme).toSwiftUIColor().opacity(0.5)
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                            .disabled(intentionText.trimmingCharacters(in: .whitespacesAndNewlines).count < 3)
                            
                            // Cancel button
                            Button(action: {
                                WKInterfaceDevice.current().play(.click)
                                dismiss()
                            }) {
                                Text("Cancel")
                                    .font(WatchOSFonts.body)
                                    .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, WatchOSSpacing.medium)
                            }
                            .buttonStyle(.plain)
                            
                            // Delete button (only when editing)
                            if isEditing {
                                Button(action: {
                                    WKInterfaceDevice.current().play(.failure)
                                    deleteIntention()
                                }) {
                                    HStack {
                                        Image(systemName: "trash")
                                            .font(.system(size: 14, weight: .semibold))
                                        Text("Delete")
                                            .font(WatchOSFonts.body)
                                    }
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, WatchOSSpacing.medium)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(Color.red.opacity(0.15))
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, WatchOSSpacing.medium)
                        .padding(.top, WatchOSSpacing.small)
                        
                        Spacer(minLength: WatchOSSpacing.large)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .alert("Validation Error", isPresented: $showingValidationAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(validationMessage)
            }
            .onAppear {
                // Auto-focus text field when view appears
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isTextFieldFocused = true
                }
                
                if selectedDate == Date() {
                    selectedDate = defaultDateForScope
                }
            }
        }
    }
    
    private func saveIntention() {
        let trimmedText = intentionText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Validation
        guard trimmedText.count >= 3 else {
            validationMessage = "Intention must be at least 3 characters long."
            showingValidationAlert = true
            return
        }
        
        guard trimmedText.count <= 100 else {
            validationMessage = "Intention must be 100 characters or less."
            showingValidationAlert = true
            return
        }
        
        if let existingIntention = intention {
            // Update existing intention
            // Check for duplicate (only if date or scope changed)
            if (selectedDate != existingIntention.date || scope != existingIntention.scope) &&
               viewModel.intentionExists(for: selectedDate, scope: scope) {
                validationMessage = "An intention already exists for this \(scope.rawValue)."
                showingValidationAlert = true
                return
            }
            
            existingIntention.text = trimmedText
            existingIntention.scope = scope
            existingIntention.date = selectedDate
            existingIntention.updatedAt = Date()
            
            do {
                try viewModel.updateIntention(existingIntention)
                dismiss()
            } catch {
                validationMessage = "Failed to update intention: \(error.localizedDescription)"
                showingValidationAlert = true
            }
        } else {
            // Create new intention
            // Check for duplicate
            if viewModel.intentionExists(for: selectedDate, scope: scope) {
                validationMessage = "An intention already exists for this \(scope.rawValue)."
                showingValidationAlert = true
                return
            }
            
            let newIntention = Intention(
                text: trimmedText,
                scope: scope,
                date: selectedDate,
                aiGenerated: false
            )
            
            do {
                try viewModel.addIntention(newIntention)
                dismiss()
            } catch {
                validationMessage = "Failed to save intention: \(error.localizedDescription)"
                showingValidationAlert = true
            }
        }
    }
    
    private func deleteIntention() {
        guard let intentionToDelete = intention else { return }
        
        do {
            try viewModel.deleteIntention(intentionToDelete)
            dismiss()
        } catch {
            validationMessage = "Failed to delete intention: \(error.localizedDescription)"
            showingValidationAlert = true
        }
    }
}

#endif

