import Foundation

enum WidgetRefreshSchedule {
    static func nextRefreshDate(
        scope: String?,
        after date: Date,
        calendar: Calendar = .current
    ) -> Date {
        let component: Calendar.Component
        switch scope {
        case "week": component = .weekOfYear
        case "month": component = .month
        default: component = .day
        }

        // Calendar intervals respect local week starts and 23/25-hour days.
        // Adding a month to today's date does not reach the next month boundary.
        return calendar.dateInterval(of: component, for: date)?.end
            ?? date.addingTimeInterval(3600)
    }
}
