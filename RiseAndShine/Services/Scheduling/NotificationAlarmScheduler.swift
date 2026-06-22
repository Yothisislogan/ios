import Foundation
import UserNotifications

/// `AlarmScheduling` backed by local notifications. Works on iOS 17+ and is the
/// fallback when AlarmKit (iOS 26+) is unavailable.
///
/// Limitation worth remembering: local notifications **cannot** break through
/// the ringer switch / silent mode the way a true alarm can. Requesting the
/// critical-alert entitlement (see entitlements file) lets sound play in those
/// modes, but that entitlement requires Apple approval. Without it we use a
/// time-sensitive interruption level, which is the best a notification can do.
@MainActor
public final class NotificationAlarmScheduler: AlarmScheduling {

    private let center: UNUserNotificationCenter
    private let categoryIdentifier = "RISE_ALARM"

    /// Whether to attempt critical alerts (requires the entitlement to actually
    /// sound in silent mode; harmless to request without it).
    private let useCriticalAlerts: Bool

    public init(
        center: UNUserNotificationCenter = .current(),
        useCriticalAlerts: Bool = false
    ) {
        self.center = center
        self.useCriticalAlerts = useCriticalAlerts
    }

    // MARK: - Authorization

    public func currentAuthorization() async -> AlarmAuthorizationStatus {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined: return .notDetermined
        case .denied: return .denied
        case .authorized, .provisional, .ephemeral: return .authorized
        @unknown default: return .denied
        }
    }

    @discardableResult
    public func requestAuthorization() async -> AlarmAuthorizationStatus {
        var options: UNAuthorizationOptions = [.alert, .sound, .badge]
        if useCriticalAlerts { options.insert(.criticalAlert) }
        do {
            let granted = try await center.requestAuthorization(options: options)
            return granted ? .authorized : .denied
        } catch {
            return .denied
        }
    }

    // MARK: - Scheduling

    public func schedule(_ alarm: Alarm) async throws {
        try await cancel(alarmID: alarm.id)
        guard alarm.isEnabled else { return }

        for planned in NotificationRequestPlanner.plan(for: alarm) {
            let content = makeContent(for: alarm)
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: planned.dateComponents,
                repeats: planned.repeats
            )
            let request = UNNotificationRequest(
                identifier: planned.identifier,
                content: content,
                trigger: trigger
            )
            do {
                try await center.add(request)
            } catch {
                throw AlarmSchedulingError.underlying(error.localizedDescription)
            }
        }
    }

    public func cancel(alarmID: UUID) async throws {
        let prefix = NotificationRequestPlanner.identifierPrefix(for: alarmID)
        let pending = await center.pendingNotificationRequests()
        let ids = pending.map(\.identifier).filter { $0.hasPrefix(prefix) }
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }

    public func cancelAll() async throws {
        center.removeAllPendingNotificationRequests()
    }

    public func syncAll(_ alarms: [Alarm]) async throws {
        try await cancelAll()
        for alarm in alarms where alarm.isEnabled {
            try await schedule(alarm)
        }
    }

    // MARK: - Helpers

    private func makeContent(for alarm: Alarm) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = alarm.label.isEmpty ? L10n.AlarmEngine.defaultAlarmTitle : alarm.label
        content.body = L10n.AlarmEngine.notificationBody
        content.categoryIdentifier = categoryIdentifier
        content.interruptionLevel = useCriticalAlerts ? .critical : .timeSensitive
        content.sound = makeSound(for: alarm)
        // Carry the alarm id so the app can route to the right dismiss flow.
        content.userInfo = ["alarmID": alarm.id.uuidString]
        return content
    }

    private func makeSound(for alarm: Alarm) -> UNNotificationSound {
        let fileName = alarm.sound.fileName
        if useCriticalAlerts, let fileName {
            return .criticalSoundNamed(UNNotificationSoundName(fileName), withAudioVolume: Float(alarm.volume))
        }
        if let fileName {
            return UNNotificationSound(named: UNNotificationSoundName(fileName))
        }
        return useCriticalAlerts ? .defaultCritical : .default
    }
}
