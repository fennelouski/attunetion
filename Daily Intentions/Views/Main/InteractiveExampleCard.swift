//
//  InteractiveExampleCard.swift
//  Daily Intentions
//
//  Created by Nathan Fennel on 12/21/25.
//

import SwiftUI

struct InteractiveExampleCard: View {
    let title: String
    let examples: [String]
    @Binding var currentIndex: Int
    @Binding var lastTapTime: Date?
    let isGood: Bool
    let colorScheme: ColorScheme

    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    @State private var tapTask: Task<Void, Never>?

    private var currentExample: String {
        examples[currentIndex]
    }

    private var iconName: String {
        isGood ? "checkmark.circle" : "xmark.circle"
    }

    private var titleFont: Font {
        isGood
            ? .system(size: 13, weight: .semibold, design: .rounded)
            : .system(size: 13, weight: .medium, design: .default)
    }

    private var textFont: Font {
        isGood
            ? .system(size: 14, weight: .regular, design: .rounded)
            : .system(size: 14, weight: .light, design: .default)
    }

    private var iconColor: Color {
        isGood
            ? AppThemeManager.shared.accentColor(for: colorScheme)
            : AppThemeManager.shared.secondaryTextColor(for: colorScheme).opacity(0.6)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: iconName)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(iconColor)
                Text(title)
                    .font(titleFont)
                    .foregroundColor(AppThemeManager.shared.primaryTextColor(for: colorScheme))
            }

            Text(currentExample)
                .font(textFont)
                .foregroundColor(AppThemeManager.shared.secondaryTextColor(for: colorScheme))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    colorScheme == .dark
                        ? AppThemeManager.shared.secondaryButtonBackground(for: colorScheme).opacity(0.4)
                        : Color.white.opacity(0.6)
                )
        )
        .offset(x: dragOffset)
        .simultaneousGesture(
            DragGesture()
                .onChanged { value in
                    isDragging = true
                    dragOffset = value.translation.width
                }
                .onEnded { value in
                    isDragging = false
                    let threshold: CGFloat = 50

                    if abs(value.translation.width) > threshold {
                        if value.translation.width > 0 {
                            // Swipe right - go to previous
                            navigateToPrevious()
                        } else {
                            // Swipe left - go to next
                            navigateToNext()
                        }
                    }

                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        dragOffset = 0
                    }
                }
        )
        .onTapGesture(count: 2) {
            // Double tap - go to previous
            tapTask?.cancel()
            navigateToPrevious()
            #if os(iOS)
            HapticFeedback.light()
            #endif
        }
        .onTapGesture(count: 1) {
            // Single tap - go to next (with delay to detect double tap)
            tapTask?.cancel()
            tapTask = Task {
                try? await Task.sleep(nanoseconds: 200_000_000) // 200ms delay
                if !Task.isCancelled {
                    await MainActor.run {
                        navigateToNext()
                        #if os(iOS)
                        HapticFeedback.light()
                        #endif
                    }
                }
            }
        }
    }

    private func navigateToNext() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            currentIndex = (currentIndex + 1) % examples.count
        }
    }

    private func navigateToPrevious() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            if currentIndex == 0 {
                currentIndex = examples.count - 1
            } else {
                currentIndex -= 1
            }
        }
    }
}
