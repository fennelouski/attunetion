//
//  LockScreenCircularWidgetView.swift
//  IntentionWidget
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI
import WidgetKit

/// Lock screen circular widget (accessoryCircular)
struct LockScreenCircularWidgetView: View {
    var entry: IntentionWidgetProvider.Entry
    
    var body: some View {
        ZStack {
            // Background circle
            if let theme = entry.theme {
                Circle()
                    .fill(WidgetTheme.color(from: theme.backgroundColor))
            } else {
                Circle()
                    .fill(Color.blue)
            }
            
            // Content
            if let intention = entry.intention {
                VStack(spacing: 2) {
                    // Scope icon
                    Image(systemName: scopeIcon(for: intention.scope))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(entry.theme.map { WidgetTheme.color(from: $0.textColor) } ?? .white)
                    
                    // First letter of intention
                    Text(String(intention.text.prefix(1)).uppercased())
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(entry.theme.map { WidgetTheme.color(from: $0.textColor) } ?? .white)
                }
            } else {
                Image(systemName: "sparkles")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func scopeIcon(for scope: String) -> String {
        switch scope.lowercased() {
        case "day":
            return "sun.max.fill"
        case "week":
            return "calendar"
        case "month":
            return "calendar.badge.clock"
        default:
            return "sun.max.fill"
        }
    }
}



