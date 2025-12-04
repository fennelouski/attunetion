//
//  AnimatedSparklesIcon.swift
//  Attunetion
//
//  Created by Nathan Fennel on 12/3/25.
//

import SwiftUI

// Animated sparkles icon with layered breathe animation
struct AnimatedSparklesIcon: View {
    let size: CGFloat
    let color: Color
    
    @State private var animationPhase: CGFloat = 0
    
    private let breatheDuration: Double = 4.8
    
    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.016)) { timeline in
            let elapsed = timeline.date.timeIntervalSince1970
            let phase = (elapsed.truncatingRemainder(dividingBy: breatheDuration) / breatheDuration) * .pi * 2
            
            ZStack {
                // Layer 1 - Largest sparkle (bottom right) - phase offset: 0
                Image(systemName: "sparkle")
                    .font(.system(size: size * 0.8, weight: .ultraLight))
                    .foregroundColor(color)
                    .offset(x: size * 0.15, y: size * 0.15)
                    .scaleEffect(1.0 + CGFloat(sin(Double(phase))) * 0.15)
                    .opacity(0.7 + CGFloat(sin(Double(phase))) * 0.3)
                
                // Layer 2 - Medium sparkle (top left) - phase offset: π * 0.4
                Image(systemName: "sparkle")
                    .font(.system(size: size * 0.6, weight: .ultraLight))
                    .foregroundColor(color)
                    .offset(x: -size * 0.2, y: -size * 0.1)
                    .scaleEffect(1.0 + CGFloat(sin(Double(phase + .pi * 0.4))) * 0.15)
                    .opacity(0.7 + CGFloat(sin(Double(phase + .pi * 0.4))) * 0.3)
                
                // Layer 3 - Small sparkle (top center) - phase offset: π * 0.8
                Image(systemName: "sparkle")
                    .font(.system(size: size * 0.5, weight: .ultraLight))
                    .foregroundColor(color)
                    .offset(x: 0, y: -size * 0.25)
                    .scaleEffect(1.0 + CGFloat(sin(Double(phase + .pi * 0.8))) * 0.15)
                    .opacity(0.7 + CGFloat(sin(Double(phase + .pi * 0.8))) * 0.3)
            }
            .frame(width: size, height: size)
        }
    }
}
