//
//  IntentionWidgetProvider.swift
//  IntentionWidget
//
//  Created by Nathan Fennel on 12/2/25.
//

import Foundation
import WidgetKit

/// Timeline provider for the Intention Widget
struct IntentionWidgetProvider: TimelineProvider {
    typealias Entry = IntentionWidgetEntry
    
    // App Group identifier for data sharing
    private let appGroupIdentifier = "group.com.nathanfennel.Attunetion"
    
    func placeholder(in context: Context) -> IntentionWidgetEntry {
        IntentionWidgetEntry.mock()
    }
    
    func getSnapshot(in context: Context, completion: @escaping (IntentionWidgetEntry) -> Void) {
        // For preview/gallery, return mock data quickly
        let entry = IntentionWidgetEntry.mock()
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<IntentionWidgetEntry>) -> Void) {
        // Read the current intention shared by the app.
        let currentDate = Date()
        let intention = getCurrentIntention()
        let theme = getCurrentTheme()
        
        let entry = IntentionWidgetEntry(
            date: currentDate,
            intention: intention,
            theme: theme
        )
        
        // Calculate next update time
        // Update at midnight for day intentions
        // Update at start of week for week intentions
        // Update at start of month for month intentions
        let nextUpdate = calculateNextUpdateDate(for: intention)
        
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    // MARK: - Private Helpers
    
    /// Get current intention from App Group
    private func getCurrentIntention() -> IntentionData? {
        WidgetDataService.shared.getCurrentIntentionData()
    }
    
    /// Get current theme from App Group
    private func getCurrentTheme() -> ThemeData? {
        if let themeData = WidgetDataService.shared.getCurrentThemeData() {
            return themeData
        }
        // Fallback to default theme if no theme set
        return WidgetTheme.ocean
    }
    
    /// Calculate the next date when the widget should update
    private func calculateNextUpdateDate(for intention: IntentionData?) -> Date {
        WidgetRefreshSchedule.nextRefreshDate(scope: intention?.scope, after: Date())
    }
}
