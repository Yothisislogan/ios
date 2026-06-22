import Foundation

/// Selects the best available alarm backend at runtime.
///
/// Uses AlarmKit (true system alarms) when the framework is present, the
/// `RISE_ENABLE_ALARMKIT` build flag is set, and the OS is iOS 26+. Otherwise
/// falls back to local notifications, which work from iOS 17.
@MainActor
public enum AlarmSchedulerFactory {
    public static func make(useCriticalAlerts: Bool = false) -> any AlarmScheduling {
        #if canImport(AlarmKit) && RISE_ENABLE_ALARMKIT
        if #available(iOS 26.0, *) {
            return AlarmKitAlarmScheduler()
        }
        #endif
        return NotificationAlarmScheduler(useCriticalAlerts: useCriticalAlerts)
    }

    /// Whether the AlarmKit backend is compiled in and selectable on this OS.
    /// Useful for surfacing "true alarm" vs "notification fallback" in the UI.
    public static var isAlarmKitActive: Bool {
        #if canImport(AlarmKit) && RISE_ENABLE_ALARMKIT
        if #available(iOS 26.0, *) { return true }
        #endif
        return false
    }
}
