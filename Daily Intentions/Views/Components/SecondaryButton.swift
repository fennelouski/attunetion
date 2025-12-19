//
//  SecondaryButton.swift
//  Daily Intentions
//
//  Created by Nathan Fennel on 12/19/25.
//

import SwiftUI

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme

    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .default))
                .foregroundColor(AppThemeManager.shared.accentColor(for: colorScheme))
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity)
                .background(AppThemeManager.shared.secondaryButtonBackground(for: colorScheme))
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}
