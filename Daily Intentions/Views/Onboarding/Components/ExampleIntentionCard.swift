//
//  ExampleIntentionCard.swift
//  Daily Intentions
//
//  Created for onboarding experience
//

import SwiftUI
#if os(macOS)
import AppKit
#endif

/// Example intention data model
struct ExampleIntention {
    let text: String
    let scope: IntentionScope
    let category: String
}

extension ExampleIntention {
    static let examples: [ExampleIntention] = [
        // Personal Growth
        ExampleIntention(text: "Practice gratitude daily", scope: .day, category: "Growth"),
        ExampleIntention(text: "Engage with books mindfully", scope: .day, category: "Learning"),
        ExampleIntention(text: "Be present with loved ones", scope: .day, category: "Relationships"),

        // Health & Wellness
        ExampleIntention(text: "Move my body joyfully", scope: .day, category: "Health"),
        ExampleIntention(text: "Choose nourishing foods", scope: .week, category: "Health"),
        ExampleIntention(text: "Prioritize rest and recovery", scope: .week, category: "Wellness"),

        // Productivity
        ExampleIntention(text: "Focus on deep work", scope: .day, category: "Productivity"),
        ExampleIntention(text: "Work with focus and purpose", scope: .day, category: "Productivity"),
        ExampleIntention(text: "Show up consistently for my project", scope: .month, category: "Growth"),

        // Mindfulness
        ExampleIntention(text: "Start the day with meditation", scope: .day, category: "Mindfulness"),
        ExampleIntention(text: "Practice mindful breathing", scope: .week, category: "Mindfulness"),
        ExampleIntention(text: "Cultivate inner peace", scope: .month, category: "Mindfulness"),

        // Creativity
        ExampleIntention(text: "Create something new", scope: .day, category: "Creativity"),
        ExampleIntention(text: "Explore a creative hobby", scope: .week, category: "Creativity"),
        ExampleIntention(text: "Show up for my creative work", scope: .month, category: "Creativity"),

        // Additional examples
        ExampleIntention(text: "Express kindness to someone", scope: .day, category: "Relationships"),
        ExampleIntention(text: "Stay open to new ideas", scope: .week, category: "Learning"),
        ExampleIntention(text: "Build meaningful connections", scope: .month, category: "Relationships"),
        ExampleIntention(text: "Take time for self-care", scope: .day, category: "Wellness"),
        ExampleIntention(text: "Reflect on my progress", scope: .week, category: "Growth"),
    ]
}

/// Card view for displaying example intentions
struct ExampleIntentionCard: View {
    @Environment(\.colorScheme) var colorScheme
    let intention: ExampleIntention
    let onTap: () -> Void

    init(intention: ExampleIntention, onTap: @escaping () -> Void) {
        self.intention = intention
        self.onTap = onTap
    }

    var body: some View {
        Button(action: {
            #if os(iOS)
            HapticFeedback.light()
            #endif
            onTap()
        }) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(intention.scope.rawValue.uppercased())
                        .font(.system(size: 11, weight: .semibold, design: .default))
                        .foregroundColor(AppThemeManager.shared.secondaryTextColor(for: colorScheme))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(nil)
                    Spacer()
                    Text(intention.category)
                        .font(.system(size: 11, weight: .medium, design: .default))
                        .foregroundColor(AppThemeManager.shared.secondaryTextColor(for: colorScheme))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(nil)
                }

                Text(intention.text)
                    .font(.system(size: 17, weight: .light, design: .default))
                    .foregroundColor(AppThemeManager.shared.primaryTextColor(for: colorScheme))
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .lineSpacing(2)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        colorScheme == .dark
                            ? AppThemeManager.shared.secondaryButtonBackground(for: colorScheme).opacity(0.4)
                            : Color.white.opacity(0.6)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(
                        AppThemeManager.shared.secondaryTextColor(for: colorScheme).opacity(0.1),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: AppThemeManager.shared.primaryTextColor(for: colorScheme).opacity(0.05),
                radius: 6,
                x: 0,
                y: 2
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 12) {
        ExampleIntentionCard(intention: ExampleIntention.examples[0]) {
            print("Tapped")
        }
        ExampleIntentionCard(intention: ExampleIntention.examples[5]) {
            print("Tapped")
        }
    }
    .padding()
    .background(AppBackground())
}
