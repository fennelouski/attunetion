//
//  EditIntentionView.swift
//  Daily Intentions
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI

struct EditIntentionView: View {
    let intention: MockIntention
    var viewModel: IntentionsViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var intentionText: String
    @State private var selectedScope: IntentionScope
    @State private var selectedDate: Date
    @State private var selectedTheme: PresetTheme?
    @State private var selectedFont: String?
    @State private var showingThemePicker = false
    @State private var showingFontPicker = false
    @State private var showingValidationAlert = false
    @State private var validationMessage = ""
    @State private var isGeneratingAITheme = false
    
    @State private var themeViewModel = ThemeViewModel()
    
    init(intention: MockIntention, viewModel: IntentionsViewModel) {
        self.intention = intention
        self.viewModel = viewModel
        _intentionText = State(initialValue: intention.text)
        _selectedScope = State(initialValue: intention.scope)
        _selectedDate = State(initialValue: intention.date)
        _selectedTheme = State(initialValue: MockData.getTheme(byId: intention.themeId ?? UUID()))
        _selectedFont = State(initialValue: intention.customFont)
    }
    
    private var characterCount: Int {
        intentionText.count
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    // Text editor
                    TextEditor(text: $intentionText)
                        .frame(minHeight: 120)
                    
                    // Character count
                    HStack {
                        Spacer()
                        Text("\(characterCount)/100")
                            .font(.caption)
                            .foregroundColor(characterCount > 100 ? .red : .secondary)
                    }
                } header: {
                    Text("Intention")
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
                    Text("Timing")
                }
                
                Section {
                    // Theme picker toggle
                    Button(action: {
                        showingThemePicker.toggle()
                    }) {
                        HStack {
                            Text("Theme")
                            Spacer()
                            if let theme = selectedTheme {
                                Text(theme.name)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("None")
                                    .foregroundColor(.secondary)
                            }
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if showingThemePicker {
                        ThemePickerView(
                            selectedTheme: $selectedTheme,
                            intentionText: intentionText
                        ) {
                            await generateAITheme()
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // Font picker toggle
                    Button(action: {
                        showingFontPicker.toggle()
                    }) {
                        HStack {
                            Text("Font")
                            Spacer()
                            if let fontId = selectedFont,
                               let fontOption = FontOption.all.first(where: { $0.id == fontId }) {
                                Text(fontOption.name)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("System Default")
                                    .foregroundColor(.secondary)
                            }
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if showingFontPicker {
                        FontPickerView(selectedFont: $selectedFont)
                            .padding(.vertical, 8)
                    }
                } header: {
                    Text("Customization")
                }
                
                // Preview section
                if !intentionText.isEmpty {
                    Section {
                        IntentionPreviewCard(
                            text: intentionText,
                            scope: selectedScope,
                            date: selectedDate,
                            theme: selectedTheme,
                            font: selectedFont
                        )
                    } header: {
                        Text("Preview")
                    }
                }
            }
            .navigationTitle("Edit Intention")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveIntention()
                    }
                    .disabled(intentionText.trimmingCharacters(in: .whitespacesAndNewlines).count < 3)
                }
            }
            .alert("Validation Error", isPresented: $showingValidationAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(validationMessage)
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
        
        // Check for duplicate (only if date or scope changed)
        if (selectedDate != intention.date || selectedScope != intention.scope) &&
           viewModel.intentionExists(for: selectedDate, scope: selectedScope) {
            validationMessage = "An intention already exists for this \(selectedScope.rawValue)."
            showingValidationAlert = true
            return
        }
        
        // Update intention
        var updatedIntention = intention
        updatedIntention.text = trimmedText
        updatedIntention.scope = selectedScope
        updatedIntention.date = selectedDate
        updatedIntention.themeId = selectedTheme?.id
        updatedIntention.customFont = selectedFont
        
        viewModel.updateIntention(updatedIntention)
        dismiss()
    }
    
    private func generateAITheme() async {
        guard !intentionText.isEmpty else { return }
        isGeneratingAITheme = true
        do {
            let theme = try await themeViewModel.generateAITheme(for: intentionText)
            selectedTheme = theme
        } catch {
            // Handle error (could show alert)
        }
        isGeneratingAITheme = false
    }
}

#Preview {
    EditIntentionView(
        intention: MockData.intentions[0],
        viewModel: IntentionsViewModel()
    )
}

