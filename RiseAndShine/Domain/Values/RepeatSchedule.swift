import Foundation

/// Describes how often an alarm repeats.
///
/// An empty set of days means the alarm is *one-time*: it fires at the next
/// occurrence of its clock time and then disables itself. A non-empty set means
/// the alarm repeats on those weekdays indefinitely.
///
/// Persisted on `Alarm` as an `Int` bitmask (`repeatDaysMask`) for SwiftData
/// robustness; this type is the in-memory representation.
public struct RepeatSchedule: Equatable, Sendable, Codable {
    public private(set) var days: Set<Weekday>

    public init(days: Set<Weekday> = []) {
        self.days = days
    }

    public var isOneTime: Bool { days.isEmpty }
    public var isRepeating: Bool { !days.isEmpty }

    public mutating func toggle(_ day: Weekday) {
        if days.contains(day) { days.remove(day) } else { days.insert(day) }
    }

    public func contains(_ day: Weekday) -> Bool { days.contains(day) }

    // MARK: - Bitmask packing (persistence bridge)

    public init(mask: Int) {
        var result: Set<Weekday> = []
        for day in Weekday.allCases where mask & (1 << day.bitIndex) != 0 {
            result.insert(day)
        }
        self.days = result
    }

    public var mask: Int {
        days.reduce(into: 0) { $0 |= (1 << $1.bitIndex) }
    }

    // MARK: - Presets

    public static let oneTime = RepeatSchedule(days: [])
    public static let everyday = RepeatSchedule(days: Set(Weekday.allCases))
    public static let weekdays = RepeatSchedule(days: Weekday.weekdays)
    public static let weekends = RepeatSchedule(days: Weekday.weekend)

    // MARK: - Display

    /// A concise, localized description such as "Every day", "Weekdays",
    /// "Mon, Wed, Fri", or "Never" for a one-time alarm.
    public func displayName(locale: Locale = .current) -> String {
        if isOneTime { return L10n.Repeat.never }
        if days == Set(Weekday.allCases) { return L10n.Repeat.everyday }
        if days == Weekday.weekdays { return L10n.Repeat.weekdays }
        if days == Weekday.weekend { return L10n.Repeat.weekends }
        return days.sorted()
            .map { $0.shortDisplayName(locale: locale) }
            .joined(separator: ", ")
    }
}
