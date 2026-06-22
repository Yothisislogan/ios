import Foundation

/// A single local-notification request the scheduler should register, expressed
/// as plain values so the mapping is pure and unit-testable (no
/// `UserNotifications` dependency).
public struct PlannedNotification: Equatable, Sendable {
    /// Stable identifier, derived from the alarm id (so it can be cancelled).
    public let identifier: String
    /// Calendar components the notification should match.
    public let dateComponents: DateComponents
    /// Whether the trigger repeats (recurring weekday alarms).
    public let repeats: Bool

    public init(identifier: String, dateComponents: DateComponents, repeats: Bool) {
        self.identifier = identifier
        self.dateComponents = dateComponents
        self.repeats = repeats
    }
}

/// Pure mapping from an `Alarm` to the set of local notifications that realize
/// it. Recurring alarms become one repeating notification per selected weekday;
/// one-time alarms become a single non-repeating notification.
///
/// iOS caps an app at 64 pending notifications, so callers should be mindful of
/// the total across all alarms (a recurring alarm costs up to 7 slots).
public enum NotificationRequestPlanner {

    /// Identifier prefix for an alarm; all of an alarm's requests share it, so
    /// they can be cancelled as a group.
    public static func identifierPrefix(for alarmID: UUID) -> String {
        "alarm.\(alarmID.uuidString)."
    }

    public static func plan(for alarm: Alarm) -> [PlannedNotification] {
        guard alarm.isEnabled else { return [] }
        let prefix = identifierPrefix(for: alarm.id)

        if alarm.isOneTime {
            var components = DateComponents()
            components.hour = alarm.hour
            components.minute = alarm.minute
            return [PlannedNotification(
                identifier: prefix + "once",
                dateComponents: components,
                repeats: false
            )]
        }

        return alarm.repeatSchedule.days.sorted().map { day in
            var components = DateComponents()
            components.weekday = day.rawValue
            components.hour = alarm.hour
            components.minute = alarm.minute
            return PlannedNotification(
                identifier: prefix + "wd\(day.rawValue)",
                dateComponents: components,
                repeats: true
            )
        }
    }
}
