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

    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .default))
                .foregroundColor(Theme.buttonSecondaryText)
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity)
                .background(Theme.buttonSecondaryBackground)
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}
