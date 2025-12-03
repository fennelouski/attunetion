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

/// Platform-specific padding helper (includes watchOS)
struct PlatformPadding {
    static func horizontal() -> CGFloat {
        #if os(watchOS)
        return 8
        #elseif os(iOS)
        return 20
        #elseif os(macOS)
        return 24
        #else
        return 16
        #endif
    }
    
    static func vertical() -> CGFloat {
        #if os(watchOS)
        return 8
        #elseif os(iOS)
        return 16
        #elseif os(macOS)
        return 20
        #else
        return 12
        #endif
    }
    
    static func safeAreaTop() -> CGFloat {
        #if os(watchOS)
        return 4
        #elseif os(iOS)
        return 8
        #else
        return 0
        #endif
    }
}

/// watchOS-specific font sizes
struct WatchOSFonts {
    static let title: Font = .system(size: 20, weight: .semibold, design: .rounded)
    static let headline: Font = .system(size: 17, weight: .semibold, design: .rounded)
    static let body: Font = .system(size: 15, weight: .regular, design: .rounded)
    static let caption: Font = .system(size: 12, weight: .regular, design: .rounded)
}

#endif



