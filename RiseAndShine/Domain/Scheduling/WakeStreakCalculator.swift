import Foundation

/// A single day's wake outcome, reduced to what the streak math needs.
public struct WakeDayResult: Equatable, Sendable {
    public let day: Date
    public let success: Bool

    public init(day: Date, success: Bool) {
        self.day = day
        self.success = success
    }
}

/// Current and longest wake-up streaks.
public struct WakeStreaks: Equatable, Sendable {
    /// Length of the most recent unbroken run of successful days.
    public let current: Int
    /// Longest unbroken run of successful days ever recorded.
    public let longest: Int

    public init(current: Int, longest: Int) {
        self.current = current
        self.longest = longest
    }

    public static let zero = WakeStreaks(current: 0, longest: 0)
}

/// Pure, dependency-free wake-up-streak math.
///
/// A *streak* is a run of consecutive successful days (first alarm dismissed
/// without snoozing). Days with no alarm produce no record and are treated as
/// neutral — they neither extend nor break a streak — so the streak reflects
/// "days you got up on time," not "every calendar day."
public enum WakeStreakCalculator {

    /// Reduces raw records to one boolean per calendar day. If a day somehow has
    /// multiple records, the day counts as a success only if *every* record that
    /// day succeeded (a single snooze breaks it).
    public static func dailyResults(
        from records: [WakeRecord],
        calendar: Calendar = .current
    ) -> [WakeDayResult] {
        var byDay: [Date: Bool] = [:]
        for record in records {
            let day = calendar.startOfDay(for: record.dayStart)
            byDay[day] = (byDay[day] ?? true) && record.wokeWithoutSnooze
        }
        return byDay
            .map { WakeDayResult(day: $0.key, success: $0.value) }
            .sorted { $0.day < $1.day }
    }

    /// Computes current and longest streaks from per-day results.
    /// Input order is irrelevant; results are sorted internally.
    public static func streaks(for results: [WakeDayResult]) -> WakeStreaks {
        guard !results.isEmpty else { return .zero }
        let sorted = results.sorted { $0.day < $1.day }

        var longest = 0
        var run = 0
        for result in sorted {
            if result.success {
                run += 1
                longest = max(longest, run)
            } else {
                run = 0
            }
        }

        var current = 0
        for result in sorted.reversed() {
            if result.success { current += 1 } else { break }
        }

        return WakeStreaks(current: current, longest: longest)
    }

    /// Convenience: compute streaks directly from `WakeRecord`s.
    public static func streaks(
        from records: [WakeRecord],
        calendar: Calendar = .current
    ) -> WakeStreaks {
        streaks(for: dailyResults(from: records, calendar: calendar))
    }

    /// Whether the current streak is still "live" — its most recent successful
    /// day is today or yesterday. Used to decide whether to submit to the
    /// leaderboard (a streak whose last success is older has effectively ended,
    /// even though `streaks(...).current` still reports its historical length).
    public static func isCurrentStreakActive(
        results: [WakeDayResult],
        asOf reference: Date = .now,
        calendar: Calendar = .current
    ) -> Bool {
        guard let mostRecentSuccess = results.filter(\.success).map(\.day).max() else {
            return false
        }
        let today = calendar.startOfDay(for: reference)
        guard let dayDelta = calendar.dateComponents([.day], from: calendar.startOfDay(for: mostRecentSuccess), to: today).day else {
            return false
        }
        return dayDelta <= 1
    }
}
