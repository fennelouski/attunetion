import Foundation

/// Stable raw values preserve existing intention files. Seasons are three-month spans,
/// beginning March, June, September and December, rather than hemisphere-specific names.
enum IntentionScope: String, Codable, CaseIterable, Hashable, Sendable {
    case day, week, month, season, year

    func interval(containing date: Date, calendar: Calendar = .current) -> DateInterval? {
        switch self {
        case .day: return calendar.dateInterval(of: .day, for: date)
        case .week: return calendar.dateInterval(of: .weekOfYear, for: date)
        case .month: return calendar.dateInterval(of: .month, for: date)
        case .year: return calendar.dateInterval(of: .year, for: date)
        case .season:
            var gregorian = Calendar(identifier: .gregorian)
            gregorian.timeZone = calendar.timeZone
            let components = gregorian.dateComponents([.year, .month], from: date)
            guard let year = components.year, let month = components.month else { return nil }
            let startMonth: Int
            let startYear: Int
            if month < 3 { startMonth = 12; startYear = year - 1 }
            else { startMonth = ((month - 3) / 3) * 3 + 3; startYear = year }
            guard let start = gregorian.date(from: DateComponents(year: startYear, month: startMonth, day: 1)),
                  let end = gregorian.date(byAdding: .month, value: 3, to: start) else { return nil }
            return DateInterval(start: start, end: end)
        }
    }

    func isCurrent(_ scopeDate: Date, at now: Date = Date(), calendar: Calendar = .current) -> Bool {
        guard let period = interval(containing: now, calendar: calendar) else { return false }
        return scopeDate >= period.start && scopeDate < period.end
    }

    func dateRangeLabel(for date: Date, calendar: Calendar = .current) -> String {
        guard let period = interval(containing: date, calendar: calendar) else { return date.formatted(date: .abbreviated, time: .omitted) }
        let lastDay = calendar.date(byAdding: .day, value: -1, to: period.end) ?? period.start
        return "\(period.start.formatted(date: .abbreviated, time: .omitted)) – \(lastDay.formatted(date: .abbreviated, time: .omitted))"
    }
}

/// App Group payload shared with the widget. It can choose a broader focus after
/// a shorter one expires, even when the main app has not been opened again.
struct IntentionWidgetRecord: Codable {
    let id: UUID
    let text: String
    let scope: String
    let scopeDate: Date
    let quote: String?
    let aiGenerated: Bool
    let backgroundColor: String?
    let textColor: String?
    let accentColor: String?
    let fontName: String?

    static func current(from records: [Self], at date: Date, calendar: Calendar = .current) -> Self? {
        for scope in IntentionScope.allCases {
            if let record = records.filter({ $0.scope == scope.rawValue && scope.isCurrent($0.scopeDate, at: date, calendar: calendar) })
                .max(by: { $0.scopeDate < $1.scopeDate }) { return record }
        }
        return nil
    }

    static func nextBoundary(in records: [Self], after date: Date, calendar: Calendar = .current) -> Date {
        let boundaries = records.flatMap { record -> [Date] in
            guard let scope = IntentionScope(rawValue: record.scope),
                  let period = scope.interval(containing: record.scopeDate, calendar: calendar) else { return [] }
            return [period.start, period.end].filter { $0 > date }
        }
        return boundaries.min() ?? calendar.dateInterval(of: .day, for: date)?.end ?? date.addingTimeInterval(3600)
    }
}
