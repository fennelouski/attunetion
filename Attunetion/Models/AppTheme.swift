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
    /// Convert to SwiftUI Color
    @ViewBuilder
    func toColor(colorScheme: ColorScheme) -> some View {
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
        name: "Serenity",
        isPreset: true,
        // Light mode - soft, calming, spa-like
        lightBackground: ThemeColor(hex: "#FAF9F6"),
        lightPrimaryText: ThemeColor(hex: "#1A1A1A"),
        lightSecondaryText: ThemeColor(hex: "#6B7280"),
        lightAccent: ThemeColor(hex: "#7C9A9B"),
        lightButtonBackground: ThemeColor(hex: "#5B7A7B"),
        lightButtonText: ThemeColor(hex: "#FFFFFF"),
        lightSecondaryButtonBackground: ThemeColor(hex: "#E8E8E8"),
        lightSecondaryButtonText: ThemeColor(hex: "#4B5563"),
        // Dark mode - deep, peaceful, elegant
        darkBackground: ThemeColor(hex: "#0F1419"),
        darkPrimaryText: ThemeColor(hex: "#F5F5F5"),
        darkSecondaryText: ThemeColor(hex: "#9CA3AF"),
        darkAccent: ThemeColor(hex: "#7C9A9B"),
        darkButtonBackground: ThemeColor(hex: "#5B7A7B"),
        darkButtonText: ThemeColor(hex: "#FFFFFF"),
        darkSecondaryButtonBackground: ThemeColor(hex: "#1F2937"),
        darkSecondaryButtonText: ThemeColor(hex: "#D1D5DB")
    )
    
    /// Warm sunset theme
    static let sunset = AppTheme(
        id: UUID(uuidString: "FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFE")!,
        name: "Sunset",
        isPreset: true,
        lightBackground: ThemeColor(hex: "#FFF8F0"),
        lightPrimaryText: ThemeColor(hex: "#2D1810"),
        lightSecondaryText: ThemeColor(hex: "#8B6F47"),
        lightAccent: ThemeColor(hex: "#D4A574"),
        lightButtonBackground: ThemeColor(hex: "#C97D60"),
        lightButtonText: ThemeColor(hex: "#FFFFFF"),
        lightSecondaryButtonBackground: ThemeColor(hex: "#F5E6D3"),
        lightSecondaryButtonText: ThemeColor(hex: "#8B6F47"),
        darkBackground: ThemeColor(hex: "#1A0F0A"),
        darkPrimaryText: ThemeColor(hex: "#F5E6D3"),
        darkSecondaryText: ThemeColor(hex: "#C97D60"),
        darkAccent: ThemeColor(hex: "#D4A574"),
        darkButtonBackground: ThemeColor(hex: "#C97D60"),
        darkButtonText: ThemeColor(hex: "#FFFFFF"),
        darkSecondaryButtonBackground: ThemeColor(hex: "#2D1810"),
        darkSecondaryButtonText: ThemeColor(hex: "#D4A574")
    )
    
    /// Ocean breeze theme
    static let ocean = AppTheme(
        id: UUID(uuidString: "FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFD")!,
        name: "Ocean",
        isPreset: true,
        lightBackground: ThemeColor(hex: "#F0F7FA"),
        lightPrimaryText: ThemeColor(hex: "#0A2540"),
        lightSecondaryText: ThemeColor(hex: "#4A6FA5"),
        lightAccent: ThemeColor(hex: "#5B9BD5"),
        lightButtonBackground: ThemeColor(hex: "#4A90E2"),
        lightButtonText: ThemeColor(hex: "#FFFFFF"),
        lightSecondaryButtonBackground: ThemeColor(hex: "#E3F2FD"),
        lightSecondaryButtonText: ThemeColor(hex: "#4A90E2"),
        darkBackground: ThemeColor(hex: "#0A1628"),
        darkPrimaryText: ThemeColor(hex: "#E3F2FD"),
        darkSecondaryText: ThemeColor(hex: "#87CEEB"),
        darkAccent: ThemeColor(hex: "#5B9BD5"),
        darkButtonBackground: ThemeColor(hex: "#4A90E2"),
        darkButtonText: ThemeColor(hex: "#FFFFFF"),
        darkSecondaryButtonBackground: ThemeColor(hex: "#1A2F4A"),
        darkSecondaryButtonText: ThemeColor(hex: "#87CEEB")
    )
    
    /// All preset themes
    static var presetThemes: [AppTheme] {
        [defaultTheme, sunset, ocean]
    }
}

