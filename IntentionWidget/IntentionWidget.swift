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
        StaticConfiguration(kind: kind, provider: IntentionWidgetProvider()) { entry in
            IntentionWidgetView(entry: entry)
        }
        .configurationDisplayName("Daily Intention")
        .description("Display your current daily, weekly, or monthly intention.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryRectangular,
            .accessoryCircular,
            .accessoryInline
        ])
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

#Preview(as: .accessoryRectangular) {
    IntentionWidget()
} timeline: {
    IntentionWidgetEntry.mock()
    IntentionWidgetEntry.empty()
}

#Preview(as: .accessoryCircular) {
    IntentionWidget()
} timeline: {
    IntentionWidgetEntry.mock()
    IntentionWidgetEntry.empty()
}

#Preview(as: .accessoryInline) {
    IntentionWidget()
} timeline: {
    IntentionWidgetEntry.mock()
    IntentionWidgetEntry.empty()
}

