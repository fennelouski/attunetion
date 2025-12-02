//
//  SmallWidgetView.swift
//  IntentionWidget
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI
import WidgetKit

/// Small widget view (systemSmall)
struct SmallWidgetView: View {
    var entry: IntentionWidgetProvider.Entry
    
    var body: some View {
        ZStack {
            // Background
            if let theme = entry.theme {
                WidgetTheme.color(from: theme.backgroundColor)
            } else {
                Color.blue
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Spacer()
                
                // Intention text
                if let intention = entry.intention {
                    Text(intention.text)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(entry.theme.map { WidgetTheme.color(from: $0.textColor) } ?? .white)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    // Scope badge
                    HStack {
                        scopeBadge(for: intention.scope)
                        Spacer()
                    }
                } else {
                    // Empty state
                    VStack(spacing: 4) {
                        Text("No intention set")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        Text("Tap to create")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
            }
            .padding(12)
        }
        .widgetURL(entry.intention.map { URL(string: "dailyintentions://intention/\($0.id.uuidString)") })
    }
    
    @ViewBuilder
    private func scopeBadge(for scope: String) -> some View {
        let (label, icon) = scopeInfo(for: scope)
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(label)
                .font(.system(size: 10, weight: .medium))
        }
        .foregroundColor(entry.theme?.accentColor.map { WidgetTheme.color(from: $0) } ?? .white.opacity(0.8))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(entry.theme?.accentColor.map { WidgetTheme.color(from: $0).opacity(0.2) } ?? Color.white.opacity(0.2))
        )
    }
    
    private func scopeInfo(for scope: String) -> (String, String) {
        switch scope.lowercased() {
        case "day":
            return ("Day", "sun.max.fill")
        case "week":
            return ("Week", "calendar")
        case "month":
            return ("Month", "calendar.badge.clock")
        default:
            return ("Day", "sun.max.fill")
        }
    }
}

