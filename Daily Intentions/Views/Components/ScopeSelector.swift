//
//  ScopeSelector.swift
//  Daily Intentions
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI

struct ScopeSelector: View {
    @Binding var selectedScope: IntentionScope?
    
    var body: some View {
        HStack(spacing: 8) {
            // "All" button
            Button(action: {
                selectedScope = nil
            }) {
                Text("All")
                    .font(.subheadline)
                    .fontWeight(selectedScope == nil ? .semibold : .regular)
                    .foregroundColor(selectedScope == nil ? .white : .primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(selectedScope == nil ? Color.accentColor : Color(.systemGray5))
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
            
            // Scope buttons
            ForEach(IntentionScope.allCases, id: \.self) { scope in
                Button(action: {
                    selectedScope = selectedScope == scope ? nil : scope
                }) {
                    Text(scope.rawValue.capitalized)
                        .font(.subheadline)
                        .fontWeight(selectedScope == scope ? .semibold : .regular)
                        .foregroundColor(selectedScope == scope ? .white : .primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(selectedScope == scope ? Color.accentColor : Color(.systemGray5))
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    @Previewable @State var selected: IntentionScope? = .day
    return ScopeSelector(selectedScope: $selected)
        .padding()
}

