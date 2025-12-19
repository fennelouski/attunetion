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
            // Content
            if let intention = entry.intention {
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Intention text - centered and elegant
                    Text(intention.text)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(entry.theme.map { WidgetTheme.color(from: $0.textColor) } ?? .white)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .lineSpacing(2)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                }
            } else {
                // Empty state - elegant and inviting with contextual placeholder
                VStack(spacing: 8) {
                    Image(systemName: "target")
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
}
