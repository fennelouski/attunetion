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

    private var accessoryURL: URL? {
        if let intention = entry.intention {
            return URL(string: "dailyintentions://intention/\(intention.id.uuidString)")
        }
        return URL(string: "dailyintentions://new")
    }
    
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
                .widgetURL(accessoryURL)
        case .accessoryCircular:
            LockScreenCircularWidgetView(entry: entry)
                .widgetURL(accessoryURL)
        case .accessoryInline:
            LockScreenInlineWidgetView(entry: entry)
                .widgetURL(accessoryURL)
        #if os(visionOS)
        case .systemExtraLarge:
            // visionOS spatial widget - poster style for pinning in virtual space
            SpatialPosterWidgetView(entry: entry)
        case .systemExtraLargeRectangular:
            // visionOS spatial widget - rectangular poster style
            SpatialPosterWidgetView(entry: entry)
        #endif
        default:
            MediumWidgetView(entry: entry)
        }
    }
}

