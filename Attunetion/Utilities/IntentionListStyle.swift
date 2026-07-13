//
//  IntentionListStyle.swift
//  Attunetion
//
//  Created for the primary intentions list display style setting.
//

import SwiftUI

/// Display style for rows in the primary intentions list.
enum IntentionListStyle: String, CaseIterable, Identifiable {
    /// Each intention rendered as its own bordered, rounded-corner cell (original design).
    case cards
    /// Intentions rendered as a single feed with thin separator lines between rows (Twitter-style).
    case separators

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .cards:
            return String(localized: "Cards")
        case .separators:
            return String(localized: "Separators")
        }
    }

    var description: String {
        switch self {
        case .cards:
            return String(localized: "Each intention in its own bordered, rounded card")
        case .separators:
            return String(localized: "A single feed with thin lines between intentions")
        }
    }
}
