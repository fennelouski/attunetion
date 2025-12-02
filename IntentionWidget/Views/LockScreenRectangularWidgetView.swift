//
//  LockScreenRectangularWidgetView.swift
//  IntentionWidget
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI
import WidgetKit

/// Lock screen rectangular widget (accessoryRectangular)
struct LockScreenRectangularWidgetView: View {
    var entry: IntentionWidgetProvider.Entry
    
    var body: some View {
        if let intention = entry.intention {
            HStack(spacing: 8) {
                // Scope icon
                Image(systemName: scopeIcon(for: intention.scope))
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
                
                // Intention text (compact, 2-3 lines max)
                Text(intention.text)
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
        } else {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 12))
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

