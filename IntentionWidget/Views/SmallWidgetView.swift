//
//  SmallWidgetView.swift
//  IntentionWidget
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI
import WidgetKit

/// Small widget view (systemSmall) - Beautiful, centered design
struct SmallWidgetView: View {
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
            
            // Content
            if let intention = entry.intention {
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Intention text - centered and elegant
                    Text(intention.text)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(entry.theme.map { WidgetTheme.color(from: $0.textColor) } ?? .white)
                        .multilineTextAlignment(.center)
                        .lineLimit(4)
                        .lineSpacing(2)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    
                    Spacer()
                }
            } else {
                // Empty state - elegant and inviting with contextual placeholder
                VStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(placeholderText)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, 8)
                    
                    Text(String(localized: "Tap to create"))
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .widgetURL(entry.intention.flatMap { URL(string: "dailyintentions://intention/\($0.id.uuidString)") })
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
