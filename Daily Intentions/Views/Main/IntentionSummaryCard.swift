//
//  IntentionSummaryCard.swift
//  Daily Intentions
//
//  Created by Nathan Fennel on 12/21/25.
//

import SwiftUI

struct IntentionSummaryCard: View {
    let scope: IntentionScope
    let text: String
    let colorScheme: ColorScheme

    private var scopeIcon: String {
        switch scope {
        case .month: return "calendar"
        case .week: return "calendar.badge.clock"
        case .day: return "sun.max.fill"
        }
    }

    private var scopeColor: Color {
        switch scope {
        case .month: return .blue
        case .week: return .green
        case .day: return .orange
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(scopeColor.opacity(0.1))
                    .frame(width: 32, height: 32)

                Image(systemName: scopeIcon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(scopeColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(scope.rawValue.capitalized)
                    .font(.system(size: 14, weight: .medium, design: .default))
                    .foregroundColor(AppThemeManager.shared.primaryTextColor(for: colorScheme))

                Text(text)
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .foregroundColor(AppThemeManager.shared.secondaryTextColor(for: colorScheme))
                    .lineSpacing(2)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppThemeManager.shared.secondaryButtonBackground(for: colorScheme))
        )
    }
}
