//
//  AppThemeManager.swift
//  Daily Intentions
//
//  Created by Nathan Fennel on 12/19/25.
//  Simple theme manager for consistent theming throughout the app
//

import SwiftUI
import SwiftData

/// Simple theme manager for Daily Intentions
@MainActor
class AppThemeManager {
    static let shared = AppThemeManager()

    var currentTheme = AppTheme.sage

    private init() {
        // Private init for singleton
    }

    // MARK: - Color Methods

    func backgroundColor(for colorScheme: ColorScheme) -> Color {
        currentTheme.backgroundColor(colorScheme)
    }

    func primaryTextColor(for colorScheme: ColorScheme) -> Color {
        currentTheme.primaryTextColor(colorScheme)
    }

    func secondaryTextColor(for colorScheme: ColorScheme) -> Color {
        currentTheme.secondaryTextColor(colorScheme)
    }

    func accentColor(for colorScheme: ColorScheme) -> Color {
        currentTheme.accentColor(colorScheme)
    }

    func buttonTextColor(for colorScheme: ColorScheme) -> Color {
        currentTheme.buttonTextColor(colorScheme)
    }

    func secondaryButtonBackground(for colorScheme: ColorScheme) -> Color {
        currentTheme.secondaryButtonBackground(colorScheme)
    }
}

/// App theme definition for Daily Intentions
struct AppTheme {
    let backgroundColor: (ColorScheme) -> Color
    let primaryTextColor: (ColorScheme) -> Color
    let secondaryTextColor: (ColorScheme) -> Color
    let accentColor: (ColorScheme) -> Color
    let buttonTextColor: (ColorScheme) -> Color
    let secondaryButtonBackground: (ColorScheme) -> Color

    // MARK: - Available Themes

    static let sage = AppTheme(
        backgroundColor: { colorScheme in
            colorScheme == .dark ? Color(hex: "#1A202C") : Color(hex: "#F7FAF7")
        },
        primaryTextColor: { colorScheme in
            colorScheme == .dark ? Color(hex: "#F7FAF7") : Color(hex: "#2D3748")
        },
        secondaryTextColor: { colorScheme in
            colorScheme == .dark ? Color(hex: "#A0AEC0") : Color(hex: "#4A5568")
        },
        accentColor: { colorScheme in
            Color(hex: "#68B0AB") // Sage green
        },
        buttonTextColor: { colorScheme in
            Color(hex: "#F7FAF7") // Light sage for button text
        },
        secondaryButtonBackground: { colorScheme in
            colorScheme == .dark ? Color(hex: "#2D3748").opacity(0.6) : Color(hex: "#E8F4F1")
        }
    )
}

// MARK: - Color Extension for Hex Support

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
