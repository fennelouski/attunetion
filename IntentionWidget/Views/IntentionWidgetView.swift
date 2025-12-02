//
//  IntentionWidgetView.swift
//  IntentionWidget
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI
import WidgetKit

/// Main widget view that routes to appropriate size-specific view
struct IntentionWidgetView: View {
    var entry: IntentionWidgetProvider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        case .accessoryRectangular:
            LockScreenRectangularWidgetView(entry: entry)
        case .accessoryCircular:
            LockScreenCircularWidgetView(entry: entry)
        case .accessoryInline:
            LockScreenInlineWidgetView(entry: entry)
        default:
            MediumWidgetView(entry: entry)
        }
    }
}

