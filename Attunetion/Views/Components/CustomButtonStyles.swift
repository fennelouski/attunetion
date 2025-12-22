//
//  CustomButtonStyles.swift
//  Attunetion
//
//  Custom ButtonStyle implementations to prevent double background issues
//

import SwiftUI

/// ButtonStyle that applies a solid background color with no default button styling
struct SolidBackgroundButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let foregroundColor: Color
    let cornerRadius: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            // Background layer - ensures single background
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(backgroundColor)
            
            // Content layer
            configuration.label
                .foregroundColor(foregroundColor)
        }
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

/// ButtonStyle for primary buttons with shadow
struct PrimaryButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let foregroundColor: Color
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat
    let shadowY: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            // Background layer - ensures single background
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(backgroundColor)
            
            // Content layer
            configuration.label
                .foregroundColor(foregroundColor)
        }
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .shadow(
            color: shadowRadius > 0 ? backgroundColor.opacity(0.3) : .clear,
            radius: shadowRadius,
            x: 0,
            y: shadowY
        )
        .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

/// ButtonStyle for buttons with optional background (for unselected states)
struct OptionalBackgroundButtonStyle: ButtonStyle {
    let backgroundColor: Color?
    let foregroundColor: Color
    let cornerRadius: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            // Background layer - ensures single background
            if let bgColor = backgroundColor {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(bgColor)
            }
            
            // Content layer
            configuration.label
                .foregroundColor(foregroundColor)
        }
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

/// ButtonStyle for card-like buttons with border and shadow
struct CardButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let borderColor: Color
    let cornerRadius: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            // Background layer - ensures single background
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(backgroundColor)
            
            // Content layer
            configuration.label
        }
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(borderColor, lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .shadow(
            color: Color.black.opacity(0.05),
            radius: 6,
            x: 0,
            y: 2
        )
        .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

