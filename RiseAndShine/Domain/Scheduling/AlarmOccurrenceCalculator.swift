import Foundation

/// Pure, dependency-free logic for computing when an alarm should next fire.
///
/// Deliberately operates on plain values (not the SwiftData `Alarm` model) so
/// it can be unit-tested in isolation and reused by the notification scheduler
/// (Stage 3). Uses `Calendar.nextDate(after:matching:)`, which correctly
/// accounts for time-zone changes and DST transitions.
public enum AlarmOccurrenceCalculator {

    /// The next moment this alarm should fire, strictly after `reference`.
    ///
    /// - For a one-time alarm (`weekdays` empty), returns the next occurrence of
    ///   `hour:minute` — today if it hasn't passed yet, otherwise tomorrow.
    /// - For a repeating alarm, returns the earliest occurrence of `hour:minute`
    ///   falling on one of `weekdays`.
    ///
    /// Returns `nil` only if the calendar cannot resolve a matching date (which
    /// should not happen for valid hour/minute inputs).
    public static func nextFireDate(
        hour: Int,
        minute: Int,
        weekdays: Set<Weekday>,
        after reference: Date,
        calendar: Calendar = .current
    ) -> Date? {
        guard (0...23).contains(hour), (0...59).contains(minute) else { return nil }

        if weekdays.isEmpty {
            var components = DateComponents()
            components.hour = hour
            components.minute = minute
            components.second = 0
            return calendar.nextDate(
                after: reference,
                matching: components,
                matchingPolicy: .nextTime
            )
        }

        let candidates = weekdays.compactMap { day -> Date? in
            var components = DateComponents()
            components.weekday = day.rawValue
            components.hour = hour
            components.minute = minute
            components.second = 0
            return calendar.nextDate(
                after: reference,
                matching: components,
                matchingPolicy: .nextTime
            )
        }
        return candidates.min()
    }

    /// The next `count` fire dates after `reference`, in ascending order.
    /// Useful for previews, the bedtime view, and (later) for batching the
    /// limited number of local notifications iOS allows per app.
    public static func upcomingFireDates(
        hour: Int,
        minute: Int,
        weekdays: Set<Weekday>,
        after reference: Date,
        count: Int,
        calendar: Calendar = .current
    ) -> [Date] {
        guard count > 0 else { return [] }
        var results: [Date] = []
        var cursor = reference
        for _ in 0..<count {
            guard let next = nextFireDate(
                hour: hour,
                minute: minute,
                weekdays: weekdays,
                after: cursor,
                calendar: calendar
            ) else { break }
            results.append(next)
            cursor = next
        }
        return results
    }

    /// Time interval from `reference` until the next fire, or `nil` if none.
    public static func timeUntilNextFire(
        hour: Int,
        minute: Int,
        weekdays: Set<Weekday>,
        from reference: Date,
        calendar: Calendar = .current
    ) -> TimeInterval? {
        guard let next = nextFireDate(
            hour: hour,
            minute: minute,
            weekdays: weekdays,
            after: reference,
            calendar: calendar
        ) else { return nil }
        return next.timeIntervalSince(reference)
    }
}
