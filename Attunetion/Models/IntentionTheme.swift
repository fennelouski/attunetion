//
//  IntentionTheme.swift
//  Attunetion
//
//  Created by Nathan Fennel on 12/2/25.
//

import Foundation
import SwiftData
import SwiftUI

/// Model representing a visual theme for intentions
@Model
final class IntentionTheme {
    var id: UUID
    var name: String
    var backgroundColor: String // Hex color string
    var textColor: String // Hex color string
    var accentColor: String? // Hex color string, optional
    var fontName: String?
    var isPreset: Bool
    var isAIGenerated: Bool
    var createdAt: Date
    var themeDescription: String?
    
    // Optional Unsplash (or proxy) background image
    var backgroundImageURL: String?
    var unsplashPhotoId: String?
    var unsplashDownloadLocation: String?
    var attributionText: String?
    var attributionURL: String?
    
    init(
        id: UUID = UUID(),
        name: String,
        backgroundColor: String,
        textColor: String,
        accentColor: String? = nil,
        fontName: String? = nil,
        isPreset: Bool = false,
        isAIGenerated: Bool = false,
        createdAt: Date = Date(),
        themeDescription: String? = nil,
        backgroundImageURL: String? = nil,
        unsplashPhotoId: String? = nil,
        unsplashDownloadLocation: String? = nil,
        attributionText: String? = nil,
        attributionURL: String? = nil
    ) {
        self.id = id
        self.name = name
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.accentColor = accentColor
        self.fontName = fontName
        self.isPreset = isPreset
        self.isAIGenerated = isAIGenerated
        self.createdAt = createdAt
        self.themeDescription = themeDescription
        self.backgroundImageURL = backgroundImageURL
        self.unsplashPhotoId = unsplashPhotoId
        self.unsplashDownloadLocation = unsplashDownloadLocation
        self.attributionText = attributionText
        self.attributionURL = attributionURL
    }
}

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
