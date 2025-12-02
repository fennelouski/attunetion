//
//  MediumWidgetView.swift
//  IntentionWidget
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI
import WidgetKit

/// Medium widget view (systemMedium)
struct MediumWidgetView: View {
    var entry: IntentionWidgetProvider.Entry
    
    var body: some View {
        ZStack {
            // Background
            if let theme = entry.theme {
                WidgetTheme.color(from: theme.backgroundColor)
            } else {
                Color.blue
            }
            
            VStack(alignment: .leading, spacing: 12) {
                // Scope badge at top
                if let intention = entry.intention {
                    HStack {
                        scopeBadge(for: intention.scope)
                        Spacer()
                    }
                    
                    Spacer()
                    
                    // Intention text
                    Text(intention.text)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(entry.theme.map { WidgetTheme.color(from: $0.textColor) } ?? .white)
                        .lineLimit(4)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    // Date subtitle
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                        Text(formatDate(for: intention))
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(entry.theme?.accentColor.map { WidgetTheme.color(from: $0) } ?? .white.opacity(0.8))
                } else {
                    // Empty state
                    VStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 32))
                            .foregroundColor(.secondary)
                        Text("No intention set")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                        Text("Tap to create one")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding(16)
        }
        .widgetURL(entry.intention.map { URL(string: "dailyintentions://intention/\($0.id.uuidString)") })
    }
    
    @ViewBuilder
    private func scopeBadge(for scope: String) -> some View {
        let (label, icon) = scopeInfo(for: scope)
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text(label)
                .font(.system(size: 12, weight: .semibold))
        }
        .foregroundColor(entry.theme?.accentColor.map { WidgetTheme.color(from: $0) } ?? .white)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
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

