import Foundation

func calendar(timeZone: String, firstWeekday: Int = 1) -> Calendar {
    var result = Calendar(identifier: .gregorian)
    result.timeZone = TimeZone(identifier: timeZone)!
    result.firstWeekday = firstWeekday
    return result
}

func localDate(_ text: String, calendar: Calendar) -> Date {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.calendar = calendar
    formatter.timeZone = calendar.timeZone
    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    return formatter.date(from: text)!
}

let cases: [(String, String?, String, String, Calendar)] = [
    ("mid-month", "month", "2026-10-03 12:00", "2026-11-01 00:00", calendar(timeZone: "America/Los_Angeles")),
    ("January 31", "month", "2026-01-31 12:00", "2026-02-01 00:00", calendar(timeZone: "Europe/Amsterdam")),
    ("leap February", "month", "2028-02-28 12:00", "2028-03-01 00:00", calendar(timeZone: "Europe/Amsterdam")),
    ("year boundary", "month", "2026-12-31 23:59", "2027-01-01 00:00", calendar(timeZone: "Pacific/Auckland")),
    ("month boundary itself", "month", "2026-11-01 00:00", "2026-12-01 00:00", calendar(timeZone: "America/Los_Angeles")),
    ("Sunday week start", "week", "2026-10-03 12:00", "2026-10-04 00:00", calendar(timeZone: "America/Los_Angeles")),
    ("Monday week start", "week", "2026-10-03 12:00", "2026-10-05 00:00", calendar(timeZone: "Europe/Amsterdam", firstWeekday: 2)),
    ("Saturday week start", "week", "2026-10-03 12:00", "2026-10-10 00:00", calendar(timeZone: "Asia/Dubai", firstWeekday: 7)),
    ("week boundary itself", "week", "2026-10-05 00:00", "2026-10-12 00:00", calendar(timeZone: "Europe/Amsterdam", firstWeekday: 2)),
    ("DST fall day", "day", "2026-11-01 00:30", "2026-11-02 00:00", calendar(timeZone: "America/Los_Angeles")),
    ("DST spring day", "day", "2026-03-08 00:30", "2026-03-09 00:00", calendar(timeZone: "America/Los_Angeles")),
    ("Dutch DST fall day", "day", "2026-10-25 00:30", "2026-10-26 00:00", calendar(timeZone: "Europe/Amsterdam")),
    ("empty widget on DST fall day", nil, "2026-11-01 00:30", "2026-11-02 00:00", calendar(timeZone: "America/Los_Angeles")),
    ("unknown scope uses day", "unexpected", "2026-10-03 12:00", "2026-10-04 00:00", calendar(timeZone: "UTC")),
]

for (label, scope, input, expected, calendar) in cases {
    let now = localDate(input, calendar: calendar)
    let expectedDate = localDate(expected, calendar: calendar)
    let actual = WidgetRefreshSchedule.nextRefreshDate(scope: scope, after: now, calendar: calendar)
    guard actual == expectedDate, actual > now else {
        fatalError("\(label): expected \(expectedDate), got \(actual), now \(now)")
    }
    print("PASS \(label)")
}
print("PASS all \(cases.count) widget calendar boundary checks")
