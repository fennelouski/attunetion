//
//  IntentionsListView.swift
//  Attunetion
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI
import SwiftData
#if os(macOS)
import AppKit
#endif

struct IntentionsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager: AppThemeManager
    @State private var viewModel: IntentionsViewModel!
    @State private var showingNewIntention = false
    @State private var showingGuide = false
    @State private var sortOrder: SortOrder = .newestFirst
    @State private var isSearchBarVisible = false
    @State private var buttonWidth: CGFloat = 0
    
    private var verticalPadding: CGFloat {
        #if os(iOS)
        return 16
        #else
        return 20
        #endif
    }
    
    private var toolbarButtonFontSize: CGFloat {
        #if os(iOS)
        return 18
        #else
        return 16
        #endif
    }
    
    private var toolbarButtonSize: CGFloat {
        #if os(iOS)
        return 44
        #else
        return 32
        #endif
    }
    
    private var horizontalPadding: CGFloat {
        #if os(watchOS)
        return 8
        #elseif os(iOS)
        return 20
        #else
        return 24
        #endif
    }
    
    private var topPadding: CGFloat {
        #if os(watchOS)
        return 8
        #elseif os(iOS)
        return 12
        #else
        return 16
        #endif
    }
    
    private var verticalScopePadding: CGFloat {
        #if os(watchOS)
        return 6
        #elseif os(iOS)
        return 10
        #else
        return 12
        #endif
    }
    
    private var vStackSpacing: CGFloat {
        #if os(watchOS)
        return 12
        #elseif os(iOS)
        return 16
        #else
        return 20
        #endif
    }
    
    private var cardHorizontalPadding: CGFloat {
        #if os(watchOS)
        return 8
        #elseif os(iOS)
        return 20
        #else
        return 24
        #endif
    }
    
    // Empty state spacing and sizing
    private var emptyStateVStackSpacing: CGFloat {
        #if os(watchOS)
        return 16
        #else
        return 24
        #endif
    }
    
    private var emptyStateIconSize: CGFloat {
        #if os(watchOS)
        return 40
        #else
        return 64
        #endif
    }
    
    private var emptyStateInnerVStackSpacing: CGFloat {
        #if os(watchOS)
        return 8
        #else
        return 12
        #endif
    }
    
    private var emptyStateTitleFontSize: CGFloat {
        #if os(watchOS)
        return 18
        #else
        return 28
        #endif
    }
    
    private var emptyStateTitleFontDesign: Font.Design {
        #if os(watchOS)
        return .rounded
        #else
        return .default
        #endif
    }
    
    private var emptyStateSubtitleFontSize: CGFloat {
        #if os(watchOS)
        return 13
        #else
        return 16
        #endif
    }
    
    private var emptyStateSubtitleFontDesign: Font.Design {
        #if os(watchOS)
        return .rounded
        #else
        return .default
        #endif
    }
    
    private var emptyStateHorizontalPadding: CGFloat {
        #if os(watchOS)
        return 16
        #else
        return 40
        #endif
    }
    
    // Guide button styling for macOS
    #if os(macOS)
    private var guideFontSize: CGFloat { 16 }
    private var guideVerticalPadding: CGFloat { 14 }
    private var guideHorizontalPadding: CGFloat { 16 }
    private var guideTopPadding: CGFloat { 12 }
    private var createButtonFontSize: CGFloat { 19 }
    private var createButtonHeight: CGFloat { 52 }
    private var createButtonCornerRadius: CGFloat { 14 }
    private var createButtonShadowRadius: CGFloat { 8 }
    private var createButtonShadowY: CGFloat { 4 }
    #else
    private var guideFontSize: CGFloat { 15 }
    private var guideVerticalPadding: CGFloat { 12 }
    private var guideHorizontalPadding: CGFloat { 0 }
    private var guideTopPadding: CGFloat { 4 }
    private var createButtonFontSize: CGFloat { 17 }
    private var createButtonHeight: CGFloat { 50 }
    private var createButtonCornerRadius: CGFloat { 12 }
    private var createButtonShadowRadius: CGFloat { 6 }
    private var createButtonShadowY: CGFloat { 2 }
    #endif
    
    /// Check if search button should be shown (requires at least 3 intentions)
    private var shouldShowSearchButton: Bool {
        guard let viewModel = viewModel else { return false }
        return viewModel.intentions.count >= 3
    }
    
    var body: some View {
        Group {
            if viewModel != nil {
                NavigationStack {
                    ZStack {
                        // Custom background
                        AppBackground(themeManager: themeManager)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 0) {
                            // Search bar (conditionally shown)
                            if isSearchBarVisible {
                                SearchBar(
                                    text: Binding(
                                        get: { viewModel.searchQuery },
                                        set: { viewModel.searchQuery = $0 }
                                    ),
                                    themeManager: themeManager
                                )
                                .padding(.horizontal, horizontalPadding)
                                .padding(.top, topPadding)
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }
                            
                            // Scope filter (only show if multiple scope types exist)
                            if let availableScopes = viewModel.availableScopes {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    ScopeSelector(
                                        selectedScope: Binding(
                                            get: { viewModel.selectedScope },
                                            set: { viewModel.selectedScope = $0 }
                                        ),
                                        themeManager: themeManager,
                                        availableScopes: availableScopes
                                    )
                                    .padding(.horizontal, 24)
                                }
                                .padding(.vertical, verticalScopePadding)
                            }
                            
                            // Content
                            if viewModel.filteredIntentions.isEmpty && viewModel.currentIntention == nil {
                                // Empty state
                                VStack(spacing: emptyStateVStackSpacing) {
                                    AnimatedSparklesIcon(
                                        size: emptyStateIconSize,
                                        color: themeManager.accentColor(for: colorScheme).toSwiftUIColor()
                                    )
                                    
                                    VStack(spacing: emptyStateInnerVStackSpacing) {
                                        Text(String(localized: "Set your first intention"))
                                            .font(.system(size: emptyStateTitleFontSize, weight: .light, design: emptyStateTitleFontDesign))
                                            .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                                        
                                        Text(String(localized: "Create a daily, weekly, or monthly intention to get started"))
                                            .font(.system(size: emptyStateSubtitleFontSize, weight: .regular, design: emptyStateSubtitleFontDesign))
                                            .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, emptyStateHorizontalPadding)
                                    }
                                    
                                    // Buttons container - ensures equal width based on longest content
                                    VStack(spacing: guideTopPadding) {
                                        // Create Intention button (primary action) - bottom
                                        Button(action: {
                                            #if os(iOS)
                                            HapticFeedback.medium()
                                            #endif
                                            showingNewIntention = true
                                        }) {
                                            Text(String(localized: "Create Intention"))
                                                .font(.system(size: createButtonFontSize, weight: .semibold, design: .default))
                                                .foregroundColor(themeManager.buttonTextColor(for: colorScheme).toSwiftUIColor())
                                                .frame(width: buttonWidth > 0 ? buttonWidth : nil)
                                                .frame(height: createButtonHeight)
                                                .background {
                                                    RoundedRectangle(cornerRadius: createButtonCornerRadius, style: .continuous)
                                                        .fill(themeManager.buttonBackgroundColor(for: colorScheme).toSwiftUIColor())
                                                }
                                                .shadow(
                                                    color: themeManager.buttonBackgroundColor(for: colorScheme).toSwiftUIColor().opacity(0.3),
                                                    radius: createButtonShadowRadius,
                                                    x: 0,
                                                    y: createButtonShadowY
                                                )
                                        }
                                        .buttonStyle(.plain)
                                        .frame(width: buttonWidth > 0 ? buttonWidth : nil)
                                        
                                        // Guide button (longer text) - top, measure its natural width
                                        Button(action: {
                                            #if os(iOS)
                                            HapticFeedback.light()
                                            #endif
                                            showingGuide = true
                                        }) {
                                            HStack(spacing: 8) {
                                                Image(systemName: "questionmark.circle")
                                                    .font(.system(size: guideFontSize, weight: .medium))
                                                Text(String(localized: "How to create good intentions"))
                                                    .font(.system(size: guideFontSize, weight: .medium, design: .default))
                                            }
                                            .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                                            .padding(.vertical, guideVerticalPadding)
                                            .padding(.horizontal, guideHorizontalPadding)
                                            #if os(macOS)
                                            .background {
                                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                    .fill(themeManager.accentColor(for: colorScheme).toSwiftUIColor().opacity(0.1))
                                            }
                                            #endif
                                        }
                                        .buttonStyle(.plain)
                                        .fixedSize(horizontal: buttonWidth == 0, vertical: false)
                                        .frame(width: buttonWidth > 0 ? buttonWidth : nil)
                                        .background(
                                            GeometryReader { geometry in
                                                Color.clear.preference(
                                                    key: ButtonWidthPreferenceKey.self,
                                                    value: geometry.size.width
                                                )
                                            }
                                        )
                                    }
                                    .onPreferenceChange(ButtonWidthPreferenceKey.self) { width in
                                        if width > 0 && buttonWidth == 0 {
                                            buttonWidth = width
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, horizontalPadding)
                                    .padding(.top, 8)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            } else {
                                ScrollView {
                                    VStack(spacing: vStackSpacing) {
                                        // Current intention card
                                        if let current = viewModel.currentIntention {
                                            NavigationLink(value: current.id) {
                                                CurrentIntentionCard(
                                                    intention: current,
                                                    viewModel: viewModel,
                                                    themeManager: themeManager
                                                )
                                                .padding(.horizontal, cardHorizontalPadding)
                                            }
                                            .buttonStyle(.plain)
                                            #if os(iOS)
                                            .simultaneousGesture(
                                                TapGesture().onEnded {
                                                    HapticFeedback.light()
                                                }
                                            )
                                            #endif
                                        }
                                        
                                        // Past and future intentions
                                        if !viewModel.pastAndFutureIntentions.isEmpty {
                                            VStack(alignment: .leading, spacing: 16) {
                                                HStack {
                                                    Text(String(localized: "All Intentions"))
                                                        .font(.system(size: 20, weight: .light, design: .default))
                                                        .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                                                    
                                                    Spacer()
                                                    
                                                    #if os(watchOS)
                                                    Picker("Sort", selection: $sortOrder) {
                                                        ForEach(SortOrder.allCases, id: \.self) { order in
                                                            Text(order.localizedName).tag(order)
                                                        }
                                                    }
                                                    .onChange(of: sortOrder) { oldValue, newValue in
                                                        viewModel.sortOrder = newValue
                                                    }
                                                    #else
                                                    Menu {
                                                        ForEach(SortOrder.allCases, id: \.self) { order in
                                                            Button(action: {
                                                                sortOrder = order
                                                                viewModel.sortOrder = order
                                                            }) {
                                                                HStack {
                                                                    Text(order.localizedName)
                                                                    if sortOrder == order {
                                                                        Image(systemName: "checkmark")
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    } label: {
                                                        HStack(spacing: 6) {
                                                            Text(String(localized: "Sort"))
                                                                .font(.system(size: 14, weight: .medium, design: .default))
                                                                .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                                                            Image(systemName: "arrow.up.arrow.down")
                                                                .font(.system(size: 12, weight: .medium))
                                                                .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                                                        }
                                                    }
                                                    #endif
                                                }
                                                .padding(.horizontal, 24)
                                                
                                                ForEach(viewModel.pastAndFutureIntentions) { intention in
                                                    NavigationLink(value: intention.id) {
                                                        IntentionRowView(
                                                            intention: intention,
                                                            themeManager: themeManager
                                                        )
                                                        .padding(.horizontal, cardHorizontalPadding)
                                                    }
                                                    .buttonStyle(.plain)
                                                    #if os(iOS)
                                                    .simultaneousGesture(
                                                        TapGesture().onEnded {
                                                            HapticFeedback.light()
                                                        }
                                                    )
                                                    #endif
                                                }
                                            }
                                        }
                                        
                                        // Guide button at bottom (always available)
                                        Button(action: {
                                            #if os(iOS)
                                            HapticFeedback.light()
                                            #endif
                                            showingGuide = true
                                        }) {
                                            HStack(spacing: 8) {
                                                Image(systemName: "lightbulb.fill")
                                                    .font(.system(size: 16, weight: .medium))
                                                Text(String(localized: "Need help? Learn how to create great intentions"))
                                                    .font(.system(size: 15, weight: .medium, design: .default))
                                            }
                                            .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                                            .padding(.vertical, 14)
                                            .padding(.horizontal, 20)
                                            .frame(maxWidth: .infinity)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                    .fill(themeManager.accentColor(for: colorScheme).toSwiftUIColor().opacity(0.1))
                                            )
                                        }
                                        .padding(.horizontal, cardHorizontalPadding)
                                        .padding(.top, 8)
                                        .padding(.bottom, verticalPadding)
                                    }
                                    .padding(.vertical, verticalPadding)
                                }
                                #if os(iOS)
                                .refreshable {
                                    // Pull-to-refresh: reload theme in case it changed on another device
                                    themeManager.loadThemePreference()
                                    viewModel.loadIntentions()
                                }
                                #endif
                            }
                        }
                    }
                    .navigationTitle(String(localized: "Attunetion"))
                    #if os(iOS)
                    .navigationBarTitleDisplayMode(.large)
                    #endif
                    .navigationDestination(for: UUID.self) { id in
                        if let intention = viewModel.intentions.first(where: { $0.id == id }) {
                            IntentionDetailView(intention: intention, viewModel: viewModel)
                        }
                    }
                    .toolbar {
                        if shouldShowSearchButton {
                            #if os(iOS)
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: {
                                    HapticFeedback.light()
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        isSearchBarVisible.toggle()
                                        if !isSearchBarVisible {
                                            // Clear search when hiding
                                            viewModel.searchQuery = ""
                                        }
                                    }
                                }) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: toolbarButtonFontSize, weight: .medium))
                                        .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                                        .frame(width: toolbarButtonSize, height: toolbarButtonSize)
                                }
                            }
                            #else
                            ToolbarItem(placement: .automatic) {
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        isSearchBarVisible.toggle()
                                        if !isSearchBarVisible {
                                            // Clear search when hiding
                                            viewModel.searchQuery = ""
                                        }
                                    }
                                }) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: toolbarButtonFontSize, weight: .medium))
                                        .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                                        .frame(width: toolbarButtonSize, height: toolbarButtonSize)
                                }
                            }
                            #endif
                        }
                        
                        ToolbarItem(placement: .primaryAction) {
                            Button(action: {
                                #if os(iOS)
                                HapticFeedback.medium()
                                #endif
                                showingNewIntention = true
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: toolbarButtonFontSize, weight: .medium))
                                    .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                                    .frame(width: toolbarButtonSize, height: toolbarButtonSize)
                            }
                            .transaction { transaction in
                                transaction.animation = nil
                            }
                        }
                        
                        ToolbarItem(placement: .automatic) {
                            NavigationLink(destination: SettingsView()) {
                                Image(systemName: "gearshape")
                                    .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                            }
                            .transaction { transaction in
                                transaction.animation = nil
                            }
                        }
                    }
                    .sheet(isPresented: $showingNewIntention) {
                        NewIntentionView(viewModel: viewModel)
                    }
                    .sheet(isPresented: $showingGuide) {
                        IntentionGuideView(modelContext: modelContext)
                    }
                    .onChange(of: showingGuide) { oldValue, newValue in
                        // Reload intentions when guide dismisses (user may have created intentions)
                        if oldValue == true && newValue == false {
                            viewModel?.loadIntentions()
                        }
                    }
                    .onChange(of: viewModel.intentions.count) { oldCount, newCount in
                        // Hide search bar if intentions drop below 3
                        if newCount < 3 && isSearchBarVisible {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                isSearchBarVisible = false
                                viewModel.searchQuery = ""
                            }
                        }
                    }
                    .onAppear {
                        if viewModel == nil {
                            viewModel = IntentionsViewModel(modelContext: modelContext)
                        }
                    }
                }
            } else {
                ZStack {
                    AppBackground(themeManager: themeManager)
                    ProgressView()
                        .tint(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                }
                .onAppear {
                    viewModel = IntentionsViewModel(modelContext: modelContext)
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = IntentionsViewModel(modelContext: modelContext)
            }
        }
    }
}

struct CurrentIntentionCard: View {
    @Environment(\.colorScheme) var colorScheme
    let intention: Intention
    let viewModel: IntentionsViewModel
    @ObservedObject var themeManager: AppThemeManager
    
    private var theme: IntentionTheme? {
        viewModel.getTheme(for: intention)
    }
    
    private var scopeColor: Color {
        switch intention.scope {
        case .day: return themeManager.accentColor(for: colorScheme).toSwiftUIColor()
        case .week: return themeManager.accentColor(for: colorScheme).toSwiftUIColor().opacity(0.8)
        case .month: return themeManager.accentColor(for: colorScheme).toSwiftUIColor().opacity(0.6)
        }
    }
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: intention.date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(String(localized: "Current"))
                    .font(.system(size: 12, weight: .semibold, design: .default))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(scopeColor)
                    )
                
                Spacer()
                
                if intention.aiGenerated {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                        Text(String(localized: "AI"))
                    }
                    .font(.system(size: 11, weight: .medium, design: .default))
                    .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(themeManager.accentColor(for: colorScheme).toSwiftUIColor().opacity(0.15))
                    )
                }
            }
            
            Text(intention.text)
                .font(.system(size: 28, weight: .light, design: .default))
                .foregroundColor(theme?.textColorValue ?? themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                .lineSpacing(4)
            
            Text("\(intention.scope.rawValue.capitalized) • \(dateString)")
                .font(.system(size: 15, weight: .regular, design: .default))
                .foregroundColor(theme?.textColorValue.opacity(0.8) ?? themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
            
            if let quote = intention.quote {
                Divider()
                    .background(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.2))
                
                Text(quote)
                    .font(.system(size: 16, weight: .light, design: .default))
                    .italic()
                    .foregroundColor(theme?.textColorValue.opacity(0.9) ?? themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                    .lineSpacing(4)
            }
        }
        .padding(24)
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
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            colorScheme == .dark
                                ? themeManager.currentTheme.darkSecondaryButtonBackground.toSwiftUIColor().opacity(0.4)
                                : Color.white.opacity(0.6)
                        )
                }
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(
                    themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.1),
                    lineWidth: 1
                )
        )
        .shadow(
            color: themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.08),
            radius: 12,
            x: 0,
            y: 4
        )
    }
}

// PreferenceKey to measure button width
struct ButtonWidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

#Preview {
    let container = try! ModelContainer(for: Intention.self, IntentionTheme.self, UserPreferences.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    IntentionsListView()
        .modelContainer(container)
        .environmentObject(AppThemeManager())
}
