//
//  IntentionPackCard.swift
//  Daily Intentions
//
//  Created by Nathan Fennel on 12/21/25.
//

import SwiftUI

struct IntentionPackCard: View {
    let pack: IntentionPack
    let isSelected: Bool
    let colorScheme: ColorScheme
    let onSelect: () -> Void
    let onPreview: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Button(action: onSelect) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(pack.name)
                            .font(.system(size: 16, weight: .semibold, design: .default))
                            .foregroundColor(AppThemeManager.shared.primaryTextColor(for: colorScheme))

                        Spacer()

                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppThemeManager.shared.accentColor(for: colorScheme))
                        } else {
                            Image(systemName: "circle")
                                .foregroundColor(AppThemeManager.shared.secondaryTextColor(for: colorScheme))
                        }
                    }

                    Text(pack.description)
                        .font(.system(size: 14, weight: .regular, design: .default))
                        .foregroundColor(AppThemeManager.shared.secondaryTextColor(for: colorScheme))
                        .lineSpacing(2)
                }
                .padding(.vertical, 16)
                .padding(.leading, 16)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Divider()
                .frame(width: 1)
                .background(AppThemeManager.shared.secondaryTextColor(for: colorScheme).opacity(0.2))

            Button(action: onPreview) {
                Image(systemName: "eye")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppThemeManager.shared.accentColor(for: colorScheme))
                    .frame(width: 50, height: 50)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(AppThemeManager.shared.secondaryButtonBackground(for: colorScheme))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(
                            isSelected ? AppThemeManager.shared.accentColor(for: colorScheme) : Color.clear,
                            lineWidth: 2
                        )
                )
        )
    }
}
