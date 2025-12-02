//
//  AboutView.swift
//  Daily Intentions
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // App icon placeholder
                    Image(systemName: "sparkles")
                        .font(.system(size: 80))
                        .foregroundColor(.accentColor)
                        .padding()
                    
                    Text("Daily Intentions")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Version 1.0.0")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("About")
                            .font(.headline)
                        
                        Text("Daily Intentions helps you set and track your intentions for each day, week, and month. Stay focused on what matters most.")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Credits")
                            .font(.headline)
                        
                        Text("Built with SwiftUI and SwiftData")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AboutView()
}

