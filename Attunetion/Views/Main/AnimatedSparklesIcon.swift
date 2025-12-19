//
//  AnimatedSparklesIcon.swift
//  Attunetion
//
//  Created by Nathan Fennel on 12/3/25.
//

import SwiftUI

// Animated target icon with layered breathe animation
struct AnimatedSparklesIcon: View {
    let size: CGFloat
    let color: Color
    
    @State private var animationPhase: CGFloat = 0
    
    private let breatheDuration: Double = 4.8
    
    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.016)) { timeline in
            let elapsed = timeline.date.timeIntervalSince1970
            let phase = (elapsed.truncatingRemainder(dividingBy: breatheDuration) / breatheDuration) * .pi * 2
            
            // Single target icon with gentle breathe animation
            Image(systemName: "target")
                .font(.system(size: size, weight: .light))
                .foregroundColor(color)
                .scaleEffect(1.0 + CGFloat(sin(Double(phase))) * 0.1)
                .opacity(0.8 + CGFloat(sin(Double(phase))) * 0.2)
                .frame(width: size, height: size)
        }
    }
}
