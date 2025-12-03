//
//  IntentionDetailView.swift
//  Attunetion
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI
import SwiftData
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct IntentionDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager: AppThemeManager
    let intention: Intention
    var viewModel: IntentionsViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var showingEdit = false
    @State private var showingFeedback = false
    
    private var theme: IntentionTheme? {
        viewModel.getTheme(for: intention)
    }
    
    private var scopeColor: Color {
        let accent = themeManager.accentColor(for: colorScheme).toSwiftUIColor()
        switch intention.scope {
        case .day: return accent.opacity(0.8)
        case .week: return accent.opacity(0.9)
        case .month: return accent
        }
    }
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: intention.date)
    }
    
    private var createdDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: intention.createdAt)
    }
    
    private var updatedDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: intention.updatedAt)
    }
    
    var body: some View {
        ZStack {
            AppBackground(themeManager: themeManager)
            
            ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Main intention card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(intention.scope.rawValue.capitalized)
                            .font(.system(size: 11, weight: .semibold, design: .default))
                            .foregroundColor(themeManager.buttonTextColor(for: colorScheme).toSwiftUIColor())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(scopeColor)
                            )
                        
                        if intention.aiGenerated {
                            HStack(spacing: 4) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 10, weight: .medium))
                                Text("Suggested")
                            }
                            .font(.system(size: 11, weight: .medium, design: .default))
                            .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(themeManager.accentColor(for: colorScheme).toSwiftUIColor().opacity(0.15))
                            )
                        }
                    }
                    
                    Text(intention.text)
                        .font(.system(size: 34, weight: .light, design: .default))
                        .foregroundColor(theme?.textColorValue ?? themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                        .lineSpacing(4)
                    
                    Text(dateString)
                        .font(.system(size: 15, weight: .regular, design: .default))
                        .foregroundColor(theme?.textColorValue.opacity(0.8) ?? themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                    
                    if let quote = intention.quote {
                        Divider()
                            .background(theme?.textColorValue.opacity(0.3) ?? themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.2))
                            .padding(.vertical, 8)
                        
                        Text(quote)
                            .font(.system(size: 20, weight: .light, design: .default))
                            .italic()
                            .foregroundColor(theme?.textColorValue.opacity(0.9) ?? themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                            .padding(.top, 4)
                    }
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
                .cornerRadius(16)
                
                // Metadata section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Details")
                        .font(.system(size: 20, weight: .light, design: .default))
                        .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                    
                    VStack(alignment: .leading, spacing: 12) {
                        DetailRow(label: "Created", value: createdDateString, themeManager: themeManager)
                        
                        if intention.updatedAt != intention.createdAt {
                            DetailRow(label: "Updated", value: updatedDateString, themeManager: themeManager)
                        }
                        
                        if let theme = theme {
                            DetailRow(label: "Theme", value: theme.name, themeManager: themeManager)
                        }
                        
                        if let fontName = intention.customFont {
                            DetailRow(label: "Font", value: fontName, themeManager: themeManager)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(
                            colorScheme == .dark
                                ? themeManager.currentTheme.darkSecondaryButtonBackground.toSwiftUIColor().opacity(0.4)
                                : Color.white.opacity(0.6)
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(
                            themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.1),
                            lineWidth: 1
                        )
                )
                
                // Actions
                VStack(spacing: 12) {
                    PrimaryButton("Edit Intention", themeManager: themeManager) {
                        showingEdit = true
                    }
                    
                    if intention.aiGenerated {
                        SecondaryButton("Give Feedback", themeManager: themeManager) {
                            showingFeedback = true
                        }
                    }
                    
                    SecondaryButton("Share", themeManager: themeManager) {
                        shareIntention()
                    }
                }
            }
            .padding()
            }
        }
        .navigationTitle("Intention")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .sheet(isPresented: $showingEdit) {
            EditIntentionView(intention: intention, viewModel: viewModel)
        }
        .sheet(isPresented: $showingFeedback) {
            IntentionFeedbackView(intention: intention, isPresented: $showingFeedback, modelContext: modelContext)
        }
        #if os(iOS) || os(macOS) || os(visionOS)
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: [shareText])
        }
        #endif
        .onChange(of: viewModel.intentions) { oldValue, newValue in
            // If the intention was deleted, dismiss the detail view
            if !newValue.contains(where: { $0.id == intention.id }) {
                dismiss()
            }
        }
    }
    
    @State private var showingShareSheet = false
    
    private func shareIntention() {
        #if os(iOS) || os(visionOS)
        showingShareSheet = true
        #elseif os(macOS)
        let text = "\(intention.text)\n\n\(intention.scope.rawValue.capitalized) • \(dateString)"
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        #elseif os(watchOS)
        // watchOS: Copy to pasteboard or use other sharing mechanism
        // For now, just log - watchOS sharing would typically be handled via Handoff or other mechanisms
        print("Share on watchOS: \(shareText)")
        #endif
    }
    
    private var shareText: String {
        "\(intention.text)\n\n\(intention.scope.rawValue.capitalized) • \(dateString)"
    }
}

struct DetailRow: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var themeManager: AppThemeManager
    let label: String
    let value: String
    
    init(label: String, value: String, themeManager: AppThemeManager) {
        self.label = label
        self.value = value
        self.themeManager = themeManager
    }
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .regular, design: .default))
                .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .regular, design: .default))
                .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: Intention.self, IntentionTheme.self, UserPreferences.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let context = container.mainContext
    let intention = Intention(text: "Focus on health and wellness", scope: .week, date: Date())
    let viewModel = IntentionsViewModel(modelContext: context)
    NavigationStack {
        IntentionDetailView(intention: intention, viewModel: viewModel)
    }
    .modelContainer(container)
}

