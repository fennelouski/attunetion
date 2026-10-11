//
//  WatchOSHelpers.swift
//  Attunetion
//
//  Created for watchOS-specific UI helpers
//

import SwiftUI
#if os(watchOS)
import WatchKit

/// watchOS-specific spacing constants optimized for small screens
struct WatchOSSpacing {
    static let small: CGFloat = 4
    static let medium: CGFloat = 8
    static let large: CGFloat = 12
    static let extraLarge: CGFloat = 16
    
    // Minimum touch target for watchOS (44pt per HIG)
    static let minimumTouchTarget: CGFloat = 44
}

/// watchOS-specific font sizes
struct WatchOSFonts {
    static let title: Font = .system(size: 20, weight: .semibold, design: .rounded)
    static let headline: Font = .system(size: 17, weight: .semibold, design: .rounded)
    static let body: Font = .system(size: 15, weight: .regular, design: .rounded)
    static let caption: Font = .system(size: 12, weight: .regular, design: .rounded)
}

#endif
