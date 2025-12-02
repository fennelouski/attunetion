//
//  ExampleIntentionCard.swift
//  Daily Intentions
//
//  Created for onboarding experience
//

import SwiftUI

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
        ExampleIntention(text: "Read for 30 minutes", scope: .day, category: "Learning"),
        ExampleIntention(text: "Be present with loved ones", scope: .day, category: "Relationships"),
        
        // Health & Wellness
        ExampleIntention(text: "Move my body joyfully", scope: .day, category: "Health"),
        ExampleIntention(text: "Choose nourishing foods", scope: .week, category: "Health"),
        ExampleIntention(text: "Prioritize rest and recovery", scope: .week, category: "Wellness"),
        
        // Productivity
        ExampleIntention(text: "Focus on deep work", scope: .day, category: "Productivity"),
        ExampleIntention(text: "Complete one important task", scope: .day, category: "Productivity"),
        ExampleIntention(text: "Launch my project", scope: .month, category: "Goals"),
        
        // Mindfulness
        ExampleIntention(text: "Start the day with meditation", scope: .day, category: "Mindfulness"),
        ExampleIntention(text: "Practice mindful breathing", scope: .week, category: "Mindfulness"),
        ExampleIntention(text: "Cultivate inner peace", scope: .month, category: "Mindfulness"),
        
        // Creativity
        ExampleIntention(text: "Create something new", scope: .day, category: "Creativity"),
        ExampleIntention(text: "Explore a creative hobby", scope: .week, category: "Creativity"),
        ExampleIntention(text: "Finish my creative project", scope: .month, category: "Creativity"),
        
        // Additional examples
        ExampleIntention(text: "Express kindness to someone", scope: .day, category: "Relationships"),
        ExampleIntention(text: "Learn something new", scope: .week, category: "Learning"),
        ExampleIntention(text: "Build meaningful connections", scope: .month, category: "Relationships"),
        ExampleIntention(text: "Take time for self-care", scope: .day, category: "Wellness"),
        ExampleIntention(text: "Reflect on my progress", scope: .week, category: "Growth"),
    ]
}

/// Card view for displaying example intentions
struct ExampleIntentionCard: View {
    let intention: ExampleIntention
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(intention.scope.rawValue.uppercased())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(intention.category)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Text(intention.text)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
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
}

