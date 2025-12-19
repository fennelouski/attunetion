//
//  LargeWidgetView.swift
//  IntentionWidget
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI
import WidgetKit

/// Large widget view (systemLarge) - Elegant, spacious design
struct LargeWidgetView: View {
    var entry: IntentionWidgetProvider.Entry
    
    private var placeholderText: String {
        let userState = WidgetDataService.shared.getUserState()
        
        // If we have user state, use it
        if let state = userState {
            // First time user
            if !state.hasSetIntentionsBefore {
                return String(localized: "Set your first intention")
            }
            
            // User has set intentions before - suggest today
            // Check if hasn't set monthly and it's been 10+ days
            if !state.hasSetMonthlyBefore, let days = state.daysSinceLastIntention, days >= 10 {
                return String(localized: "Try an intention pack to stay focused")
            }
            return String(localized: "Set your intention for today")
        }
        
        // No user state available - likely first time user or state not synced yet
        // Default to "Set your first intention" as it's the most helpful message
        return String(localized: "Set your first intention")
    }
    
    var body: some View {
        Group {
            if let intention = entry.intention {
                VStack(alignment: .leading, spacing: 0) {
                    // Scope badge at top
                    HStack {
                        scopeBadge(for: intention.scope)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    Spacer()
                    
                    // Main intention text - large, prominent, elegant
                    VStack(alignment: .leading, spacing: 12) {
                        Text(intention.text)
                            .font(.system(size: 26, weight: .semibold, design: .rounded))
                            .foregroundColor(entry.theme.map { WidgetTheme.color(from: $0.textColor) } ?? .white)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                            .lineSpacing(6)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // Quote (if available) - styled elegantly
                        if let quote = intention.quote, !quote.isEmpty {
                            Text("\"\(quote)\"")
                                .font(.system(size: 15, weight: .regular, design: .rounded))
                                .italic()
                                .foregroundColor(entry.theme?.accentColor.map { WidgetTheme.color(from: $0).opacity(0.9) } ?? .white.opacity(0.8))
                                .lineLimit(nil)
                                .padding(.top, 4)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    
                    Spacer()
                    
                    // Date range at bottom
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12, weight: .medium))
                        Text(formatDate(for: intention))
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(entry.theme?.accentColor.map { WidgetTheme.color(from: $0).opacity(0.8) } ?? .white.opacity(0.7))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }
            } else {
                // Empty state - elegant and inviting with contextual placeholder
                VStack(spacing: 16) {
                    Image(systemName: "target")
                        .font(.system(size: 48, weight: .light))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(placeholderText)
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, 20)
                    
                    Text(String(localized: "Tap to create one"))
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .widgetURL(entry.intention != nil 
            ? URL(string: "dailyintentions://intention/\(entry.intention!.id.uuidString)")
            : URL(string: "dailyintentions://new"))
        .containerBackground(for: .widget) {
            ZStack {
                // Beautiful gradient background
                WidgetTheme.gradient(for: entry.theme)
                
                // Subtle overlay for depth
                WidgetTheme.overlayGradient()
            }
        }
    }
    
    @ViewBuilder
    private func scopeBadge(for scope: String) -> some View {
        let (label, icon) = scopeInfo(for: scope)
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
            Text(label)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
        }
        .foregroundColor(entry.theme?.accentColor.map { WidgetTheme.color(from: $0) } ?? .white)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.2))
        )
    }
    
    private func scopeInfo(for scope: String) -> (String, String) {
        switch scope.lowercased() {
        case "day":
            return (String(localized: "Today"), "sun.max.fill")
        case "week":
            return (String(localized: "This Week"), "calendar")
        case "month":
            return (String(localized: "This Month"), "calendar.badge.clock")
        default:
            return (String(localized: "Today"), "sun.max.fill")
        }
    }
    
    private func formatDate(for intention: IntentionData) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        switch intention.scope.lowercased() {
        case "day":
            return formatter.string(from: intention.scopeDate)
        case "week":
            let calendar = Calendar.current
            let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: intention.scopeDate)?.start ?? intention.scopeDate
            let endOfWeek = calendar.dateInterval(of: .weekOfYear, for: intention.scopeDate)?.end ?? intention.scopeDate
            let startStr = formatter.string(from: startOfWeek)
            let endStr = formatter.string(from: calendar.date(byAdding: .day, value: -1, to: endOfWeek) ?? endOfWeek)
            return "\(startStr) - \(endStr)"
        case "month":
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: intention.scopeDate)
        default:
            return formatter.string(from: intention.scopeDate)
        }
    }
}
