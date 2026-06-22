//  AlarmIntents.swift
//
//  AlarmKit metadata + App Intents backing the alarm's Live Activity buttons.
//  Gated identically to AlarmKitAlarmScheduler (see that file's header).
//
//  ⚠️ VERIFY BEFORE ENABLING — written against the iOS 26 SDK, not compiled here.

#if canImport(AlarmKit) && RISE_ENABLE_ALARMKIT
import AlarmKit
import AppIntents
import Foundation

/// App-specific data carried alongside a scheduled AlarmKit alarm, available to
/// the Live Activity / widget UI and to the dismiss flow.
@available(iOS 26.0, *)
public struct RiseAlarmMetadata: AlarmMetadata {
    public let alarmID: String

    public init(alarmID: String) {
        self.alarmID = alarmID
    }
}

/// Stops a ringing alarm from its Live Activity stop button.
///
/// In Stage 4 this is where the reaction-gate hand-off lives: instead of
/// stopping immediately, open the app to present the reaction challenge and only
/// call `stop` once the user passes.
@available(iOS 26.0, *)
public struct StopAlarmIntent: LiveActivityIntent {
    public static var title: LocalizedStringResource = "Stop Alarm"

    @Parameter(title: "Alarm ID")
    public var alarmID: String

    public init() {}
    public init(alarmID: String) { self.alarmID = alarmID }

    public func perform() async throws -> some IntentResult {
        if let id = UUID(uuidString: alarmID) {
            try AlarmManager.shared.stop(id: id)
        }
        return .result()
    }
}

/// Snoozes (starts the post-alert countdown) for a ringing alarm.
@available(iOS 26.0, *)
public struct SnoozeAlarmIntent: LiveActivityIntent {
    public static var title: LocalizedStringResource = "Snooze Alarm"

    @Parameter(title: "Alarm ID")
    public var alarmID: String

    public init() {}
    public init(alarmID: String) { self.alarmID = alarmID }

    public func perform() async throws -> some IntentResult {
        if let id = UUID(uuidString: alarmID) {
            try AlarmManager.shared.countdown(id: id)
        }
        return .result()
    }
}
#endif
