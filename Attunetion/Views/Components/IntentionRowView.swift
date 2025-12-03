//
//  IntentionRowView.swift
//  Attunetion
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI
import SwiftData

struct IntentionRowView: View {
    @Environment(\.colorScheme) var colorScheme
    let intention: Intention
    @ObservedObject var themeManager: AppThemeManager
    
    init(intention: Intention, themeManager: AppThemeManager) {
        self.intention = intention
        self.themeManager = themeManager
    }
    
    private var scopeColor: Color {
        themeManager.accentColor(for: colorScheme).toSwiftUIColor()
    }
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: intention.date)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Scope badge
            Text(intention.scope.rawValue.capitalized)
                .font(.system(size: 11, weight: .semibold, design: .default))
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(scopeColor.opacity(0.8))
                )
            
            // Intention text
            VStack(alignment: .leading, spacing: 6) {
                Text(intention.text)
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .lineLimit(2)
                    .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                    .lineSpacing(2)
                
                Text(dateString)
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
            }
            
            Spacer()
            
            // AI badge if applicable
            if intention.aiGenerated {
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
            }
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.5))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    colorScheme == .dark
                        ? themeManager.currentTheme.darkSecondaryButtonBackground.toSwiftUIColor().opacity(0.3)
                        : Color.white.opacity(0.5)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(
                    themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.1),
                    lineWidth: 1
                )
        )
    }
}

#Preview {
    let container = try! ModelContainer(for: Intention.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let _ = container.mainContext
    
    // Create sample intentions for preview
    let intention1 = Intention(text: "Be present with family", scope: .day, date: Date())
    let intention2 = Intention(text: "Focus on health and wellness", scope: .week, date: Date())
    let intention3 = Intention(text: "Build meaningful connections", scope: .month, date: Date())
    
    VStack(spacing: 12) {
        IntentionRowView(intention: intention1, themeManager: AppThemeManager())
        IntentionRowView(intention: intention2, themeManager: AppThemeManager())
        IntentionRowView(intention: intention3, themeManager: AppThemeManager())
    }
    .padding()
    .background(AppBackground(themeManager: AppThemeManager()))
    .modelContainer(container)
}
