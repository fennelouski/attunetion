//
//  AppTheme.swift
//  Attunetion
//
//  Created for app-wide theming system
//

import Foundation
import SwiftUI

/// App-wide theme system for UI elements (separate from IntentionTheme)
struct AppTheme: Identifiable, Codable {
    let id: UUID
    let name: String
    let isPreset: Bool
    
    // Light mode colors
    let lightBackground: ThemeColor
    let lightPrimaryText: ThemeColor
    let lightSecondaryText: ThemeColor
    let lightAccent: ThemeColor
    let lightButtonBackground: ThemeColor
    let lightButtonText: ThemeColor
    let lightSecondaryButtonBackground: ThemeColor
    let lightSecondaryButtonText: ThemeColor
    
    // Dark mode colors
    let darkBackground: ThemeColor
    let darkPrimaryText: ThemeColor
    let darkSecondaryText: ThemeColor
    let darkAccent: ThemeColor
    let darkButtonBackground: ThemeColor
    let darkButtonText: ThemeColor
    let darkSecondaryButtonBackground: ThemeColor
    let darkSecondaryButtonText: ThemeColor
    
    init(
        id: UUID = UUID(),
        name: String,
        isPreset: Bool = true,
        lightBackground: ThemeColor,
        lightPrimaryText: ThemeColor,
        lightSecondaryText: ThemeColor,
        lightAccent: ThemeColor,
        lightButtonBackground: ThemeColor,
        lightButtonText: ThemeColor,
        lightSecondaryButtonBackground: ThemeColor,
        lightSecondaryButtonText: ThemeColor,
        darkBackground: ThemeColor,
        darkPrimaryText: ThemeColor,
        darkSecondaryText: ThemeColor,
        darkAccent: ThemeColor,
        darkButtonBackground: ThemeColor,
        darkButtonText: ThemeColor,
        darkSecondaryButtonBackground: ThemeColor,
        darkSecondaryButtonText: ThemeColor
    ) {
        self.id = id
        self.name = name
        self.isPreset = isPreset
        self.lightBackground = lightBackground
        self.lightPrimaryText = lightPrimaryText
        self.lightSecondaryText = lightSecondaryText
        self.lightAccent = lightAccent
        self.lightButtonBackground = lightButtonBackground
        self.lightButtonText = lightButtonText
        self.lightSecondaryButtonBackground = lightSecondaryButtonBackground
        self.lightSecondaryButtonText = lightSecondaryButtonText
        self.darkBackground = darkBackground
        self.darkPrimaryText = darkPrimaryText
        self.darkSecondaryText = darkSecondaryText
        self.darkAccent = darkAccent
        self.darkButtonBackground = darkButtonBackground
        self.darkButtonText = darkButtonText
        self.darkSecondaryButtonBackground = darkSecondaryButtonBackground
        self.darkSecondaryButtonText = darkSecondaryButtonText
    }
}

/// Color representation that supports both solid colors and gradients
struct ThemeColor: Codable {
    enum ColorType: String, Codable {
        case solid
        case gradient
    }
    
    let type: ColorType
    let hex: String? // For solid colors
    let gradientColors: [String]? // For gradients (array of hex colors)
    let gradientStartPoint: GradientPoint?
    let gradientEndPoint: GradientPoint?
    
    init(hex: String) {
        self.type = .solid
        self.hex = hex
        self.gradientColors = nil
        self.gradientStartPoint = nil
        self.gradientEndPoint = nil
    }
    
    init(gradientColors: [String], startPoint: GradientPoint, endPoint: GradientPoint) {
        self.type = .gradient
        self.hex = nil
        self.gradientColors = gradientColors
        self.gradientStartPoint = startPoint
        self.gradientEndPoint = endPoint
    }
}

struct GradientPoint: Codable {
    let x: Double
    let y: Double
}

// MARK: - SwiftUI Color Conversion

extension ThemeColor {
    /// Convert to SwiftUI Color (for solid colors) or return a Color that represents the theme color
    func toColor(colorScheme: ColorScheme) -> Color {
        switch type {
        case .solid:
            if let hex = hex {
                return Color(hex: hex)
            } else {
                return Color.clear
            }
        case .gradient:
            // For gradients, return the first color as a fallback
            // In practice, gradients should be handled differently in views
            if let colors = gradientColors, let firstColor = colors.first {
                return Color(hex: firstColor)
            } else {
                return Color.clear
            }
        }
    }

    /// Convert to SwiftUI View (supports gradients)
    @ViewBuilder
    func toView(colorScheme: ColorScheme) -> some View {
        switch type {
        case .solid:
            if let hex = hex {
                Color(hex: hex)
            } else {
                Color.clear
            }
        case .gradient:
            if let colors = gradientColors {
                LinearGradient(
                    colors: colors.map { Color(hex: $0) },
                    startPoint: UnitPoint(
                        x: gradientStartPoint?.x ?? 0,
                        y: gradientStartPoint?.y ?? 0
                    ),
                    endPoint: UnitPoint(
                        x: gradientEndPoint?.x ?? 1,
                        y: gradientEndPoint?.y ?? 1
                    )
                )
            } else {
                Color.clear
            }
        }
    }
    
    /// Get SwiftUI Color directly (for solid colors)
    func toSwiftUIColor() -> Color {
        guard type == .solid, let hex = hex else {
            return Color.clear
        }
        return Color(hex: hex)
    }
}

extension Color {
    /// Initialize Color from hex string
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
            self = Color.gray
            return
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

// MARK: - Preset App Themes

extension AppTheme {
    /// Default inspirational theme - spa-like, Apple-inspired
    static let defaultTheme = AppTheme(
        id: UUID(uuidString: "FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF")!,
        name: "Sage Serenity",
        isPreset: true,
        // Light mode - soft, calming, spa-like sage green theme
        lightBackground: ThemeColor(hex: "#FAF9F6"), // Soft cream background
        lightPrimaryText: ThemeColor(hex: "#2D3748"), // Deep charcoal text
        lightSecondaryText: ThemeColor(hex: "#718096"), // Muted gray text
        lightAccent: ThemeColor(hex: "#7C9A9B"), // Sage green accent
        lightButtonBackground: ThemeColor(hex: "#5B7A7B"), // Deeper sage button
        lightButtonText: ThemeColor(hex: "#FFFFFF"), // White text
        lightSecondaryButtonBackground: ThemeColor(hex: "#E8E8E8"), // Light gray button
        lightSecondaryButtonText: ThemeColor(hex: "#4B5563"), // Dark gray text
        // Dark mode - deep, peaceful, elegant
        darkBackground: ThemeColor(hex: "#1A1A1A"), // Deep charcoal
        darkPrimaryText: ThemeColor(hex: "#F5F5F5"), // Soft white text
        darkSecondaryText: ThemeColor(hex: "#A0AEC0"), // Light gray text
        darkAccent: ThemeColor(hex: "#7C9A9B"), // Sage green accent
        darkButtonBackground: ThemeColor(hex: "#5B7A7B"), // Deeper sage button
        darkButtonText: ThemeColor(hex: "#FFFFFF"), // White text
        darkSecondaryButtonBackground: ThemeColor(hex: "#2D3748"), // Dark gray button
        darkSecondaryButtonText: ThemeColor(hex: "#D1D5DB") // Light gray text
    )
    
    /// Warm sunset theme
    static let sunset = AppTheme(
        id: UUID(uuidString: "FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFE")!,
        name: "Sunset",
        isPreset: true,
        lightBackground: ThemeColor(hex: "#FEF5E7"), // Warm cream background
        lightPrimaryText: ThemeColor(hex: "#7C2D12"), // Deep orange text
        lightSecondaryText: ThemeColor(hex: "#EA580C"), // Bright orange text
        lightAccent: ThemeColor(hex: "#F97316"), // Vibrant orange accent
        lightButtonBackground: ThemeColor(hex: "#EA580C"), // Orange button
        lightButtonText: ThemeColor(hex: "#FFFFFF"), // White text
        lightSecondaryButtonBackground: ThemeColor(hex: "#FED7AA"), // Light orange button
        lightSecondaryButtonText: ThemeColor(hex: "#9A3412"), // Dark orange text
        darkBackground: ThemeColor(hex: "#451A03"), // Dark brown
        darkPrimaryText: ThemeColor(hex: "#FFEDD5"), // Light cream text
        darkSecondaryText: ThemeColor(hex: "#FDBA74"), // Light orange text
        darkAccent: ThemeColor(hex: "#F97316"), // Vibrant orange accent
        darkButtonBackground: ThemeColor(hex: "#EA580C"), // Orange button
        darkButtonText: ThemeColor(hex: "#FFFFFF"), // White text
        darkSecondaryButtonBackground: ThemeColor(hex: "#7C2D12"), // Dark orange button
        darkSecondaryButtonText: ThemeColor(hex: "#FED7AA") // Light orange text
    )

    /// Spa-like sage green theme - calming and restorative
    static let ocean = AppTheme(
        id: UUID(uuidString: "FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFD")!,
        name: "Sage Spa",
        isPreset: true,
        lightBackground: ThemeColor(hex: "#F7FAF7"), // Soft sage-tinted cream
        lightPrimaryText: ThemeColor(hex: "#2D3748"), // Deep forest text
        lightSecondaryText: ThemeColor(hex: "#4A5568"), // Muted sage text
        lightAccent: ThemeColor(hex: "#68B0AB"), // Calming sage green accent
        lightButtonBackground: ThemeColor(hex: "#5A8F8A"), // Deep sage button
        lightButtonText: ThemeColor(hex: "#FFFFFF"), // White text
        lightSecondaryButtonBackground: ThemeColor(hex: "#E8F4F1"), // Light sage button
        lightSecondaryButtonText: ThemeColor(hex: "#2D5F5F"), // Dark sage text
        darkBackground: ThemeColor(hex: "#1A1F1E"), // Deep forest
        darkPrimaryText: ThemeColor(hex: "#F0F4F0"), // Soft sage white
        darkSecondaryText: ThemeColor(hex: "#A8B5B2"), // Light sage text
        darkAccent: ThemeColor(hex: "#68B0AB"), // Calming sage green accent
        darkButtonBackground: ThemeColor(hex: "#5A8F8A"), // Deep sage button
        darkButtonText: ThemeColor(hex: "#FFFFFF"), // White text
        darkSecondaryButtonBackground: ThemeColor(hex: "#2D5F5F"), // Dark sage button
        darkSecondaryButtonText: ThemeColor(hex: "#C8D9D6") // Light sage text
    )
    
    /// All preset themes
    static var presetThemes: [AppTheme] {
        [ocean, defaultTheme, sunset] // Sage Spa first as the calming default
    }
}

