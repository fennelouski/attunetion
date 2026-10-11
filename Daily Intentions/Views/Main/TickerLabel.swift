//
//  TickerLabel.swift
//  Daily Intentions
//
//  Created by Nathan Fennel on 12/21/25.
//

import SwiftUI

// MARK: - Ticker Label


struct TickerLabel: View {
    let text: String
    let blurRadius: CGFloat
    let colorScheme: ColorScheme
    let direction: TickerDirection

    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 0.4
    @State private var fontSize: CGFloat = 150 // Random size will be set on appear

    var body: some View {
        GeometryReader { geometry in
            Text(text)
                .font(.system(size: fontSize, weight: .light, design: .default))
                .foregroundColor(AppThemeManager.shared.primaryTextColor(for: colorScheme))
                .fixedSize(horizontal: true, vertical: false) // Prevent truncation
                .offset(x: offset)
                .opacity(opacity)
                .onAppear {
                    // Random font size between 100-200
                    fontSize = CGFloat.random(in: 100...200)

                    let screenWidth = geometry.size.width
                    let textWidth = estimateTextWidth(text, fontSize: fontSize)

                    // Start from the edge based on direction
                    switch direction {
                    case .leftToRight:
                        // Start off-screen to the left
                        offset = -textWidth
                    case .rightToLeft:
                        // Start off-screen to the right
                        offset = screenWidth
                    }

                    // Random duration for scrolling (3x slower)
                    let scrollDuration = Double.random(in: 21...39)

                    // Initial opacity
                    let initialOpacity = Double.random(in: 0.3...0.6)
                    opacity = initialOpacity

                    // Animate scrolling based on direction
                    switch direction {
                    case .leftToRight:
                        // Animate from left to right (off-screen right)
                        withAnimation(
                            Animation.linear(duration: scrollDuration)
                                .repeatForever(autoreverses: false)
                        ) {
                            offset = screenWidth + textWidth
                        }
                    case .rightToLeft:
                        // Animate from right to left (off-screen left)
                        withAnimation(
                            Animation.linear(duration: scrollDuration)
                                .repeatForever(autoreverses: false)
                        ) {
                            offset = -textWidth - screenWidth
                        }
                    }

                    // Fade in and out with different random duration (3x slower)
                    let fadeDuration = Double.random(in: 21...39)
                    withAnimation(
                        Animation.easeInOut(duration: fadeDuration)
                            .repeatForever(autoreverses: true)
                    ) {
                        opacity = Double.random(in: 0.3...0.7)
                    }
                }
        }
        .clipped(antialiased: false) // Don't clip so text can animate from edges
        .blur(radius: blurRadius)
    }

    private func estimateTextWidth(_ text: String, fontSize: CGFloat) -> CGFloat {
        // Rough estimate: approximately 0.6 * fontSize per character for light font
        return CGFloat(text.count) * fontSize * 0.6
    }
}
