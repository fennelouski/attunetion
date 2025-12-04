//
//  NewIntentionView.swift
//  Attunetion
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI
import SwiftData
#if os(macOS)
import AppKit
#endif

struct NewIntentionView: View {
    var viewModel: IntentionsViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager: AppThemeManager
    
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
    @State private var showingGuide = false
    
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
                        .overlay(
                            Group {
                                if intentionText.isEmpty {
                                    Text(String(localized: "Enter your intention..."))
                                        .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                                        .padding(.top, 8)
                                        .padding(.leading, 5)
                                        .allowsHitTesting(false)
                                }
                            },
                            alignment: .topLeading
                        )
                    #endif
                    
                    // Character count and guide button
                    HStack {
                        if intentionText.isEmpty {
                            Button(action: {
                                #if os(iOS)
                                HapticFeedback.light()
                                #endif
                                showingGuide = true
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "lightbulb.fill")
                                        .font(.system(size: 14, weight: .medium))
                                    Text(String(localized: "Need inspiration?"))
                                        .font(.system(size: 14, weight: .medium, design: .default))
                                }
                                .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                            }
                        }
                        Spacer()
                        Text("\(characterCount)/100")
                            .font(.system(size: 12, weight: .regular, design: .default))
                            .foregroundColor(characterCount > 100 ? .red : themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                    }
                } header: {
                    ThemedSectionHeader(
                        text: String(localized: "Intention"),
                        themeManager: themeManager
                    )
                }
                
                Section {
                    // Scope selector
                    Picker(String(localized: "Scope"), selection: $selectedScope) {
                        ForEach(IntentionScope.allCases, id: \.self) { scope in
                            Text(scope.rawValue.capitalized).tag(scope)
                        }
                    }
                    .onChange(of: selectedScope) { _, _ in
                        selectedDate = defaultDateForScope
                    }
                    
                    // Date picker
                    DatePicker(
                        String(localized: "Date"),
                        selection: $selectedDate,
                        displayedComponents: selectedScope == .day ? [.date] : [.date]
                    )
                } header: {
                    Text(String(localized: "Timing"))
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
                            Text(String(localized: "Theme"))
                                .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                            Spacer()
                            if let theme = selectedTheme {
                                Text(theme.name)
                                    .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                            } else {
                                Text(String(localized: "None"))
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
                            Text(String(localized: "Font"))
                                .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                            Spacer()
                            if let fontId = selectedFont,
                               let fontOption = FontOption.all.first(where: { $0.id == fontId }) {
                                Text(fontOption.name)
                                    .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                            } else {
                                Text(String(localized: "System Default"))
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
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(String(localized: "New Intention"))
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
            .sheet(isPresented: $showingGuide) {
                IntentionGuideView(modelContext: modelContext)
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

struct IntentionPreviewCard: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var themeManager: AppThemeManager
    let text: String
    let scope: IntentionScope
    let date: Date
    let theme: IntentionTheme?
    let font: String?
    
    init(text: String, scope: IntentionScope, date: Date, theme: IntentionTheme?, font: String?, themeManager: AppThemeManager) {
        self.text = text
        self.scope = scope
        self.date = date
        self.theme = theme
        self.font = font
        self.themeManager = themeManager
    }
    
    private var scopeColor: Color {
        themeManager.accentColor(for: colorScheme).toSwiftUIColor()
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
                .font(.system(size: 11, weight: .semibold, design: .default))
                .foregroundColor(themeManager.buttonTextColor(for: colorScheme).toSwiftUIColor())
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(scopeColor)
                )
            
            Text(text)
                .font(previewFont)
                .fontWeight(.light)
                .foregroundColor(theme?.textColorValue ?? themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
            
            Text(dateString)
                .font(.system(size: 12, weight: .regular, design: .default))
                .foregroundColor(theme?.textColorValue.opacity(0.8) ?? themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Group {
                if let theme = theme {
                    LinearGradient(
                        gradient: Gradient(colors: [theme.backgroundColorValue, theme.accentColorValue]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                } else {
                    colorScheme == .dark
                        ? themeManager.currentTheme.darkSecondaryButtonBackground.toSwiftUIColor().opacity(0.4)
                        : Color.white.opacity(0.6)
                }
            }
        )
        .cornerRadius(12)
    }
}

#Preview {
    let container = try! ModelContainer(for: Intention.self, IntentionTheme.self, UserPreferences.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let context = container.mainContext
    let viewModel = IntentionsViewModel(modelContext: context)
    NewIntentionView(viewModel: viewModel)
        .modelContainer(container)
}

