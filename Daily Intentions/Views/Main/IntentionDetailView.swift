//
//  IntentionDetailView.swift
//  Daily Intentions
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct IntentionDetailView: View {
    let intention: MockIntention
    var viewModel: IntentionsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingEdit = false
    @State private var showingDeleteConfirmation = false
    
    private var theme: PresetTheme? {
        guard let themeId = intention.themeId else { return nil }
        return MockData.getTheme(byId: themeId)
    }
    
    private var scopeColor: Color {
        switch intention.scope {
        case .day: return .blue
        case .week: return .green
        case .month: return .purple
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
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Main intention card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(intention.scope.rawValue.capitalized)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(scopeColor)
                            .cornerRadius(6)
                        
                        if intention.aiGenerated {
                            HStack(spacing: 4) {
                                Image(systemName: "sparkles")
                                Text("AI Generated")
                            }
                            .font(.caption)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(6)
                        }
                    }
                    
                    Text(intention.text)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(theme?.textColor ?? .primary)
                    
                    Text(dateString)
                        .font(.subheadline)
                        .foregroundColor(theme?.textColor.opacity(0.8) ?? .secondary)
                    
                    if let quote = intention.quote {
                        Divider()
                            .background(theme?.textColor.opacity(0.3) ?? Color.secondary)
                        
                        Text(quote)
                            .font(.title3)
                            .italic()
                            .foregroundColor(theme?.textColor.opacity(0.9) ?? .secondary)
                            .padding(.top, 8)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    Group {
                        if let theme = theme {
                            LinearGradient(
                                colors: [theme.backgroundColor, theme.accentColor ?? theme.backgroundColor],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        } else {
                            Color(.systemGray6)
                        }
                    }
                )
                .cornerRadius(16)
                
                // Metadata section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Details")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        DetailRow(label: "Created", value: createdDateString)
                        
                        if intention.updatedAt != intention.createdAt {
                            DetailRow(label: "Updated", value: updatedDateString)
                        }
                        
                        if let theme = theme {
                            DetailRow(label: "Theme", value: theme.name)
                        }
                        
                        if let fontName = intention.customFont {
                            DetailRow(label: "Font", value: fontName)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Actions
                VStack(spacing: 12) {
                    Button(action: {
                        showingEdit = true
                    }) {
                        HStack {
                            Image(systemName: "pencil")
                            Text("Edit Intention")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        shareIntention()
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        showingDeleteConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(12)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Intention")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEdit) {
            EditIntentionView(intention: intention, viewModel: viewModel)
        }
        .alert("Delete Intention", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.deleteIntention(intention)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this intention? This action cannot be undone.")
        }
        #if os(iOS) || os(macOS) || os(visionOS)
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: [shareText])
        }
        #endif
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
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    NavigationStack {
        IntentionDetailView(
            intention: MockData.intentions[1],
            viewModel: IntentionsViewModel()
        )
    }
}

