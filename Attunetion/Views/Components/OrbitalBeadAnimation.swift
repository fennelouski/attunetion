//
//  OrbitalBeadAnimation.swift
//  Attunetion
//
//  Created by Nathan Fennel on 12/6/25.
//

import SwiftUI

/// A subtle orbital animation with a pulsating bead on a thin circular path
/// Used to indicate active intentions (today, this week, this month)
struct OrbitalBeadAnimation: View {
    let size: CGFloat
    let color: Color
    let orbitDuration: Double
    let maxBeads: Int

    @State private var rotation: Double = 0

    init(size: CGFloat = 44, color: Color, orbitDuration: Double = 8.0, maxBeads: Int = 3) {
        self.size = size
        self.color = color
        self.orbitDuration = orbitDuration
        self.maxBeads = maxBeads
    }

    /// Bead lifecycle configuration
    /// Each bead has: fade-in duration, stay duration, fade-out duration
    private func beadLifecycle(for index: Int) -> (fadeIn: Double, stay: Double, fadeOut: Double) {
        switch index {
        case 0: return (5.0, 5.0, 5.0)
        case 1: return (6.1, 6.1, 6.1)
        case 2: return (9.3, 9.3, 9.3)
        case 3: return (7.2, 7.2, 7.2)
        case 4: return (8.5, 8.5, 8.5)
        case 5: return (6.8, 6.8, 6.8)
        case 6: return (10.1, 10.1, 10.1)
        case 7: return (7.9, 7.9, 7.9)
        case 8: return (9.7, 9.7, 9.7)
        case 9: return (8.2, 8.2, 8.2)
        default: return (5.0, 5.0, 5.0)
        }
    }

    /// Calculate the visibility (0.0 to 1.0) of a bead based on its lifecycle
    private func beadVisibility(elapsed: TimeInterval, index: Int) -> CGFloat {
        let lifecycle = beadLifecycle(for: index)
        let totalCycle = lifecycle.fadeIn + lifecycle.stay + lifecycle.fadeOut
        let timeInCycle = elapsed.truncatingRemainder(dividingBy: totalCycle)

        if timeInCycle < lifecycle.fadeIn {
            // Fade in phase
            return CGFloat(timeInCycle / lifecycle.fadeIn)
        } else if timeInCycle < lifecycle.fadeIn + lifecycle.stay {
            // Stay phase
            return 1.0
        } else {
            // Fade out phase
            let fadeOutProgress = timeInCycle - lifecycle.fadeIn - lifecycle.stay
            return CGFloat(1.0 - (fadeOutProgress / lifecycle.fadeOut))
        }
    }

    /// Calculate orbital offset for each bead (different speeds)
    private func beadOrbitOffset(for index: Int) -> Double {
        // Each bead has a slightly different orbital speed
        let speedMultiplier = 1.0 + (Double(index) * 0.15)
        return Double(index) * 45.0 * speedMultiplier // Offset starting positions
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.016)) { timeline in
            let elapsed = timeline.date.timeIntervalSince1970

            // Slower pulse for the ring (different phase for variety)
            let ringPulsePhase = (elapsed.truncatingRemainder(dividingBy: 3.6) / 3.6) * .pi * 2
            let ringPulse = CGFloat(sin(ringPulsePhase))

            ZStack {
                // Thin orbital ring with pulsating opacity and line width
                Circle()
                    .strokeBorder(
                        color.opacity(0.15 * (0.3 + ringPulse * 0.7)), // Pulse from 30% to 100% of max opacity
                        lineWidth: 0.5 * (0.4 + ringPulse * 0.6) // Pulse from 0.2pt to 0.5pt
                    )
                    .frame(width: size, height: size)

                // Multiple pulsating beads traveling along the orbit
                ForEach(0..<maxBeads, id: \.self) { index in
                    let visibility = beadVisibility(elapsed: elapsed, index: index)
                    let orbitOffset = beadOrbitOffset(for: index)
                    let speedMultiplier = 1.0 + (Double(index) * 0.15)
                    let orbitPhase = ((elapsed * speedMultiplier).truncatingRemainder(dividingBy: orbitDuration) / orbitDuration) * 360 + orbitOffset
                    let pulsePhase = (elapsed.truncatingRemainder(dividingBy: 2.4 + Double(index) * 0.3) / (2.4 + Double(index) * 0.3)) * .pi * 2

                    Circle()
                        .fill(color)
                        .frame(width: 3, height: 3)
                        .scaleEffect(1.0 + CGFloat(sin(pulsePhase)) * 0.4)
                        .opacity((0.7 + CGFloat(sin(pulsePhase)) * 0.3) * visibility)
                        .offset(x: size / 2)
                        .rotationEffect(.degrees(orbitPhase))
                        .shadow(color: color.opacity(0.5 * visibility), radius: 2, x: 0, y: 0)
                }
            }
            .frame(width: size, height: size)
        }
    }
}

/// A variant with a slower, more meditative orbit for monthly intentions
struct SlowOrbitalBeadAnimation: View {
    let size: CGFloat
    let color: Color

    var body: some View {
        OrbitalBeadAnimation(size: size, color: color, orbitDuration: 12.0, maxBeads: 10)
    }
}

/// A variant with a faster orbit for daily intentions
struct FastOrbitalBeadAnimation: View {
    let size: CGFloat
    let color: Color

    var body: some View {
        OrbitalBeadAnimation(size: size, color: color, orbitDuration: 6.0, maxBeads: 3)
    }
}

/// A variant for weekly intentions
struct WeeklyOrbitalBeadAnimation: View {
    let size: CGFloat
    let color: Color

    var body: some View {
        OrbitalBeadAnimation(size: size, color: color, orbitDuration: 8.0, maxBeads: 7)
    }
}

#Preview("Single Orbital") {
    ZStack {
        Color.black
        OrbitalBeadAnimation(size: 60, color: .blue, maxBeads: 3)
    }
}

#Preview("Multiple Speeds") {
    ZStack {
        Color.black
        HStack(spacing: 40) {
            VStack(spacing: 8) {
                FastOrbitalBeadAnimation(size: 50, color: .blue)
                Text("Day (3 beads)")
                    .font(.caption)
                    .foregroundColor(.white)
            }

            VStack(spacing: 8) {
                WeeklyOrbitalBeadAnimation(size: 50, color: .purple)
                Text("Week (7 beads)")
                    .font(.caption)
                    .foregroundColor(.white)
            }

            VStack(spacing: 8) {
                SlowOrbitalBeadAnimation(size: 50, color: .orange)
                Text("Month (10 beads)")
                    .font(.caption)
                    .foregroundColor(.white)
            }
        }
    }
}
