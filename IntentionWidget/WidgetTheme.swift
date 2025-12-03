//
//  WidgetTheme.swift
//  IntentionWidget
//
//  Created by Nathan Fennel on 12/2/25.
//

import Foundation
import SwiftUI

/// Preset themes optimized for widget display
struct WidgetTheme {
    static let ocean = ThemeData(
        backgroundColor: "#1E3A8A",
        textColor: "#FFFFFF",
        accentColor: "#60A5FA",
        fontName: nil
    )
    
    static let sunset = ThemeData(
        backgroundColor: "#FCD34D",
        textColor: "#78350F",
        accentColor: "#FB923C",
        fontName: nil
    )
    
    static let forest = ThemeData(
        backgroundColor: "#166534",
        textColor: "#FFFFFF",
        accentColor: "#86EFAC",
        fontName: nil
    )
    
    static let minimal = ThemeData(
        backgroundColor: "#FFFFFF",
        textColor: "#000000",
        accentColor: "#808080",
        fontName: nil
    )
    
    static let midnight = ThemeData(
        backgroundColor: "#0F172A",
        textColor: "#FFFFFF",
        accentColor: "#818CF8",
        fontName: nil
    )
    
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
    
    /// Create a beautiful gradient from theme colors
    /// Inspired by serene, natural backgrounds with smooth color transitions
    static func gradient(for theme: ThemeData?) -> LinearGradient {
        if let theme = theme {
            let baseColor = color(from: theme.backgroundColor)
            let accentColor = theme.accentColor.map { color(from: $0) } ?? baseColor
            
            // Create a gradient that transitions from lighter accent to darker base
            // This creates depth and visual interest
            return LinearGradient(
                gradient: Gradient(colors: [
                    accentColor.opacity(0.6),
                    baseColor,
                    baseColor.opacity(0.9)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            // Default beautiful gradient (purple/pink to dark blue)
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.7, green: 0.5, blue: 0.9), // Soft purple
                    Color(red: 0.9, green: 0.6, blue: 0.8), // Pink
                    Color(red: 0.2, green: 0.2, blue: 0.4)  // Dark blue
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
    
    /// Create a subtle overlay gradient for depth
    static func overlayGradient() -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.black.opacity(0.0),
                Color.black.opacity(0.1)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}



