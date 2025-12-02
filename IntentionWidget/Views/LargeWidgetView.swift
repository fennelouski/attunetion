//
//  LargeWidgetView.swift
//  IntentionWidget
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI
import WidgetKit

/// Large widget view (systemLarge)
struct LargeWidgetView: View {
    var entry: IntentionWidgetProvider.Entry
    
    var body: some View {
        ZStack {
            // Background
            if let theme = entry.theme {
                WidgetTheme.color(from: theme.backgroundColor)
            } else {
                Color.blue
            }
            
            VStack(alignment: .leading, spacing: 16) {
                // Scope badge at top
                if let intention = entry.intention {
                    HStack {
                        scopeBadge(for: intention.scope)
                        Spacer()
                    }
                    
                    Spacer()
                    
                    // Intention text (larger font)
                    Text(intention.text)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(entry.theme.map { WidgetTheme.color(from: $0.textColor) } ?? .white)
                        .lineLimit(6)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    // Quote (if available)
                    if let quote = intention.quote, !quote.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\"\(quote)\"")
                                .font(.system(size: 14, weight: .regular))
                                .italic()
                                .foregroundColor(entry.theme?.accentColor.map { WidgetTheme.color(from: $0) } ?? .white.opacity(0.9))
                        }
                        .padding(.vertical, 8)
                    }
                    
                    Spacer()
                    
                    // Date range at bottom
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.system(size: 14))
                        Text(formatDate(for: intention))
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(entry.theme?.accentColor.map { WidgetTheme.color(from: $0) } ?? .white.opacity(0.8))
                } else {
                    // Empty state
                    VStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No intention set")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.secondary)
                        Text("Tap to create one")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding(20)
        }
        .widgetURL(entry.intention.map { URL(string: "dailyintentions://intention/\($0.id.uuidString)") })
    }
    
    @ViewBuilder
    private func scopeBadge(for scope: String) -> some View {
        let (label, icon) = scopeInfo(for: scope)
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
            Text(label)
                .font(.system(size: 14, weight: .bold))
        }
        .foregroundColor(entry.theme?.accentColor.map { WidgetTheme.color(from: $0) } ?? .white)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(entry.theme?.accentColor.map { WidgetTheme.color(from: $0).opacity(0.2) } ?? Color.white.opacity(0.2))
        )
    }
    
    private func scopeInfo(for scope: String) -> (String, String) {
        switch scope.lowercased() {
        case "day":
            return ("Today", "sun.max.fill")
        case "week":
            return ("This Week", "calendar")
        case "month":
            return ("This Month", "calendar.badge.clock")
        default:
            return ("Today", "sun.max.fill")
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

