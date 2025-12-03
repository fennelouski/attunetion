//
//  IOSHelpers.swift
//  Attunetion
//
//  Created for iOS-specific UI helpers
//

import SwiftUI
#if os(iOS)
import UIKit

/// iOS-specific spacing constants optimized for touch targets
struct IOSSpacing {
    static let small: CGFloat = 8
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
    static let extraLarge: CGFloat = 32
    
    // Touch target minimum size (44pt per HIG)
    static let minimumTouchTarget: CGFloat = 44
}
#endif

/// Haptic feedback helper - available on all platforms, but only works on iOS
struct HapticFeedback {
    static func light() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
    }
    
    static func medium() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        #endif
    }
    
    static func heavy() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        #endif
    }
    
    static func success() {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }
    
    static func error() {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        #endif
    }
}

/// Platform-specific padding helper
struct PlatformPadding {
    static func horizontal() -> CGFloat {
        #if os(iOS)
        return 20
        #elseif os(macOS)
        return 24
        #else
        return 16
        #endif
    }
    
    static func vertical() -> CGFloat {
        #if os(iOS)
        return 16
        #elseif os(macOS)
        return 20
        #else
        return 12
        #endif
    }
    
    static func safeAreaTop() -> CGFloat {
        #if os(iOS)
        return 8
        #else
        return 0
        #endif
    }
}

