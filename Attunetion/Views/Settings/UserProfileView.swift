//
//  UserProfileView.swift
//  Attunetion
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI
import SwiftData

struct UserProfileView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: AppThemeManager
    
    @State private var userInfo: String = ""
    @State private var autoGenerateEnabled: Bool = false
    @State private var isSaving: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var showSuccess: Bool = false
    @State private var inputMode: InputMode = .freeform
    @State private var showConsentDialog: Bool = false
    
    // Structured input fields
    @State private var goals: String = ""
    @State private var values: String = ""
    @State private var challenges: String = ""
    @State private var focusAreas: String = ""
    
    private let userProfileRepository: UserProfileRepository
    private var profile: UserProfile
    
    init(modelContext: ModelContext) {
        let repository = UserProfileRepository(modelContext: modelContext)
        self.userProfileRepository = repository
        self.profile = repository.getOrCreateProfile()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground(themeManager: themeManager)
                
                Form {
                    Section {
                        // Input mode selector
                        Picker("Input Style", selection: $inputMode) {
                            Text("Free-form").tag(InputMode.freeform)
                            Text("Guided").tag(InputMode.guided)
                        }
                        .pickerStyle(.segmented)
                        .padding(.vertical, 4)
                        .onChange(of: inputMode) { oldValue, newValue in
                            // Sync data when switching modes
                            syncDataBetweenModes(from: oldValue, to: newValue)
                        }
                    } header: {
                        ThemedSectionHeader(text: "How would you like to share?", themeManager: themeManager)
                    } footer: {
                        ThemedSectionFooter(
                            text: inputMode == .freeform 
                                ? "Write freely about yourself, your goals, and what matters to you."
                                : "Answer what feels right - you can skip any question.",
                            themeManager: themeManager
                        )
                    }
                    
                    Section {
                        if inputMode == .freeform {
                            freeFormInput
                        } else {
                            guidedInput
                        }
                    } header: {
                        ThemedSectionHeader(text: "Your Information", themeManager: themeManager)
                    }
                    
                    Section {
                        Toggle(isOn: Binding(
                            get: { autoGenerateEnabled },
                            set: { newValue in
                                if newValue && !profile.hasAcceptedTerms {
                                    // Show consent dialog
                                    showConsentDialog = true
                                } else {
                                    autoGenerateEnabled = newValue
                                }
                            }
                        )) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Auto-Suggest Intentions")
                                    .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                                Text("Automatically receive personalized suggestions for daily, weekly, and monthly intentions based on your profile")
                                    .font(.caption)
                                    .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                            }
                        }
                        .tint(themeManager.accentColor(for: colorScheme).toSwiftUIColor())

                        if !profile.hasAcceptedTerms {
                            HStack {
                                Image(systemName: "info.circle")
                                    .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                                Text("Requires accepting Terms of Service")
                                    .font(.caption)
                                    .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                            }
                        }
                    } header: {
                        ThemedSectionHeader(
                            text: "Auto-Suggestions",
                            themeManager: themeManager
                        )
                    } footer: {
                        if autoGenerateEnabled {
                            ThemedSectionFooter(
                                text: "Suggestions will be created weekly. You can always edit or delete them. Your data may be shared with third-party services to generate suggestions.",
                                themeManager: themeManager
                            )
                        } else {
                            ThemedSectionFooter(
                                text: "Enable this to receive automatic suggestions for your intentions each week. You'll need to agree to our Terms of Service first.",
                                themeManager: themeManager
                            )
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Suggested Intentions")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveProfile()
                    }
                    .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                    .disabled(isSaving)
                }
            }
            .onAppear {
                loadProfile()
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .alert("Saved", isPresented: $showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your profile has been saved successfully.")
            }
            .sheet(isPresented: $showConsentDialog) {
                LegalConsentView(
                    onAccept: {
                        // User accepted terms
                        profile.hasAcceptedTerms = true
                        profile.termsAcceptedDate = Date()
                        try? userProfileRepository.update(profile)
                        autoGenerateEnabled = true
                    },
                    onDecline: {
                        // User declined - keep toggle off
                        autoGenerateEnabled = false
                    }
                )
            }
        }
    }
    
    private var freeFormInput: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tell us about yourself")
                .font(.headline)
                .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
            
            Text("Share anything that helps us create personalized suggestions for you. This could include your goals, values, interests, challenges, or anything else you'd like us to know.")
                .font(.subheadline)
                .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
            
            TextEditor(text: $userInfo)
                .frame(minHeight: 150)
                .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                .scrollContentBackground(.hidden)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.2),
                            lineWidth: 1
                        )
                )
            
            Text("This information is stored locally on your device and only used when generating suggestions. We don't store it on our servers.")
                .font(.caption)
                .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                .padding(.top, 4)
        }
        .padding(.vertical, 8)
    }
    
    private var guidedInput: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // Goals
            VStack(alignment: .leading, spacing: 8) {
                Text("What are you working toward?")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                
                TextField("e.g., Better health, career growth, stronger relationships", text: $goals, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.2),
                                lineWidth: 1
                            )
                    )
                    .lineLimit(2...4)
            }
            
            // Values/Interests
            VStack(alignment: .leading, spacing: 8) {
                Text("What matters most to you?")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                
                TextField("e.g., Family, creativity, learning, helping others", text: $values, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.2),
                                lineWidth: 1
                            )
                    )
                    .lineLimit(2...4)
            }
            
            // Challenges
            VStack(alignment: .leading, spacing: 8) {
                Text("What would you like to improve?")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                
                TextField("e.g., Managing stress, staying organized, being present", text: $challenges, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.2),
                                lineWidth: 1
                            )
                    )
                    .lineLimit(2...4)
            }
            
            // Focus Areas
            VStack(alignment: .leading, spacing: 8) {
                Text("What would you like to focus on?")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                
                TextField("e.g., Mindfulness, productivity, connection, growth", text: $focusAreas, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.2),
                                lineWidth: 1
                            )
                    )
                    .lineLimit(2...4)
            }
            
            Text("This information is stored locally on your device and only used when generating suggestions. We don't store it on our servers.")
                .font(.caption)
                .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                .padding(.top, 4)
        }
        .padding(.vertical, 8)
    }
    
    private func loadProfile() {
        userInfo = profile.userInfo
        autoGenerateEnabled = profile.autoGenerateEnabled
        
        // Parse structured data if it exists in userInfo
        parseStructuredData()
    }
    
    private func parseStructuredData() {
        // Try to parse structured data from userInfo
        // Format: "GOALS:...|VALUES:...|CHALLENGES:...|FOCUS:..."
        if userInfo.contains("|") {
            let parts = userInfo.components(separatedBy: "|")
            for part in parts {
                if part.hasPrefix("GOALS:") {
                    goals = String(part.dropFirst(6)).trimmingCharacters(in: .whitespaces)
                } else if part.hasPrefix("VALUES:") {
                    values = String(part.dropFirst(7)).trimmingCharacters(in: .whitespaces)
                } else if part.hasPrefix("CHALLENGES:") {
                    challenges = String(part.dropFirst(11)).trimmingCharacters(in: .whitespaces)
                } else if part.hasPrefix("FOCUS:") {
                    focusAreas = String(part.dropFirst(6)).trimmingCharacters(in: .whitespaces)
                }
            }
            
            // If we found structured data, switch to guided mode
            if !goals.isEmpty || !values.isEmpty || !challenges.isEmpty || !focusAreas.isEmpty {
                inputMode = .guided
            }
        }
    }
    
    private func syncDataBetweenModes(from oldMode: InputMode, to newMode: InputMode) {
        if oldMode == .freeform && newMode == .guided {
            // When switching from freeform to guided, try to extract structured data
            // This is optional - user can still fill in guided fields fresh
            // We don't auto-populate to avoid confusion
        } else if oldMode == .guided && newMode == .freeform {
            // When switching from guided to freeform, combine structured data into freeform
            if !goals.isEmpty || !values.isEmpty || !challenges.isEmpty || !focusAreas.isEmpty {
                userInfo = combineStructuredData()
            }
        }
    }
    
    private func combineStructuredData() -> String {
        var parts: [String] = []
        if !goals.isEmpty {
            parts.append("GOALS:\(goals)")
        }
        if !values.isEmpty {
            parts.append("VALUES:\(values)")
        }
        if !challenges.isEmpty {
            parts.append("CHALLENGES:\(challenges)")
        }
        if !focusAreas.isEmpty {
            parts.append("FOCUS:\(focusAreas)")
        }
        
        // Combine into a natural text format for the AI
        var combined = ""
        if !goals.isEmpty {
            combined += "Goals: \(goals). "
        }
        if !values.isEmpty {
            combined += "Values and interests: \(values). "
        }
        if !challenges.isEmpty {
            combined += "Areas for improvement: \(challenges). "
        }
        if !focusAreas.isEmpty {
            combined += "Focus areas: \(focusAreas). "
        }
        
        // Also store structured format for parsing
        let structured = parts.joined(separator: "|")
        return structured.isEmpty ? combined.trimmingCharacters(in: .whitespaces) : "\(combined.trimmingCharacters(in: .whitespaces))|\(structured)"
    }
    
    private func saveProfile() {
        isSaving = true
        defer { isSaving = false }
        
        do {
            // Combine data based on input mode
            if inputMode == .guided {
                profile.userInfo = combineStructuredData()
            } else {
                profile.userInfo = userInfo
            }
            
            profile.autoGenerateEnabled = autoGenerateEnabled
            try userProfileRepository.update(profile)
            showSuccess = true
        } catch {
            errorMessage = "Failed to save profile: \(error.localizedDescription)"
            showError = true
        }
    }
}

enum InputMode: String {
    case freeform
    case guided
}


