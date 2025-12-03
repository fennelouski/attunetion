//
//  LockScreenInlineWidgetView.swift
//  IntentionWidget
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI
import WidgetKit

/// Lock screen inline widget (accessoryInline)
struct LockScreenInlineWidgetView: View {
    var entry: IntentionWidgetProvider.Entry
    
    var body: some View {
        if let intention = entry.intention {
            HStack(spacing: 4) {
                Image(systemName: scopeIcon(for: intention.scope))
                    .font(.system(size: 10))
                Text(intention.text)
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(1)
            }
        } else {
            HStack(spacing: 4) {
                Image(systemName: "sparkles")
                    .font(.system(size: 10))
                Text("No intention set")
                    .font(.system(size: 12, weight: .medium))
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



