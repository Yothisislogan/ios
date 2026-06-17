import Foundation

/// A day of the week.
///
/// Raw values intentionally match Foundation's `Calendar` weekday component
/// (Sunday == 1 ... Saturday == 7) so the value can be passed directly into
/// `DateComponents.weekday` without translation.
public enum Weekday: Int, CaseIterable, Codable, Sendable, Identifiable, Comparable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7

    public var id: Int { rawValue }

    public static func < (lhs: Weekday, rhs: Weekday) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    /// Zero-based bit index used when packing a set of weekdays into a mask.
    var bitIndex: Int { rawValue - 1 }

    /// Monday-through-Friday convenience set.
    public static var weekdays: Set<Weekday> { [.monday, .tuesday, .wednesday, .thursday, .friday] }

    /// Saturday and Sunday.
    public static var weekend: Set<Weekday> { [.saturday, .sunday] }

    /// Localized full name, respecting the user's locale and calendar ordering rules.
    public func displayName(locale: Locale = .current) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = locale
        // `weekdaySymbols` is 0-indexed starting at Sunday.
        return calendar.weekdaySymbols[rawValue - 1]
    }

    /// Localized short name (e.g. "Mon").
    public func shortDisplayName(locale: Locale = .current) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = locale
        return calendar.shortWeekdaySymbols[rawValue - 1]
    }

    /// Very short, single/double letter name (e.g. "M").
    public func narrowDisplayName(locale: Locale = .current) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = locale
        return calendar.veryShortWeekdaySymbols[rawValue - 1]
    }
}
