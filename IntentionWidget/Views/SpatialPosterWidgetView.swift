//
//  SpatialPosterWidgetView.swift
//  IntentionWidget
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI
import WidgetKit

/// Spatial poster widget view optimized for visionOS virtual space
/// Designed to be pinned/anchored in the user's virtual environment
struct SpatialPosterWidgetView: View {
    var entry: IntentionWidgetProvider.Entry
    
    var body: some View {
        ZStack {
            // Background with subtle depth effect
            if let theme = entry.theme {
                WidgetTheme.color(from: theme.backgroundColor)
            } else {
                Color.blue
            }
            
            VStack(alignment: .leading, spacing: 24) {
                // Scope badge at top
                if let intention = entry.intention {
                    HStack {
                        scopeBadge(for: intention.scope)
                        Spacer()
                    }
                    
                    Spacer()
                    
                    // Intention text (large, bold, readable from distance)
                    Text(intention.text)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(entry.theme.map { WidgetTheme.color(from: $0.textColor) } ?? .white)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .minimumScaleFactor(0.7)
                    
                    Spacer()
                    
                    // Quote (if available) - displayed prominently
                    if let quote = intention.quote, !quote.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\"\(quote)\"")
                                .font(.system(size: 24, weight: .regular, design: .serif))
                                .italic()
                                .foregroundColor(entry.theme?.accentColor.map { WidgetTheme.color(from: $0) } ?? .white.opacity(0.9))
                        }
                        .padding(.vertical, 12)
                    }
                    
                    Spacer()
                    
                    // Date range at bottom
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .font(.system(size: 20))
                        Text(formatDate(for: intention))
                            .font(.system(size: 20, weight: .medium))
                    }
                    .foregroundColor(entry.theme?.accentColor.map { WidgetTheme.color(from: $0) } ?? .white.opacity(0.8))
                } else {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 64))
                            .foregroundColor(.secondary)
                        Text(String(localized: "No intention set"))
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.secondary)
                        Text(String(localized: "Tap to create one"))
                            .font(.system(size: 20))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding(32)
        }
        .widgetURL(entry.intention.flatMap { URL(string: "dailyintentions://intention/\($0.id.uuidString)") })
        #if os(visionOS)
        // Add depth and dimension for spatial display
        .containerBackground(.clear, for: .widget)
        #endif
    }
    
    @ViewBuilder
    private func scopeBadge(for scope: String) -> some View {
        let (label, icon) = scopeInfo(for: scope)
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
            Text(label)
                .font(.system(size: 20, weight: .bold))
        }
        .foregroundColor(entry.theme?.accentColor.map { WidgetTheme.color(from: $0) } ?? .white)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(entry.theme?.accentColor.map { WidgetTheme.color(from: $0).opacity(0.2) } ?? Color.white.opacity(0.2))
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
        formatter.dateStyle = .long
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

