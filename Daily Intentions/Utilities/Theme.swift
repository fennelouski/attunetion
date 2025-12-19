//
//  Theme.swift
//  Daily Intentions
//
//  Central theme definition for consistent colors throughout the app
//

import SwiftUI

/// App-wide theme colors for the Daily Intentions app
/// Uses sage green color palette for a calming, spa-like experience
struct Theme {
    // MARK: - Primary Colors (Sage Green Palette)

    /// Primary sage green accent - main brand color
    static let primary = IntentionTheme.color(from: "#68B0AB")

    /// Deep sage green - for buttons and strong accents
    static let primaryDark = IntentionTheme.color(from: "#5A8F8A")

    /// Light sage green - for backgrounds and subtle accents
    static let primaryLight = IntentionTheme.color(from: "#F7FAF7")

    // MARK: - Text Colors

    /// Primary text color - dark sage for headings and important text
    static let textPrimary = IntentionTheme.color(from: "#2D3748")

    /// Secondary text color - muted sage for descriptions and secondary info
    static let textSecondary = IntentionTheme.color(from: "#4A5568")

    // MARK: - Button Colors

    /// Button background color
    static let buttonBackground = primaryDark

    /// Button text color (on dark button background)
    static let buttonText = primaryLight

    /// Secondary button background color
    static let buttonSecondaryBackground = IntentionTheme.color(from: "#E8F4F1")

    /// Secondary button text color
    static let buttonSecondaryText = IntentionTheme.color(from: "#2D5F5F")

    // MARK: - Background Colors

    /// Light background tint
    static let backgroundLight = primaryLight

    /// Gradient colors for backgrounds
    static let backgroundGradient = [
        IntentionTheme.color(from: "#F7FAF7").opacity(0.8), // Light sage
        IntentionTheme.color(from: "#68B0AB").opacity(0.1), // Sage accent
        IntentionTheme.color(from: "#E8F4F1").opacity(0.6)  // Light sage
    ]

    // MARK: - Glow Effects

    /// Glow color for sparkles and highlights
    static let glow = IntentionTheme.color(from: "#68B0AB").opacity(0.2)
}