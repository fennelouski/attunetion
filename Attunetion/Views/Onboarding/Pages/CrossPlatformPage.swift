//
//  CrossPlatformPage.swift
//  Attunetion
//
//  Created for onboarding experience
//

import SwiftUI

/// Page explaining cross-platform functionality
struct CrossPlatformPage: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager: AppThemeManager
    
    let onContinue: () -> Void
    let onSkip: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Custom background
                AppBackground(themeManager: themeManager)
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Main content area
                    VStack(spacing: 32) {
                        // Cross-platform illustration
                        Image(systemName: "iphone.and.ipad")
                            .font(.system(size: 60, weight: .ultraLight))
                            .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                        
                        VStack(spacing: 16) {
                            Text(String(localized: "Works across"))
                                .font(.system(size: 28, weight: .light, design: .default))
                                .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.center)
                            
                            Text(String(localized: "all your devices"))
                                .font(.system(size: 28, weight: .light, design: .default))
                                .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.center)
                        }
                        
                        Text(String(localized: "Your intentions sync automatically across iPhone, iPad, Mac, and Apple Watch. Set an intention on one device and it's available everywhere."))
                            .font(.system(size: 17, weight: .light, design: .default))
                            .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                            .opacity(0.75)
                            .padding(.horizontal, 60)
                            .frame(maxWidth: 700)
                        
                        // Device icons
                        HStack(spacing: 24) {
                            #if os(iOS)
                            DeviceIcon(iconName: "iphone", label: "iPhone")
                            DeviceIcon(iconName: "ipad", label: "iPad")
                            DeviceIcon(iconName: "applewatch", label: "Watch")
                            DeviceIcon(iconName: "laptopcomputer", label: "Mac")
                            #elseif os(macOS)
                            DeviceIcon(iconName: "laptopcomputer", label: "Mac")
                            DeviceIcon(iconName: "iphone", label: "iPhone")
                            DeviceIcon(iconName: "ipad", label: "iPad")
                            DeviceIcon(iconName: "applewatch", label: "Watch")
                            #elseif os(watchOS)
                            DeviceIcon(iconName: "applewatch", label: "Watch")
                            DeviceIcon(iconName: "iphone", label: "iPhone")
                            DeviceIcon(iconName: "ipad", label: "iPad")
                            DeviceIcon(iconName: "laptopcomputer", label: "Mac")
                            #else
                            DeviceIcon(iconName: "iphone", label: "iPhone")
                            DeviceIcon(iconName: "ipad", label: "iPad")
                            DeviceIcon(iconName: "applewatch", label: "Watch")
                            DeviceIcon(iconName: "laptopcomputer", label: "Mac")
                            #endif
                        }
                        .padding(.top, 8)
                    }
                    
                    Spacer()
                    
                    // Action buttons
                    VStack(spacing: 20) {
                        PrimaryButton("Continue", themeManager: themeManager, action: onContinue)
                            .frame(maxWidth: 360)
                        
                        TextButton("Skip", themeManager: themeManager, action: onSkip)
                            .padding(.top, 4)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 80)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}

/// Device icon component
private struct DeviceIcon: View {
    let iconName: String
    let label: String
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager: AppThemeManager
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.system(size: 32, weight: .ultraLight))
                .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                .frame(width: 50, height: 50)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                .fixedSize(horizontal: false, vertical: true)
                .opacity(0.75)
        }
    }
}

#Preview {
    CrossPlatformPage(
        onContinue: { print("Continue") },
        onSkip: { print("Skip") }
    )
}


