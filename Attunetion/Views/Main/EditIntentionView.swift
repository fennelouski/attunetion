//
//  EditIntentionView.swift
//  Attunetion
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI
import SwiftData
#if os(iOS) || os(visionOS)
import UIKit
#endif

struct EditIntentionView: View {
    let intention: Intention
    var viewModel: IntentionsViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager: AppThemeManager
    
    @State private var intentionText: String
    @State private var selectedScope: IntentionScope
    @State private var selectedDate: Date
    @State private var selectedTheme: IntentionTheme?
    @State private var selectedFont: String?
    @State private var showingThemePicker = false
    @State private var showingFontPicker = false
    @State private var showingValidationAlert = false
    @State private var validationMessage = ""
    @State private var isGeneratingAITheme = false
    @State private var showingDeleteConfirmation = false
    
    init(intention: Intention, viewModel: IntentionsViewModel) {
        self.intention = intention
        self.viewModel = viewModel
        _intentionText = State(initialValue: intention.text)
        _selectedScope = State(initialValue: intention.scope)
        _selectedDate = State(initialValue: intention.date)
        _selectedTheme = State(initialValue: viewModel.getTheme(for: intention))
        _selectedFont = State(initialValue: intention.customFont)
    }
    
    private var characterCount: Int {
        intentionText.count
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground(themeManager: themeManager)
                
                Form {
                Section {
                    // Text editor
                    #if os(watchOS)
                    TextField("Enter your intention", text: $intentionText, axis: .vertical)
                        .lineLimit(5...10)
                    #else
                    TextEditor(text: $intentionText)
                        .frame(minHeight: 120)
                    #endif
                    
                    // Character count
                    HStack {
                        Spacer()
                        Text("\(characterCount)/100")
                            .font(.system(size: 12, weight: .regular, design: .default))
                            .foregroundColor(characterCount > 100 ? .red : themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                    }
                } header: {
                    ThemedSectionHeader(text: "Intention", themeManager: themeManager)
                }
                
                Section {
                    // Scope selector
                    Picker("Scope", selection: $selectedScope) {
                        ForEach(IntentionScope.allCases, id: \.self) { scope in
                            Text(scope.rawValue.capitalized).tag(scope)
                        }
                    }
                    
                    // Date picker
                    DatePicker(
                        "Date",
                        selection: $selectedDate,
                        displayedComponents: selectedScope == .day ? [.date] : [.date]
                    )
                } header: {
                    ThemedSectionHeader(text: "Timing", themeManager: themeManager)
                }
                
                Section {
                    // Theme picker toggle
                    Button(action: {
                        #if os(iOS)
                        HapticFeedback.light()
                        #endif
                        showingThemePicker.toggle()
                    }) {
                        HStack {
                            Text("Theme")
                                .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                            Spacer()
                            if let theme = selectedTheme {
                                Text(theme.name)
                                    .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                            } else {
                                Text("None")
                                    .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                            }
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                        }
                    }
                    
                    if showingThemePicker {
                        ThemePickerView(
                            selectedTheme: Binding(
                                get: { selectedTheme },
                                set: { selectedTheme = $0 }
                            ),
                            intentionText: intentionText,
                            modelContext: modelContext,
                            themeManager: themeManager
                        ) {
                            await generateAITheme()
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // Font picker toggle
                    Button(action: {
                        #if os(iOS)
                        HapticFeedback.light()
                        #endif
                        showingFontPicker.toggle()
                    }) {
                        HStack {
                            Text("Font")
                                .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                            Spacer()
                            if let fontId = selectedFont,
                               let fontOption = FontOption.all.first(where: { $0.id == fontId }) {
                                Text(fontOption.name)
                                    .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                            } else {
                                Text("System Default")
                                    .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                            }
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                        }
                    }
                    
                    if showingFontPicker {
                        FontPickerView(selectedFont: $selectedFont, themeManager: themeManager)
                            .padding(.vertical, 8)
                    }
                } header: {
                    ThemedSectionHeader(text: "Customization", themeManager: themeManager)
                }
                
                // Preview section
                if !intentionText.isEmpty {
                    Section {
                        IntentionPreviewCard(
                            text: intentionText,
                            scope: selectedScope,
                            date: selectedDate,
                            theme: selectedTheme,
                            font: selectedFont,
                            themeManager: themeManager
                        )
                    } header: {
                        ThemedSectionHeader(text: "Preview", themeManager: themeManager)
                    }
                }
                
                // Delete button section (only for existing intentions)
                Section {
                    Button(action: {
                        #if os(iOS)
                        HapticFeedback.medium()
                        #endif
                        showingDeleteConfirmation = true
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
                .scrollContentBackground(.hidden)
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
                    .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        #if os(iOS)
                        HapticFeedback.medium()
                        #endif
                        saveIntention()
                    }
                    .disabled(intentionText.trimmingCharacters(in: .whitespacesAndNewlines).count < 3)
                    .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                }
            }
            .alert("Validation Error", isPresented: $showingValidationAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(validationMessage)
            }
            .alert("Delete Intention", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteIntention()
                }
            } message: {
                Text("Are you sure you want to delete this intention? This action cannot be undone.")
            }
            #if os(iOS) || os(visionOS)
            .onChange(of: showingThemePicker) { oldValue, newValue in
                if newValue {
                    dismissKeyboard()
                }
            }
            .onChange(of: showingFontPicker) { oldValue, newValue in
                if newValue {
                    dismissKeyboard()
                }
            }
            #endif
        }
    }
    
    #if os(iOS) || os(visionOS)
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    #endif
    
    private func deleteIntention() {
        do {
            try viewModel.deleteIntention(intention)
            dismiss()
        } catch {
            validationMessage = "Failed to delete intention: \(error.localizedDescription)"
            showingValidationAlert = true
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
        
        // Check for duplicate (only if date or scope changed)
        if (selectedDate != intention.date || selectedScope != intention.scope) &&
           viewModel.intentionExists(for: selectedDate, scope: selectedScope) {
            validationMessage = "An intention already exists for this \(selectedScope.rawValue)."
            showingValidationAlert = true
            return
        }
        
        // Update intention
        intention.text = trimmedText
        intention.scope = selectedScope
        intention.date = selectedDate
        intention.themeId = selectedTheme?.id
        intention.customFont = selectedFont
        
        do {
            try viewModel.updateIntention(intention)
            dismiss()
        } catch {
            validationMessage = "Failed to update intention: \(error.localizedDescription)"
            showingValidationAlert = true
        }
    }
    
    private func generateAITheme() async {
        guard !intentionText.isEmpty else { return }
        isGeneratingAITheme = true
        
        do {
            let aiTheme = try await APIClient.shared.generateTheme(intentionText: intentionText)
            
            // Convert AI theme to IntentionTheme and save to repository
            let theme = IntentionTheme(
                name: aiTheme.name,
                backgroundColor: aiTheme.backgroundColor,
                textColor: aiTheme.textColor,
                accentColor: aiTheme.accentColor,
                isPreset: false,
                isAIGenerated: true
            )
            
            // Save theme to repository
            let themeRepo = ThemeRepository(modelContext: modelContext)
            do {
                try themeRepo.create(theme)
                selectedTheme = theme
            } catch {
                // If save fails, still use the theme (it just won't persist)
                selectedTheme = theme
                print("Warning: Failed to save AI theme to repository: \(error)")
            }
        } catch APIClient.APIError.noBaseURL {
            // Backend not configured - show helpful message
            validationMessage = "AI theme generation is not available. Backend API URL needs to be configured."
            showingValidationAlert = true
        } catch APIClient.APIError.rateLimitExceeded(let retryAfter) {
            if let retryAfter = retryAfter {
                validationMessage = "Rate limit exceeded. Please try again in \(Int(retryAfter)) seconds."
            } else {
                validationMessage = "Rate limit exceeded. Please try again later."
            }
            showingValidationAlert = true
        } catch {
            validationMessage = "Failed to generate AI theme: \(error.localizedDescription)"
            showingValidationAlert = true
        }
        
        isGeneratingAITheme = false
    }
}

#Preview {
    let container = try! ModelContainer(for: Intention.self, IntentionTheme.self, UserPreferences.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let context = container.mainContext
    let intention = Intention(text: "Be present with family", scope: .day, date: Date())
    let viewModel = IntentionsViewModel(modelContext: context)
    EditIntentionView(intention: intention, viewModel: viewModel)
        .modelContainer(container)
}

