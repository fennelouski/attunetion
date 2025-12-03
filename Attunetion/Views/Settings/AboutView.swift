//
//  AboutView.swift
//  Attunetion
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager: AppThemeManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground(themeManager: themeManager)
                
                ScrollView {
                    VStack(spacing: 32) {
                        // App icon placeholder
                        Image(systemName: "sparkles")
                            .font(.system(size: 72, weight: .ultraLight))
                            .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                            .padding(.top, 20)
                        
                        VStack(spacing: 12) {
                            Text("Attunetion")
                                .font(.system(size: 36, weight: .light, design: .default))
                                .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                            
                            Text("Version 1.0.0")
                                .font(.system(size: 15, weight: .regular, design: .default))
                                .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                        }
                        
                        Divider()
                            .background(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.2))
                            .padding(.horizontal, 40)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("About")
                                .font(.system(size: 20, weight: .light, design: .default))
                                .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                            
                            Text("Attunetion helps you set and track your intentions for each day, week, and month. Stay focused on what matters most.")
                                .font(.system(size: 16, weight: .regular, design: .default))
                                .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                                .lineSpacing(4)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 40)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Credits")
                                .font(.system(size: 20, weight: .light, design: .default))
                                .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                            
                            Text("Built with SwiftUI and SwiftData")
                                .font(.system(size: 16, weight: .regular, design: .default))
                                .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 40)
                        
                        Spacer()
                            .frame(height: 40)
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("About")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                }
            }
        }
    }
}

#Preview {
    AboutView()
}

