//
//  WatchOSIntentionsView.swift
//  Attunetion
//
//  Created for watchOS-specific intentions display
//

import SwiftUI
import SwiftData

#if os(watchOS)
import WatchKit
/// Main watchOS view for displaying and managing intentions
struct WatchOSIntentionsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager: AppThemeManager
    
    @State private var viewModel: IntentionsViewModel!
    @State private var selectedTab: Int = 0
    @State private var showingEditView = false
    @State private var editingScope: IntentionScope = .day
    @State private var editingIntention: Intention?
    
    private let scopes: [IntentionScope] = [.day, .week, .month]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                AppBackground(themeManager: themeManager)
                    .ignoresSafeArea()
                
                if viewModel != nil {
                    TabView(selection: $selectedTab) {
                        ForEach(Array(scopes.enumerated()), id: \.offset) { index, scope in
                            IntentionCardView(
                                scope: scope,
                                viewModel: viewModel!,
                                themeManager: themeManager,
                                onEdit: {
                                    editingScope = scope
                                    editingIntention = getCurrentIntention(for: scope)
                                    showingEditView = true
                                }
                            )
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .animation(.easeInOut(duration: 0.25), value: selectedTab)
                    .onChange(of: selectedTab) { oldValue, newValue in
                        // Haptic feedback when swiping between tabs
                        WKInterfaceDevice.current().play(.click)
                    }
                } else {
                    ProgressView()
                        .tint(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                }
            }
            .navigationTitle("Intentions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        // Haptic feedback
                        WKInterfaceDevice.current().play(.click)
                        // Determine which scope to edit based on current tab
                        editingScope = scopes[selectedTab]
                        editingIntention = nil // New intention
                        showingEditView = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                    }
                    .buttonStyle(.plain)
                }
            }
            .sheet(isPresented: $showingEditView) {
                WatchOSEditIntentionView(
                    scope: editingScope,
                    intention: editingIntention,
                    viewModel: viewModel
                )
            }
            .onChange(of: showingEditView) { _, isShowing in
                // Refresh when edit view dismisses
                if !isShowing {
                    viewModel?.loadIntentions()
                }
            }
            .onAppear {
                if viewModel == nil {
                    viewModel = IntentionsViewModel(modelContext: modelContext)
                }
                // Set initial tab based on current active intention
                if let current = viewModel?.currentIntention {
                    if let index = scopes.firstIndex(of: current.scope) {
                        selectedTab = index
                    }
                }
            }
        }
    }
    
    private func getCurrentIntention(for scope: IntentionScope) -> Intention? {
        guard let viewModel = viewModel else { return nil }
        let repository = IntentionRepository(modelContext: modelContext)
        let today = Date()
        return repository.getIntention(for: today, scope: scope)
    }
}

/// Individual intention card for watchOS
struct IntentionCardView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var modelContext
    let scope: IntentionScope
    let viewModel: IntentionsViewModel
    @ObservedObject var themeManager: AppThemeManager
    let onEdit: () -> Void
    
    @State private var currentIntention: Intention?
    
    private var theme: IntentionTheme? {
        guard let intention = currentIntention else { return nil }
        return viewModel.getTheme(for: intention)
    }
    
    private var scopeDisplayName: String {
        scope.rawValue.capitalized
    }
    
    private var scopeColor: Color {
        switch scope {
        case .day:
            return themeManager.accentColor(for: colorScheme).toSwiftUIColor()
        case .week:
            return themeManager.accentColor(for: colorScheme).toSwiftUIColor().opacity(0.85)
        case .month:
            return themeManager.accentColor(for: colorScheme).toSwiftUIColor().opacity(0.7)
        }
    }
    
    private var dateString: String {
        guard let intention = currentIntention else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: Date())
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: intention.date)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: WatchOSSpacing.large) {
                // Scope badge
                HStack {
                    Text(scopeDisplayName)
                        .font(WatchOSFonts.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(scopeColor)
                        )
                    
                    Spacer()
                }
                .padding(.horizontal, WatchOSSpacing.medium)
                .padding(.top, WatchOSSpacing.medium)
                
                // Intention content
                if let intention = currentIntention {
                    VStack(alignment: .leading, spacing: WatchOSSpacing.medium) {
                        // Intention text
                        Text(intention.text)
                            .font(WatchOSFonts.body)
                            .foregroundColor(theme?.textColorValue ?? themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                            .lineSpacing(4)
                            .multilineTextAlignment(.leading)
                        
                        // Date
                        Text(dateString)
                            .font(WatchOSFonts.caption)
                            .foregroundColor(theme?.textColorValue.opacity(0.8) ?? themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                        
                        // Quote if available
                        if let quote = intention.quote {
                            Divider()
                                .background((theme?.textColorValue ?? themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor()).opacity(0.3))
                            
                            Text(quote)
                                .font(WatchOSFonts.caption)
                                .italic()
                                .foregroundColor(theme?.textColorValue.opacity(0.9) ?? themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                                .lineSpacing(2)
                        }
                    }
                    .padding(WatchOSSpacing.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        Group {
                            if let theme = theme {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [theme.backgroundColorValue, theme.accentColorValue ?? theme.backgroundColorValue]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            } else {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(
                                        colorScheme == .dark
                                            ? themeManager.currentTheme.darkSecondaryButtonBackground.toSwiftUIColor().opacity(0.3)
                                            : Color.white.opacity(0.2)
                                    )
                            }
                        }
                    )
                    .padding(.horizontal, WatchOSSpacing.medium)
                    
                    // Edit button
                    Button(action: {
                        WKInterfaceDevice.current().play(.click)
                        onEdit()
                    }) {
                        HStack {
                            Image(systemName: "pencil")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Edit")
                                .font(WatchOSFonts.body)
                        }
                        .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, WatchOSSpacing.medium)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(scopeColor.opacity(0.2))
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, WatchOSSpacing.medium)
                    .padding(.top, WatchOSSpacing.small)
                } else {
                    // Empty state
                    VStack(spacing: WatchOSSpacing.medium) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 32, weight: .ultraLight))
                            .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                        
                        VStack(spacing: WatchOSSpacing.small) {
                            Text("No \(scopeDisplayName.lowercased()) intention")
                                .font(WatchOSFonts.headline)
                                .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                            
                            Text("Tap + to create one")
                                .font(WatchOSFonts.caption)
                                .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, WatchOSSpacing.large)
                }
                
                Spacer(minLength: WatchOSSpacing.large)
            }
        }
        .onAppear {
            loadIntention()
        }
        .onChange(of: viewModel.intentions) { _, _ in
            withAnimation(.easeInOut(duration: 0.2)) {
                loadIntention()
            }
        }
        .onChange(of: scope) { _, _ in
            loadIntention()
        }
    }
    
    private func loadIntention() {
        let repository = IntentionRepository(modelContext: modelContext)
        let today = Date()
        currentIntention = repository.getIntention(for: today, scope: scope)
    }
}

#endif

