//
//  PageIndicator.swift
//  Daily Intentions
//
//  Created by Nathan Fennel on 12/19/25.
//

import SwiftUI

struct PageIndicator: View {
    let currentPage: Int
    let pageCount: Int
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<pageCount, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? AppThemeManager.shared.accentColor(for: colorScheme) : AppThemeManager.shared.accentColor(for: colorScheme).opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
    }
}
