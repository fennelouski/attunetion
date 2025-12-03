//
//  IntentionFeedbackView.swift
//  Attunetion
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI
import SwiftData

struct IntentionFeedbackView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var themeManager: AppThemeManager
    
    let intention: Intention
    @Binding var isPresented: Bool
    
    @State private var isApproved: Bool? = nil
    @State private var feedbackText: String = ""
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var isSubmitting: Bool = false
    
    private let feedbackRepository: IntentionFeedbackRepository
    private var existingFeedback: IntentionFeedback?
    
    init(intention: Intention, isPresented: Binding<Bool>, modelContext: ModelContext) {
        self.intention = intention
        self._isPresented = isPresented
        self.feedbackRepository = IntentionFeedbackRepository(modelContext: modelContext)
        self.existingFeedback = feedbackRepository.getFeedback(for: intention.id)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground(themeManager: themeManager)
                
                Form {
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("How helpful was this suggestion?")
                                .font(.headline)
                                .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                            
                            HStack(spacing: 20) {
                                // Approve button
                                Button(action: {
                                    #if os(iOS)
                                    HapticFeedback.light()
                                    #endif
                                    isApproved = true
                                }) {
                                    VStack(spacing: 8) {
                                        Image(systemName: isApproved == true ? "hand.thumbsup.fill" : "hand.thumbsup")
                                            .font(.system(size: 32, weight: .medium))
                                            .foregroundColor(isApproved == true ? .green : themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                                        
                                        Text("Helpful")
                                            .font(.caption)
                                            .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(isApproved == true ? Color.green.opacity(0.1) : Color.clear)
                                    )
                                }
                                .buttonStyle(.plain)
                                
                                // Disapprove button
                                Button(action: {
                                    #if os(iOS)
                                    HapticFeedback.light()
                                    #endif
                                    isApproved = false
                                }) {
                                    VStack(spacing: 8) {
                                        Image(systemName: isApproved == false ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                                            .font(.system(size: 32, weight: .medium))
                                            .foregroundColor(isApproved == false ? .red : themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                                        
                                        Text("Not Helpful")
                                            .font(.caption)
                                            .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(isApproved == false ? Color.red.opacity(0.1) : Color.clear)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 8)
                    } header: {
                        ThemedSectionHeader(text: "Feedback", themeManager: themeManager)
                    }
                    
                    if isApproved != nil {
                        Section {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Optional: Tell us more (up to 100 characters)")
                                    .font(.subheadline)
                                    .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                                
                                TextEditor(text: $feedbackText)
                                    .frame(minHeight: 80)
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
                                    .onChange(of: feedbackText) { oldValue, newValue in
                                        // Limit to 100 characters
                                        if newValue.count > 100 {
                                            feedbackText = String(newValue.prefix(100))
                                        }
                                    }
                                
                                HStack {
                                    Spacer()
                                    Text("\(feedbackText.count)/100")
                                        .font(.caption)
                                        .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                                }
                            }
                            .padding(.vertical, 8)
                        } header: {
                            ThemedSectionHeader(text: "Additional Comments", themeManager: themeManager)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Feedback")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        submitFeedback()
                    }
                    .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                    .disabled(isApproved == nil || isSubmitting)
                }
            }
            .onAppear {
                // Load existing feedback if any
                if let existing = existingFeedback {
                    isApproved = existing.isApproved
                    feedbackText = existing.feedbackText ?? ""
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func submitFeedback() {
        guard let approved = isApproved else { return }
        
        // Check for prompt injection
        if !feedbackText.isEmpty && PromptInjectionFilter.containsPromptInjection(feedbackText) {
            errorMessage = "Your feedback contains content that cannot be processed. Please revise your message."
            showError = true
            return
        }
        
        isSubmitting = true
        defer { isSubmitting = false }
        
        do {
            // Sanitize feedback text
            let sanitizedText = feedbackText.isEmpty ? nil : PromptInjectionFilter.sanitize(feedbackText)
            
            // Update or create feedback
            if let existing = existingFeedback {
                existing.isApproved = approved
                existing.feedbackText = sanitizedText
                try modelContext.save()
            } else {
                let feedback = IntentionFeedback(
                    intentionId: intention.id,
                    isApproved: approved,
                    feedbackText: sanitizedText
                )
                try feedbackRepository.create(feedback)
                
                // Update user profile feedback count
                let profileRepo = UserProfileRepository(modelContext: modelContext)
                let profile = profileRepo.getOrCreateProfile()
                profile.totalFeedbackGiven += 1
                try profileRepo.update(profile)
            }
            
            isPresented = false
        } catch {
            errorMessage = "Failed to submit feedback: \(error.localizedDescription)"
            showError = true
        }
    }
}


