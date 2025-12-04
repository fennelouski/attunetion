//
//  MediumWidgetView.swift
//  IntentionWidget
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI
import WidgetKit

/// Medium widget view (systemMedium) - Beautiful, intentional design
struct MediumWidgetView: View {
    var entry: IntentionWidgetProvider.Entry
    
    private var placeholderText: String {
        let frequency = WidgetDataService.shared.getDefaultIntentionFrequency()
        switch frequency {
        case "daily":
            return String(localized: "Set your intention for today")
        case "weekly":
            return String(localized: "Set your intention for this week")
        case "monthly":
            return String(localized: "Set your intention for this month")
        default:
            return String(localized: "Set your intention")
        }
    }
    
    var body: some View {
        ZStack {
            // Beautiful gradient background
            WidgetTheme.gradient(for: entry.theme)
            
            // Subtle overlay for depth
            WidgetTheme.overlayGradient()
            
            if let intention = entry.intention {
                VStack(alignment: .leading, spacing: 0) {
                    // Subtle scope indicator at top
                    HStack {
                        scopeBadge(for: intention.scope)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    
                    Spacer()
                    
                    // Main intention text - prominent and centered
                    Text(intention.text)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(entry.theme.map { WidgetTheme.color(from: $0.textColor) } ?? .white)
                        .multilineTextAlignment(.leading)
                        .lineLimit(4)
                        .lineSpacing(4)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    
                    Spacer()
                    
                    // Subtle date indicator at bottom
                    HStack {
                        Image(systemName: "calendar")
                            .font(.system(size: 11, weight: .medium))
                        Text(formatDate(for: intention))
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(entry.theme?.accentColor.map { WidgetTheme.color(from: $0).opacity(0.8) } ?? .white.opacity(0.7))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                }
            } else {
                // Empty state with contextual placeholder
                VStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 36, weight: .light))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(placeholderText)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, 16)
                    
                    Text(String(localized: "Tap to create one"))
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .widgetURL(entry.intention.flatMap { URL(string: "dailyintentions://intention/\($0.id.uuidString)") })
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
    
    @ViewBuilder
    private func scopeBadge(for scope: String) -> some View {
        let (label, icon) = scopeInfo(for: scope)
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .medium))
            Text(label)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
        }
        .foregroundColor(entry.theme?.accentColor.map { WidgetTheme.color(from: $0) } ?? .white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
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
