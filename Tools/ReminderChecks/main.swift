import Foundation

@main
struct ReminderChecks {
    @MainActor static func main() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/New_York")!

        func date(_ month: Int, _ day: Int, _ hour: Int) -> Date {
            calendar.date(from: DateComponents(year: 2026, month: month, day: day, hour: hour))!
        }

        let time = DateComponents(hour: 8, minute: 0)
        let anchor = date(10, 30, 8)
        let first = NotificationManager.everyOtherDayDates(
            anchor: anchor, after: date(10, 29, 12), time: time, calendar: calendar, count: 4
        )
        precondition(first == [date(10, 30, 8), date(11, 1, 8), date(11, 3, 8), date(11, 5, 8)])

        let resumed = NotificationManager.everyOtherDayDates(
            anchor: anchor, after: date(11, 1, 9), time: time, calendar: calendar, count: 2
        )
        precondition(resumed == [date(11, 3, 8), date(11, 5, 8)])
        precondition(first.allSatisfy { calendar.component(.hour, from: $0) == 8 })
        print("PASS: Every-other-day reminders keep their start-date parity and local time across month and daylight-saving boundaries")
    }
}
