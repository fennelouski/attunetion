//
//  IntentionRowView.swift
//  Daily Intentions
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI

struct IntentionRowView: View {
    let intention: Intention
    
    private var scopeColor: Color {
        switch intention.scope {
        case .day:
            return .blue
        case .week:
            return .green
        case .month:
            return .purple
        }
    }
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: intention.date)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Scope badge
            Text(intention.scope.rawValue.capitalized)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(scopeColor)
                .cornerRadius(6)
            
            // Intention text
            VStack(alignment: .leading, spacing: 4) {
                Text(intention.text)
                    .font(.body)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                Text(dateString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // AI badge if applicable
            if intention.aiGenerated {
                Image(systemName: "sparkles")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    let container = try! ModelContainer(for: Intention.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let context = container.mainContext
    
    // Create sample intentions for preview
    let intention1 = Intention(text: "Be present with family", scope: .day, date: Date())
    let intention2 = Intention(text: "Focus on health and wellness", scope: .week, date: Date())
    let intention3 = Intention(text: "Build meaningful connections", scope: .month, date: Date())
    
    return List {
        IntentionRowView(intention: intention1)
        IntentionRowView(intention: intention2)
        IntentionRowView(intention: intention3)
    }
    .modelContainer(container)
}

