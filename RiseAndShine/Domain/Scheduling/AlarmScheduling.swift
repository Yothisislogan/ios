import Foundation

/// Authorization state for whichever alarm backend is active, abstracted over
/// `UNAuthorizationStatus` (notifications) and AlarmKit's authorization state.
public enum AlarmAuthorizationStatus: Sendable, Equatable {
    case notDetermined
    case authorized
    case denied
}

/// Errors the scheduling layer can surface to the UI.
public enum AlarmSchedulingError: LocalizedError, Equatable {
    case notAuthorized
    case backendUnavailable
    case underlying(String)

    public var errorDescription: String? {
        switch self {
        case .notAuthorized: return L10n.AlarmEngine.errorNotAuthorized
        case .backendUnavailable: return L10n.AlarmEngine.errorUnavailable
        case .underlying(let message): return message
        }
    }
}

/// The single abstraction the app schedules alarms through, so the firing
/// backend is swappable and the rest of the app never imports AlarmKit or
/// UserNotifications directly.
///
/// Two implementations exist:
/// - `AlarmKitAlarmScheduler` (iOS 26+): true system alarms that break through
///   silent mode and Focus.
/// - `NotificationAlarmScheduler` (iOS 17+): local-notification fallback.
///
/// `makeAlarmScheduler()` picks the best available backend at runtime.
///
/// `@MainActor` because both backends ultimately touch main-actor system
/// singletons; callers are view models on the main actor anyway.
@MainActor
public protocol AlarmScheduling {
    /// The current authorization state without prompting.
    func currentAuthorization() async -> AlarmAuthorizationStatus

    /// Prompts for authorization if undetermined; returns the resulting state.
    @discardableResult
    func requestAuthorization() async -> AlarmAuthorizationStatus

    /// Schedules (or reschedules) a single enabled alarm. Disabled alarms are
    /// cancelled instead.
    func schedule(_ alarm: Alarm) async throws

    /// Cancels every pending firing for the given alarm id.
    func cancel(alarmID: UUID) async throws

    /// Cancels all pending alarms owned by this app.
    func cancelAll() async throws

    /// Reconciles the scheduled set with `alarms` (enabled ones scheduled,
    /// everything else cleared). Call after bulk changes or app launch.
    func syncAll(_ alarms: [Alarm]) async throws
}
