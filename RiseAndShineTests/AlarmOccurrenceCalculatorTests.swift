import XCTest
@testable import RiseAndShine

final class AlarmOccurrenceCalculatorTests: XCTestCase {

    /// A fixed calendar (UTC, Gregorian) so tests are deterministic regardless
    /// of where they run.
    private func makeCalendar() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        calendar.locale = Locale(identifier: "en_US_POSIX")
        return calendar
    }

    private func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int, calendar: Calendar) -> Date {
        var c = DateComponents()
        c.year = year; c.month = month; c.day = day; c.hour = hour; c.minute = minute
        return calendar.date(from: c)!
    }

    // MARK: - One-time alarms

    func testOneTimeAlarmLaterTodayFiresToday() {
        let calendar = makeCalendar()
        // 2026-06-17 is a Wednesday. Reference 08:00, alarm 09:30.
        let reference = date(2026, 6, 17, 8, 0, calendar: calendar)
        let next = AlarmOccurrenceCalculator.nextFireDate(
            hour: 9, minute: 30, weekdays: [], after: reference, calendar: calendar
        )
        XCTAssertEqual(next, date(2026, 6, 17, 9, 30, calendar: calendar))
    }

    func testOneTimeAlarmEarlierTodayRollsToTomorrow() {
        let calendar = makeCalendar()
        let reference = date(2026, 6, 17, 10, 0, calendar: calendar)
        let next = AlarmOccurrenceCalculator.nextFireDate(
            hour: 9, minute: 30, weekdays: [], after: reference, calendar: calendar
        )
        XCTAssertEqual(next, date(2026, 6, 18, 9, 30, calendar: calendar))
    }

    func testFireDateIsStrictlyAfterReference() {
        let calendar = makeCalendar()
        // Reference exactly at the alarm time should roll to the next day.
        let reference = date(2026, 6, 17, 9, 30, calendar: calendar)
        let next = AlarmOccurrenceCalculator.nextFireDate(
            hour: 9, minute: 30, weekdays: [], after: reference, calendar: calendar
        )
        XCTAssertEqual(next, date(2026, 6, 18, 9, 30, calendar: calendar))
    }

    // MARK: - Repeating alarms

    func testRepeatingPicksNextMatchingWeekday() {
        let calendar = makeCalendar()
        // Wednesday 2026-06-17 at 10:00; alarm repeats Mon/Fri at 07:00.
        let reference = date(2026, 6, 17, 10, 0, calendar: calendar)
        let next = AlarmOccurrenceCalculator.nextFireDate(
            hour: 7, minute: 0, weekdays: [.monday, .friday], after: reference, calendar: calendar
        )
        // Next Friday is 2026-06-19.
        XCTAssertEqual(next, date(2026, 6, 19, 7, 0, calendar: calendar))
    }

    func testRepeatingFiresTodayWhenTimeNotYetPassed() {
        let calendar = makeCalendar()
        // Wednesday 06:00; alarm repeats Wednesdays at 07:00 -> fires today.
        let reference = date(2026, 6, 17, 6, 0, calendar: calendar)
        let next = AlarmOccurrenceCalculator.nextFireDate(
            hour: 7, minute: 0, weekdays: [.wednesday], after: reference, calendar: calendar
        )
        XCTAssertEqual(next, date(2026, 6, 17, 7, 0, calendar: calendar))
    }

    func testRepeatingRollsToNextWeekWhenTimePassed() {
        let calendar = makeCalendar()
        // Wednesday 08:00; alarm Wednesdays at 07:00 -> next Wednesday.
        let reference = date(2026, 6, 17, 8, 0, calendar: calendar)
        let next = AlarmOccurrenceCalculator.nextFireDate(
            hour: 7, minute: 0, weekdays: [.wednesday], after: reference, calendar: calendar
        )
        XCTAssertEqual(next, date(2026, 6, 24, 7, 0, calendar: calendar))
    }

    // MARK: - Upcoming dates & invalid input

    func testUpcomingFireDatesAreAscendingAndCorrectCount() {
        let calendar = makeCalendar()
        let reference = date(2026, 6, 17, 8, 0, calendar: calendar)
        let dates = AlarmOccurrenceCalculator.upcomingFireDates(
            hour: 7, minute: 0, weekdays: [.monday, .wednesday, .friday],
            after: reference, count: 4, calendar: calendar
        )
        XCTAssertEqual(dates.count, 4)
        XCTAssertEqual(dates, dates.sorted())
        // First should be Friday 06-19, then Mon 06-22, Wed 06-24, Fri 06-26.
        XCTAssertEqual(dates[0], date(2026, 6, 19, 7, 0, calendar: calendar))
        XCTAssertEqual(dates[3], date(2026, 6, 26, 7, 0, calendar: calendar))
    }

    func testInvalidHourReturnsNil() {
        let calendar = makeCalendar()
        let reference = date(2026, 6, 17, 8, 0, calendar: calendar)
        XCTAssertNil(AlarmOccurrenceCalculator.nextFireDate(
            hour: 24, minute: 0, weekdays: [], after: reference, calendar: calendar
        ))
        XCTAssertNil(AlarmOccurrenceCalculator.nextFireDate(
            hour: 6, minute: 60, weekdays: [], after: reference, calendar: calendar
        ))
    }

    // MARK: - DST handling

    func testSpringForwardDSTResolvesToValidTime() {
        // US DST 2026 begins 2026-03-08, when 02:00–02:59 local does not exist.
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/New_York")!
        calendar.locale = Locale(identifier: "en_US_POSIX")

        let reference = date(2026, 3, 8, 0, 0, calendar: calendar)
        let next = AlarmOccurrenceCalculator.nextFireDate(
            hour: 2, minute: 30, weekdays: [], after: reference, calendar: calendar
        )
        // The nonexistent 02:30 must resolve to a real, later instant, not nil.
        XCTAssertNotNil(next)
        XCTAssertGreaterThan(next!, reference)
    }
}
