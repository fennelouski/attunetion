//
//  MockData.swift
//  Attunetion
//
//  Created by Nathan Fennel on 12/2/25.
//

import Foundation
import SwiftUI

/// Mock intention for UI development (before real data layer is ready)
struct MockIntention: Identifiable, Hashable {
    let id: UUID
    var text: String
    var scope: IntentionScope
    var date: Date
    var createdAt: Date
    var updatedAt: Date
    var themeId: UUID?
    var customFont: String?
    var aiGenerated: Bool
    var aiRephrased: Bool
    var quote: String?
    
    init(
        id: UUID = UUID(),
        text: String,
        scope: IntentionScope,
        date: Date,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        themeId: UUID? = nil,
        customFont: String? = nil,
        aiGenerated: Bool = false,
        aiRephrased: Bool = false,
        quote: String? = nil
    ) {
        self.id = id
        self.text = text
        self.scope = scope
        self.date = date
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.themeId = themeId
        self.customFont = customFont
        self.aiGenerated = aiGenerated
        self.aiRephrased = aiRephrased
        self.quote = quote
    }
}

/// Preset theme for mock data
struct PresetTheme: Identifiable {
    let id: UUID
    let name: String
    let backgroundColor: Color
    let textColor: Color
    let accentColor: Color?
    
    init(id: UUID = UUID(), name: String, backgroundColor: Color, textColor: Color, accentColor: Color? = nil) {
        self.id = id
        self.name = name
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.accentColor = accentColor
    }
}

/// Preset themes collection for mock data
struct MockPresetThemes {
    static let ocean = PresetTheme(
        name: "Ocean",
        backgroundColor: Color(red: 0.1, green: 0.4, blue: 0.6),
        textColor: .white,
        accentColor: Color(red: 0.2, green: 0.7, blue: 0.9)
    )
    
    static let sunset = PresetTheme(
        name: "Sunset",
        backgroundColor: Color(red: 1.0, green: 0.4, blue: 0.3),
        textColor: .white,
        accentColor: Color(red: 1.0, green: 0.6, blue: 0.4)
    )
    
    static let forest = PresetTheme(
        name: "Forest",
        backgroundColor: Color(red: 0.1, green: 0.5, blue: 0.2),
        textColor: .white,
        accentColor: Color(red: 0.3, green: 0.7, blue: 0.4)
    )
    
    static let minimal = PresetTheme(
        name: "Minimal",
        backgroundColor: .white,
        textColor: .black,
        accentColor: .gray
    )
    
    static let midnight = PresetTheme(
        name: "Midnight",
        backgroundColor: Color(red: 0.1, green: 0.1, blue: 0.3),
        textColor: .white,
        accentColor: Color(red: 0.3, green: 0.3, blue: 0.6)
    )
    
    static let all: [PresetTheme] = [ocean, sunset, forest, minimal, midnight]
}

/// Mock data for development
struct MockData {
    static let intentions: [MockIntention] = [
        MockIntention(
            text: "Be present with family",
            scope: .day,
            date: Date(),
            themeId: MockPresetThemes.ocean.id,
            aiGenerated: false
        ),
        MockIntention(
            text: "Focus on health and wellness",
            scope: .week,
            date: Calendar.current.startOfDay(for: Date()),
            themeId: MockPresetThemes.forest.id,
            aiGenerated: true,
            quote: "The greatest wealth is health."
        ),
        MockIntention(
            text: "Practice gratitude daily",
            scope: .day,
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            themeId: MockPresetThemes.sunset.id
        ),
        MockIntention(
            text: "Build meaningful connections",
            scope: .month,
            date: Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date())) ?? Date(),
            themeId: MockPresetThemes.midnight.id,
            aiGenerated: true
        ),
        MockIntention(
            text: "Stay open to learning",
            scope: .week,
            date: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
            themeId: MockPresetThemes.minimal.id
        ),
        MockIntention(
            text: "Reduce stress through mindfulness",
            scope: .day,
            date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            themeId: MockPresetThemes.ocean.id,
            aiGenerated: true,
            quote: "Peace comes from within. Do not seek it without."
        )
    ]
    
    static func getTheme(byId id: UUID) -> PresetTheme? {
        MockPresetThemes.all.first { $0.id == id }
    }
}

