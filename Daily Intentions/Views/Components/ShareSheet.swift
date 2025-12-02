//
//  ShareSheet.swift
//  Daily Intentions
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI
#if os(iOS)
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No update needed
    }
}
#elseif os(macOS)
import AppKit

struct ShareSheet: NSViewRepresentable {
    let activityItems: [Any]
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        // macOS sharing is typically handled via menu items or copy to pasteboard
        // This is a placeholder - actual sharing would be implemented via menu bar
    }
}
#elseif os(watchOS) || os(visionOS)
// watchOS and visionOS don't have native share sheets
// Use copy to pasteboard or other platform-specific sharing mechanisms
struct ShareSheet: View {
    let activityItems: [Any]
    
    var body: some View {
        EmptyView()
    }
}
#endif

