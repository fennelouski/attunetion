//
//  AnimationSpeed.swift
//  Attunetion
//
//  Created for centralized animation speed control
//

import SwiftUI

/// Enum representing different animation speeds
enum AnimationSpeed: String, CaseIterable {
    case sprint = "Sprint"
    case rushed = "Rushed"
    case faster = "Faster"
    case fast = "Fast"
    case normal = "Normal"
    case slow = "Slow"
    case slower = "Slower"
    case turtle = "Turtle"
    case areYouOn = "Are you on?"
    
    /// Multiplier for animation durations (higher = slower)
    var durationMultiplier: Double {
        switch self {
        case .sprint:
            return 0.1      // 10x faster
        case .rushed:
            return 0.25     // 4x faster
        case .faster:
            return 0.5      // 2x faster
        case .fast:
            return 0.75     // 1.33x faster (current speed)
        case .normal:
            return 1.0      // Normal speed (default)
        case .slow:
            return 2.0      // 2x slower
        case .slower:
            return 4.0      // 4x slower
        case .turtle:
            return 8.0      // 8x slower
        case .areYouOn:
            return 16.0     // 16x slower
        }
    }
    
    /// Base duration for standard animations (in seconds)
    private var baseDuration: Double {
        return 0.3
    }
    
    /// Get animation duration based on speed
    func duration(for base: Double = 0.3) -> Double {
        return base * durationMultiplier
    }
    
    /// Get spring animation response time
    func springResponse(for base: Double = 0.3) -> Double {
        return base * durationMultiplier
    }
    
    /// Get spring animation damping fraction (adjusted for speed)
    func springDamping(for base: Double = 0.8) -> Double {
        // Slower animations benefit from slightly less damping for smoother feel
        switch self {
        case .sprint, .rushed, .faster, .fast:
            return base
        case .normal:
            return base
        case .slow, .slower, .turtle, .areYouOn:
            return max(0.6, base - 0.1) // Slightly less damping for very slow animations
        }
    }
}

/// Manager for animation speed settings
class AnimationSpeedManager: ObservableObject {
    static let shared = AnimationSpeedManager()
    
    @Published var currentSpeed: AnimationSpeed = .normal
    
    private init() {
        // Default to normal speed
        currentSpeed = .normal
    }
    
    /// Get an easeInOut animation with the current speed
    func easeInOut(duration baseDuration: Double = 0.3) -> Animation {
        return .easeInOut(duration: currentSpeed.duration(for: baseDuration))
    }
    
    /// Get an easeOut animation with the current speed
    func easeOut(duration baseDuration: Double = 0.4) -> Animation {
        return .easeOut(duration: currentSpeed.duration(for: baseDuration))
    }
    
    /// Get an easeIn animation with the current speed
    func easeIn(duration baseDuration: Double = 0.3) -> Animation {
        return .easeIn(duration: currentSpeed.duration(for: baseDuration))
    }
    
    /// Get a spring animation with the current speed
    func spring(response baseResponse: Double = 0.3, dampingFraction baseDamping: Double = 0.8) -> Animation {
        return .spring(
            response: currentSpeed.springResponse(for: baseResponse),
            dampingFraction: currentSpeed.springDamping(for: baseDamping)
        )
    }
    
    /// Get a linear animation with the current speed
    func linear(duration baseDuration: Double = 0.3) -> Animation {
        return .linear(duration: currentSpeed.duration(for: baseDuration))
    }
    
    /// Helper to create a withAnimation block using current speed
    func withAnimation<T>(_ baseDuration: Double = 0.3, _ body: () throws -> T) rethrows -> T {
        return try SwiftUI.withAnimation(easeInOut(duration: baseDuration), body)
    }
    
    /// Helper to create a withAnimation block using spring animation
    func withSpringAnimation<T>(response baseResponse: Double = 0.3, dampingFraction baseDamping: Double = 0.8, _ body: () throws -> T) rethrows -> T {
        return try SwiftUI.withAnimation(spring(response: baseResponse, dampingFraction: baseDamping), body)
    }
    
    /// Get symbol effect speed multiplier (inverse of duration multiplier for symbol effects)
    /// Symbol effects use speed where 1.0 is normal, >1.0 is faster, <1.0 is slower
    func symbolEffectSpeed(for baseSpeed: Double = 1.0) -> Double {
        // For symbol effects, we want inverse relationship: slower animations = lower speed value
        return baseSpeed / currentSpeed.durationMultiplier
    }
}

