//
//  IntentionTheme.swift
//  Attunetion
//
//  Created by Nathan Fennel on 12/2/25.
//

import Foundation
import SwiftData
import SwiftUI

/// Model representing a visual theme for intentions (versioned schema V1)
typealias IntentionTheme = AttunetionSchemaV1.IntentionTheme

// MARK: - SwiftUI Color Conversion

extension IntentionTheme {
    /// Convert hex string to SwiftUI Color
    static func color(from hex: String) -> Color {
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
            return Color.gray
        }
        return Color(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    /// Get SwiftUI Color for background
    var backgroundColorValue: Color {
        Self.color(from: backgroundColor)
    }
    
    /// Get SwiftUI Color for text
    var textColorValue: Color {
        Self.color(from: textColor)
    }
    
    /// Get SwiftUI Color for accent (or background if not set)
    var accentColorValue: Color {
        if let accentColor = accentColor {
            return Self.color(from: accentColor)
        }
        return backgroundColorValue
    }
    
    /// Whether this theme uses a background image (e.g. Unsplash)
    var hasBackgroundImage: Bool {
        (backgroundImageURL ?? "").isEmpty == false
    }
}
