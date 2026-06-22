import XCTest
@testable import RiseAndShine

final class NotificationRequestPlannerTests: XCTestCase {

    func testDisabledAlarmPlansNothing() {
        let alarm = Alarm(hour: 7, minute: 0, isEnabled: false)
        XCTAssertTrue(NotificationRequestPlanner.plan(for: alarm).isEmpty)
    }

    func testOneTimeAlarmPlansSingleNonRepeatingRequest() {
        let alarm = Alarm(hour: 6, minute: 45, isEnabled: true, repeatDaysMask: 0)
        let plan = NotificationRequestPlanner.plan(for: alarm)

        XCTAssertEqual(plan.count, 1)
        let request = plan[0]
        XCTAssertFalse(request.repeats)
        XCTAssertEqual(request.dateComponents.hour, 6)
        XCTAssertEqual(request.dateComponents.minute, 45)
        XCTAssertNil(request.dateComponents.weekday)
        XCTAssertTrue(request.identifier.hasPrefix(NotificationRequestPlanner.identifierPrefix(for: alarm.id)))
        XCTAssertTrue(request.identifier.hasSuffix("once"))
    }

    func testRecurringAlarmPlansOneRepeatingRequestPerWeekday() {
        var alarm = Alarm(hour: 8, minute: 15, isEnabled: true)
        alarm.repeatSchedule = RepeatSchedule(days: [.monday, .wednesday, .friday])

        let plan = NotificationRequestPlanner.plan(for: alarm)
        XCTAssertEqual(plan.count, 3)

        // All repeating, all carrying the right time.
        XCTAssertTrue(plan.allSatisfy(\.repeats))
        XCTAssertTrue(plan.allSatisfy { $0.dateComponents.hour == 8 && $0.dateComponents.minute == 15 })

        // Weekdays match Monday(2)/Wednesday(4)/Friday(6), and are unique ids.
        let weekdays = Set(plan.compactMap { $0.dateComponents.weekday })
        XCTAssertEqual(weekdays, [Weekday.monday.rawValue, Weekday.wednesday.rawValue, Weekday.friday.rawValue])
        XCTAssertEqual(Set(plan.map(\.identifier)).count, 3)
    }

    func testIdentifiersAreScopedToAlarmForCancellation() {
        let alarm = Alarm(hour: 9, minute: 0, isEnabled: true)
        let prefix = NotificationRequestPlanner.identifierPrefix(for: alarm.id)
        XCTAssertTrue(NotificationRequestPlanner.plan(for: alarm).allSatisfy { $0.identifier.hasPrefix(prefix) })
    }
}
