//
//  MacOSPageIndicator.swift
//  Attunetion
//
//  Created for macOS-specific onboarding page indicator
//

import SwiftUI
#if os(macOS)
import AppKit
#endif

/// macOS-specific minimal page indicator - elegant and subtle
struct MacOSPageIndicator: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var themeManager: AppThemeManager
    
    let currentPage: Int
    let pageCount: Int
    let onPageSelected: ((Int) -> Void)?
    
    init(currentPage: Int, pageCount: Int, themeManager: AppThemeManager, onPageSelected: ((Int) -> Void)? = nil) {
        self.currentPage = currentPage
        self.pageCount = pageCount
        self.themeManager = themeManager
        self.onPageSelected = onPageSelected
    }
    
    private var progress: Double {
        Double(currentPage + 1) / Double(pageCount)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Minimal progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    Capsule()
                        .fill(
                            themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.15)
                        )
                    
                    // Progress fill
                    Capsule()
                        .fill(
                            themeManager.accentColor(for: colorScheme).toSwiftUIColor()
                        )
                        .frame(width: geometry.size.width * progress)
                        .animation(.easeInOut(duration: 0.3), value: currentPage)
                }
            }
            .frame(height: 3)
            
            // Subtle page counter text
            Text(String(format: String(localized: "%1$d of %2$d"), currentPage + 1, pageCount))
                .font(.system(size: 11, weight: .regular, design: .default))
                .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.6))
        }
        .frame(width: 200)
    }
}

#Preview {
    VStack(spacing: 40) {
        MacOSPageIndicator(
            currentPage: 0,
            pageCount: 5,
            themeManager: AppThemeManager()
        )
        
        MacOSPageIndicator(
            currentPage: 2,
            pageCount: 5,
            themeManager: AppThemeManager()
        )
        
        MacOSPageIndicator(
            currentPage: 4,
            pageCount: 5,
            themeManager: AppThemeManager()
        )
    }
    .padding()
    .frame(width: 800)
    .background(Color.black)
}

