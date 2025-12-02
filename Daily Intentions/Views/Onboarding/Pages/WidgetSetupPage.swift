//
//  WidgetSetupPage.swift
//  Daily Intentions
//
//  Created for onboarding experience
//

import SwiftUI
#if canImport(WidgetKit)
import WidgetKit
#endif

/// Third page of onboarding - Widget setup information
struct WidgetSetupPage: View {
    let onContinue: () -> Void
    let onSkip: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Widget illustration
            Image(systemName: "square.on.square")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
            
            VStack(spacing: 16) {
                Text("Your intention,")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("always visible")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Text("Add a widget to your home screen or lock screen to keep your intention in sight")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 32)
            
            // Widget preview mockup
            VStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
                    .frame(height: 120)
                    .overlay(
                        VStack(spacing: 8) {
                            Text("TODAY")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("Be present")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                    )
                    .padding(.horizontal, 32)
                
                Text("Customize with themes and fonts")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                
                Button(action: onSkip) {
                    Text("Skip")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
        .padding()
    }
}

#Preview {
    WidgetSetupPage(
        onContinue: { print("Continue") },
        onSkip: { print("Skip") }
    )
}

