//
//  IntentionWidgetEntry.swift
//  IntentionWidget
//
//  Created by Nathan Fennel on 12/2/25.
//

import Foundation
import WidgetKit

/// Timeline entry model for the widget
struct IntentionWidgetEntry: TimelineEntry {
    let date: Date
    let intention: IntentionData?
    let theme: ThemeData?
    
    /// Mock data for development/testing
    static func mock() -> IntentionWidgetEntry {
        IntentionWidgetEntry(
            date: Date(),
            intention: IntentionData.mock(),
            theme: ThemeData.mock()
        )
    }
    
    /// Mock week intention entry
    static func mockWeek() -> IntentionWidgetEntry {
        IntentionWidgetEntry(
            date: Date(),
            intention: IntentionData.mockWeek(),
            theme: ThemeData.mock()
        )
    }
    
    /// Mock month intention entry
    static func mockMonth() -> IntentionWidgetEntry {
        IntentionWidgetEntry(
            date: Date(),
            intention: IntentionData.mockMonth(),
            theme: ThemeData.mock()
        )
    }
    
    /// Empty state entry
    static func empty() -> IntentionWidgetEntry {
        IntentionWidgetEntry(
            date: Date(),
            intention: nil,
            theme: nil
        )
    }
}

/// Simplified intention data for widget display
struct IntentionData: Codable {
    let id: UUID
    let text: String
    let scope: String // "day", "week", "month"
    let scopeDate: Date
    let quote: String?
    let aiGenerated: Bool
    
    /// Mock data for development
    static func mock() -> IntentionData {
        IntentionData(
            id: UUID(),
            text: "Be present with family and focus on meaningful connections",
            scope: "day",
            scopeDate: Date(),
            quote: "The greatest wealth is health.",
            aiGenerated: false
        )
    }
    
    static func mockWeek() -> IntentionData {
        IntentionData(
            id: UUID(),
            text: "Focus on health and meaningful movement",
            scope: "week",
            scopeDate: Date(),
            quote: "The greatest wealth is health.",
            aiGenerated: false
        )
    }
    
    static func mockMonth() -> IntentionData {
        IntentionData(
            id: UUID(),
            text: "Cultivate gratitude and practice mindfulness daily",
            scope: "month",
            scopeDate: Date(),
            quote: "Gratitude turns what we have into enough.",
            aiGenerated: true
        )
    }
}

/// Simplified theme data for widget display
struct ThemeData: Codable {
    let backgroundColor: String // Hex color
    let textColor: String // Hex color
    let accentColor: String? // Hex color
    let fontName: String?
    
    /// Mock theme for development
    static func mock() -> ThemeData {
        ThemeData(
            backgroundColor: "#1E3A8A",
            textColor: "#FFFFFF",
            accentColor: "#60A5FA",
            fontName: nil
        )
    }
}

