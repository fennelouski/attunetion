import Foundation

enum WidgetRefreshSchedule {
    static func nextRefreshDate(
        scope: String?,
        after date: Date,
        calendar: Calendar = .current
    ) -> Date {
        // Calendar intervals respect local week starts and 23/25-hour days.
        // Adding a month to today's date does not reach the next month boundary.
        return (IntentionScope(rawValue: scope ?? "day") ?? .day).interval(containing: date, calendar: calendar)?.end
            ?? date.addingTimeInterval(3600)
    }
}
