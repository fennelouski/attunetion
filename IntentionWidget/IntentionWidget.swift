//
//  IntentionWidget.swift
//  IntentionWidget
//
//  Created by Nathan Fennel on 12/2/25.
//

import WidgetKit
import SwiftUI

@main
struct IntentionWidget: Widget {
    let kind: String = "IntentionWidget"
    
    var body: some WidgetConfiguration {
        var families: [WidgetFamily] = [
            .systemSmall,
            .systemMedium,
            .systemLarge
        ]
        
        #if os(iOS) || os(watchOS)
        // Accessory widgets are only available on iOS and watchOS
        families.append(contentsOf: [
            .accessoryRectangular,
            .accessoryCircular,
            .accessoryInline
        ])
        #endif
        
        #if os(visionOS)
        // visionOS 2.0+ supports spatial widgets that can be pinned in virtual space
        if #available(visionOS 2.0, *) {
            // Add spatial widget families for visionOS
            // These allow users to pin "posters" in their virtual environment
            families.append(.systemExtraLarge)
            families.append(.systemExtraLargeRectangular)
        }
        #endif
        
        return StaticConfiguration(kind: kind, provider: IntentionWidgetProvider()) { entry in
            IntentionWidgetView(entry: entry)
        }
        .configurationDisplayName("Daily Intention")
        .description("Display your current daily, weekly, or monthly intention.")
        .supportedFamilies(families)
    }
}

#Preview(as: .systemSmall) {
    IntentionWidget()
} timeline: {
    IntentionWidgetEntry.mock()
    IntentionWidgetEntry.empty()
}

#Preview(as: .systemMedium) {
    IntentionWidget()
} timeline: {
    IntentionWidgetEntry.mock()
    IntentionWidgetEntry.mockWeek()
    IntentionWidgetEntry.empty()
}

#Preview(as: .systemLarge) {
    IntentionWidget()
} timeline: {
    IntentionWidgetEntry.mock()
    IntentionWidgetEntry.mockMonth()
    IntentionWidgetEntry.empty()
}

#if os(visionOS)
@available(visionOS 2.0, *)
#Preview(as: .systemExtraLarge) {
    IntentionWidget()
} timeline: {
    IntentionWidgetEntry.mock()
    IntentionWidgetEntry.mockWeek()
    IntentionWidgetEntry.mockMonth()
    IntentionWidgetEntry.empty()
}

@available(visionOS 2.0, *)
#Preview(as: .systemExtraLargeRectangular) {
    IntentionWidget()
} timeline: {
    IntentionWidgetEntry.mock()
    IntentionWidgetEntry.mockWeek()
    IntentionWidgetEntry.mockMonth()
    IntentionWidgetEntry.empty()
}
#endif

