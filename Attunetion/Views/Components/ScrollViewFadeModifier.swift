//
//  ScrollViewFadeModifier.swift
//  Attunetion
//
//  Created for scroll view fade gradient effect
//

import SwiftUI

/// Wrapper view that adds fade gradients at the top and bottom of a ScrollView
struct FadedScrollView<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var themeManager: AppThemeManager
    let axes: Axis.Set
    let showsIndicators: Bool
    let content: Content
    
    init(
        _ axes: Axis.Set = .vertical,
        showsIndicators: Bool = true,
        themeManager: AppThemeManager,
        @ViewBuilder content: () -> Content
    ) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.themeManager = themeManager
        self.content = content()
    }
    
    private var backgroundColor: Color {
        themeManager.backgroundColor(for: colorScheme).toSwiftUIColor()
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(axes, showsIndicators: showsIndicators) {
                content
            }
            
            // Top fade gradient - positioned at the top edge
            VStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        backgroundColor,
                        backgroundColor.opacity(0)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 8)
                .allowsHitTesting(false)
                
                Spacer()
            }
            
            // Bottom fade gradient - positioned at the bottom edge
            VStack {
                Spacer()
                
                LinearGradient(
                    gradient: Gradient(colors: [
                        backgroundColor.opacity(0),
                        backgroundColor
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 8)
                .allowsHitTesting(false)
            }
        }
    }
}

