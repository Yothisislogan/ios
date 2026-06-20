import XCTest
@testable import RiseAndShine

final class WakeStreakCalculatorTests: XCTestCase {

    private func makeCalendar() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        calendar.locale = Locale(identifier: "en_US_POSIX")
        return calendar
    }

    private func day(_ year: Int, _ month: Int, _ day: Int, _ calendar: Calendar) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    private func results(_ pairs: [(Date, Bool)]) -> [WakeDayResult] {
        pairs.map { WakeDayResult(day: $0.0, success: $0.1) }
    }

    // MARK: - streaks(for:)

    func testEmptyResultsAreZero() {
        XCTAssertEqual(WakeStreakCalculator.streaks(for: []), .zero)
    }

    func testCurrentAndLongestForUnbrokenRun() {
        let cal = makeCalendar()
        let r = results([
            (day(2026, 6, 15, cal), true),
            (day(2026, 6, 16, cal), true),
            (day(2026, 6, 17, cal), true),
        ])
        let streaks = WakeStreakCalculator.streaks(for: r)
        XCTAssertEqual(streaks.current, 3)
        XCTAssertEqual(streaks.longest, 3)
    }

    func testBreakResetsCurrentButLongestPersists() {
        let cal = makeCalendar()
        // 4-day run, a miss, then a 2-day run. Longest = 4, current = 2.
        let r = results([
            (day(2026, 6, 10, cal), true),
            (day(2026, 6, 11, cal), true),
            (day(2026, 6, 12, cal), true),
            (day(2026, 6, 13, cal), true),
            (day(2026, 6, 14, cal), false),
            (day(2026, 6, 15, cal), true),
            (day(2026, 6, 16, cal), true),
        ])
        let streaks = WakeStreakCalculator.streaks(for: r)
        XCTAssertEqual(streaks.current, 2)
        XCTAssertEqual(streaks.longest, 4)
    }

    func testTrailingFailureMakesCurrentZero() {
        let cal = makeCalendar()
        let r = results([
            (day(2026, 6, 15, cal), true),
            (day(2026, 6, 16, cal), false),
        ])
        XCTAssertEqual(WakeStreakCalculator.streaks(for: r).current, 0)
    }

    // MARK: - dailyResults(from:)

    func testDailyResultsCollapsesMultipleRecordsPerDay() {
        let cal = makeCalendar()
        let theDay = day(2026, 6, 17, cal)
        let records = [
            WakeRecord(dayStart: theDay, wokeWithoutSnooze: true),
            // A second record the same day with a snooze => the day fails.
            WakeRecord(dayStart: cal.date(byAdding: .hour, value: 3, to: theDay)!, wokeWithoutSnooze: false, snoozeCount: 1),
        ]
        let daily = WakeStreakCalculator.dailyResults(from: records, calendar: cal)
        XCTAssertEqual(daily.count, 1)
        XCTAssertEqual(daily.first?.success, false)
    }

    // MARK: - isCurrentStreakActive

    func testActiveWhenMostRecentSuccessIsToday() {
        let cal = makeCalendar()
        let today = day(2026, 6, 17, cal)
        let r = results([(day(2026, 6, 16, cal), true), (today, true)])
        XCTAssertTrue(WakeStreakCalculator.isCurrentStreakActive(results: r, asOf: today, calendar: cal))
    }

    func testActiveWhenMostRecentSuccessIsYesterday() {
        let cal = makeCalendar()
        let today = day(2026, 6, 17, cal)
        let r = results([(day(2026, 6, 16, cal), true)])
        XCTAssertTrue(WakeStreakCalculator.isCurrentStreakActive(results: r, asOf: today, calendar: cal))
    }

    func testLapsedWhenMostRecentSuccessIsOlderThanYesterday() {
        let cal = makeCalendar()
        let today = day(2026, 6, 17, cal)
        let r = results([(day(2026, 6, 14, cal), true)])
        XCTAssertFalse(WakeStreakCalculator.isCurrentStreakActive(results: r, asOf: today, calendar: cal))
    }
}
