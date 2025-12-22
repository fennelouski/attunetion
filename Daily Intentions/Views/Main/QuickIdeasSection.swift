//
//  QuickIdeasSection.swift
//  Daily Intentions
//
//  Created by Nathan Fennel on 12/21/25.
//

import SwiftUI

struct QuickIdeasSection: View {
    let colorScheme: ColorScheme
    let scope: IntentionScope
    @Binding var pageIndex: Int
    @Binding var pages: [[String]]
    let onSelect: (String) -> Void

    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false

    private var currentPage: [String] {
        guard pageIndex >= 0 && pageIndex < pages.count else {
            return []
        }
        return pages[pageIndex]
    }

    var body: some View {
        VStack(spacing: 12) {
            #if os(macOS)
            // Centered layout for macOS
            HStack {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        navigateToPrevious()
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppThemeManager.shared.accentColor(for: colorScheme))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)

                Spacer()

                Text("Quick ideas")
                    .font(.system(size: 13, weight: .medium, design: .default))
                    .foregroundColor(AppThemeManager.shared.secondaryTextColor(for: colorScheme))

                Spacer()

                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        navigateToNext()
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppThemeManager.shared.accentColor(for: colorScheme))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
            }
            #else
            // Original layout for iOS
            HStack {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        navigateToPrevious()
                    }
                    HapticFeedback.light()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppThemeManager.shared.accentColor(for: colorScheme))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)

                Text("Quick ideas:")
                    .font(.system(size: 13, weight: .medium, design: .default))
                    .foregroundColor(AppThemeManager.shared.secondaryTextColor(for: colorScheme))

                Spacer()

                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        navigateToNext()
                    }
                    HapticFeedback.light()
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppThemeManager.shared.accentColor(for: colorScheme))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
            }
            #endif

            // Content with swipe gesture and animation
            VStack(spacing: 12) {
                ForEach(currentPage, id: \.self) { suggestion in
                    Button(action: {
                        onSelect(suggestion)
                        #if os(iOS)
                        HapticFeedback.light()
                        #endif
                    }) {
                        Text(suggestion)
                            .font(.system(size: 13, weight: .regular, design: .default))
                            .foregroundColor(AppThemeManager.shared.accentColor(for: colorScheme))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(AppThemeManager.shared.secondaryButtonBackground(for: colorScheme))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .offset(x: dragOffset)
            .id(pageIndex) // Force view update on page change for animation
            .gesture(
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
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    navigateToPrevious()
                                }
                                #if os(iOS)
                                HapticFeedback.light()
                                #endif
                            } else {
                                // Swipe left - go to next
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    navigateToNext()
                                }
                                #if os(iOS)
                                HapticFeedback.light()
                                #endif
                            }
                        }

                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            dragOffset = 0
                        }
                    }
            )
        }
    }

    private func navigateToNext() {
        let nextIndex = pageIndex + 1

        if nextIndex >= pages.count {
            // Wrap around to beginning
            pageIndex = 0
        } else {
            pageIndex = nextIndex
        }
    }

    private func navigateToPrevious() {
        let prevIndex = pageIndex - 1

        if prevIndex < 0 {
            // Wrap around to end
            pageIndex = pages.count - 1
        } else {
            pageIndex = prevIndex
        }
    }
}
