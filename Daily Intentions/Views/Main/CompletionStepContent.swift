//
//  CompletionStepContent.swift
//  Daily Intentions
//
//  Created by Nathan Fennel on 12/21/25.
//

import SwiftUI

struct CompletionStepContent: View {
    let monthlyIntention: String
    let weeklyIntention: String
    let dailyIntention: String
    @Binding var selectedPack: IntentionPack?
    @Binding var showingAIGenerator: Bool
    @Binding var showingPackPreview: IntentionPack?
    let colorScheme: ColorScheme

    private var hasIntentions: Bool {
        !monthlyIntention.isEmpty || !weeklyIntention.isEmpty || !dailyIntention.isEmpty
    }

    var body: some View {
        VStack(spacing: 24) {
            if hasIntentions {
                // Show created intentions
                VStack(spacing: 20) {
                    Text(String(localized: "You're All Set!"))
                        .font(.system(size: 28, weight: .light, design: .default))
                        .foregroundColor(AppThemeManager.shared.primaryTextColor(for: colorScheme))

                    Text(String(localized: "You've created your first intentions! They'll appear on your home screen and help keep you focused. You can always add more or edit existing ones."))
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .foregroundColor(AppThemeManager.shared.secondaryTextColor(for: colorScheme))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)

                    VStack(spacing: 16) {
                        if !monthlyIntention.isEmpty {
                            IntentionSummaryCard(
                                scope: .month,
                                text: monthlyIntention,
                                colorScheme: colorScheme
                            )
                        }

                        if !weeklyIntention.isEmpty {
                            IntentionSummaryCard(
                                scope: .week,
                                text: weeklyIntention,
                                colorScheme: colorScheme
                            )
                        }

                        if !dailyIntention.isEmpty {
                            IntentionSummaryCard(
                                scope: .day,
                                text: dailyIntention,
                                colorScheme: colorScheme
                            )
                        }
                    }
                }
            } else {
                // Show options for creating intentions
                VStack(spacing: 24) {
                    Image(systemName: "target")
                        .font(.system(size: 64, weight: .ultraLight))
                        .foregroundColor(AppThemeManager.shared.accentColor(for: colorScheme))
                        .symbolEffect(.variableColor.iterative, options: .repeating.speed(0.5))
                        .symbolEffect(.pulse, options: .repeating.speed(0.5))

                    Text(String(localized: "Need Some Ideas?"))
                        .font(.system(size: 28, weight: .light, design: .default))
                        .foregroundColor(AppThemeManager.shared.primaryTextColor(for: colorScheme))

                    Text(String(localized: "If you're not sure where to start, here are some ready-to-use intention packs. You can preview them to see what they include."))
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .foregroundColor(AppThemeManager.shared.secondaryTextColor(for: colorScheme))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)

                    // Intention packs
                    VStack(spacing: 12) {
                        ForEach(IntentionPack.packs, id: \.name) { pack in
                            IntentionPackCard(
                                pack: pack,
                                isSelected: selectedPack?.name == pack.name,
                                colorScheme: colorScheme,
                                onSelect: {
                                    selectedPack = pack
                                    #if os(iOS)
                                    HapticFeedback.light()
                                    #endif
                                },
                                onPreview: {
                                    showingPackPreview = pack
                                    #if os(iOS)
                                    HapticFeedback.light()
                                    #endif
                                }
                            )
                        }
                    }

                    // AI option - simplified for Daily Intentions
                    Button(action: {
                        showingAIGenerator = true
                        #if os(iOS)
                        HapticFeedback.medium()
                        #endif
                    }) {
                        HStack {
                            Image(systemName: "target")
                                .font(.system(size: 16, weight: .medium))
                                .symbolEffect(.variableColor.iterative, options: .repeating.speed(0.5))
                                .symbolEffect(.pulse, options: .repeating.speed(0.5))
                            Text(String(localized: "Or tell us about yourself and we'll create custom intentions"))
                                .font(.system(size: 15, weight: .medium, design: .default))
                        }
                        .foregroundColor(AppThemeManager.shared.accentColor(for: colorScheme))
                        .padding(.vertical, 14)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(AppThemeManager.shared.accentColor(for: colorScheme).opacity(0.1))
                        )
                    }
                }
            }
        }
    }
}
