//
//  NewIntentionView.swift
//  Daily Intentions
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI
import SwiftData

struct NewIntentionView: View {
    var viewModel: IntentionsViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var intentionText: String = ""
    @State private var selectedScope: IntentionScope = .day
    @State private var selectedDate: Date = Date()
    @State private var selectedTheme: IntentionTheme? = nil
    @State private var selectedFont: String? = nil
    @State private var showingThemePicker = false
    @State private var showingFontPicker = false
    @State private var showingValidationAlert = false
    @State private var validationMessage = ""
    @State private var isGeneratingAITheme = false
    
    @State private var themeViewModel = ThemeViewModel()
    
    private var characterCount: Int {
        intentionText.count
    }
    
    private var defaultDateForScope: Date {
        let calendar = Calendar.current
        switch selectedScope {
        case .day:
            return Date()
        case .week:
            return calendar.startOfDay(for: Date())
        case .month:
            return calendar.date(from: calendar.dateComponents([.year, .month], from: Date())) ?? Date()
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    // Text editor
                    TextEditor(text: $intentionText)
                        .frame(minHeight: 120)
                        .overlay(
                            Group {
                                if intentionText.isEmpty {
                                    Text("Enter your intention...")
                                        .foregroundColor(.secondary)
                                        .padding(.top, 8)
                                        .padding(.leading, 5)
                                        .allowsHitTesting(false)
                                }
                            },
                            alignment: .topLeading
                        )
                    
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
                    .onChange(of: selectedScope) { _, _ in
                        selectedDate = defaultDateForScope
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
                            selectedTheme: Binding(
                                get: { selectedTheme },
                                set: { selectedTheme = $0 }
                            ),
                            intentionText: intentionText,
                            modelContext: modelContext
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
            .navigationTitle("New Intention")
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
            .onAppear {
                selectedDate = defaultDateForScope
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
        
        // Check for duplicate
        if viewModel.intentionExists(for: selectedDate, scope: selectedScope) {
            validationMessage = "An intention already exists for this \(selectedScope.rawValue)."
            showingValidationAlert = true
            return
        }
        
        // Create new intention
        let newIntention = Intention(
            text: trimmedText,
            scope: selectedScope,
            date: selectedDate,
            themeId: selectedTheme?.id,
            customFont: selectedFont,
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

struct IntentionPreviewCard: View {
    let text: String
    let scope: IntentionScope
    let date: Date
    let theme: IntentionTheme?
    let font: String?
    
    private var scopeColor: Color {
        switch scope {
        case .day: return .blue
        case .week: return .green
        case .month: return .purple
        }
    }
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private var previewFont: Font {
        guard let fontId = font,
              let fontOption = FontOption.all.first(where: { $0.id == fontId }) else {
            return .system(.body, design: .default)
        }
        return fontOption.font
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(scope.rawValue.capitalized)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(scopeColor)
                .cornerRadius(6)
            
            Text(text)
                .font(previewFont)
                .fontWeight(.semibold)
                .foregroundColor(theme?.textColorValue ?? .primary)
            
            Text(dateString)
                .font(.caption)
                .foregroundColor(theme?.textColorValue.opacity(0.8) ?? .secondary)
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
        .cornerRadius(12)
    }
}

#Preview {
    let container = try! ModelContainer(for: [Intention.self, IntentionTheme.self, UserPreferences.self], configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let context = container.mainContext
    let viewModel = IntentionsViewModel(modelContext: context)
    return NewIntentionView(viewModel: viewModel)
        .modelContainer(container)
}

