//  AlarmKitAlarmScheduler.swift
//
//  iOS 26+ AlarmKit backend for `AlarmScheduling`. Provides *true* system
//  alarms that break through silent mode and Focus.
//
//  ⚠️ VERIFY BEFORE ENABLING. This file is written against the iOS 26 AlarmKit
//  API from documentation, not compiled here. It is gated behind BOTH
//  `canImport(AlarmKit)` and the `RISE_ENABLE_ALARMKIT` compilation flag (off by
//  default — see project.yml) so the default build uses the notification
//  backend. To adopt AlarmKit: add `RISE_ENABLE_ALARMKIT` to
//  SWIFT_ACTIVE_COMPILATION_CONDITIONS, build on Xcode 26, and reconcile any API
//  differences flagged in the comments below.
//
//  Note on naming: AlarmKit defines its own `Alarm` type, which collides with
//  this app's `Alarm` model. AlarmKit's type is referenced as `AlarmKit.Alarm`
//  and ours as `RiseAndShine.Alarm` throughout.

#if canImport(AlarmKit) && RISE_ENABLE_ALARMKIT
import AlarmKit
import AppIntents
import Foundation
import SwiftUI

@available(iOS 26.0, *)
@MainActor
public final class AlarmKitAlarmScheduler: AlarmScheduling {

    private let manager = AlarmManager.shared

    public init() {}

    // MARK: - Authorization

    public func currentAuthorization() async -> AlarmAuthorizationStatus {
        map(manager.authorizationState)
    }

    @discardableResult
    public func requestAuthorization() async -> AlarmAuthorizationStatus {
        do { return map(try await manager.requestAuthorization()) }
        catch { return .denied }
    }

    // MARK: - Scheduling

    public func schedule(_ alarm: RiseAndShine.Alarm) async throws {
        // `schedule` is upsert-like: cancel any existing then (re)add if enabled.
        try await cancel(alarmID: alarm.id)
        guard alarm.isEnabled else { return }

        let configuration = makeConfiguration(for: alarm)
        do {
            _ = try await manager.schedule(id: alarm.id, configuration: configuration)
        } catch {
            throw AlarmSchedulingError.underlying(error.localizedDescription)
        }
    }

    public func cancel(alarmID: UUID) async throws {
        // `cancel(id:)` is documented as synchronous throwing; not-scheduled is
        // not an error condition we want to propagate.
        try? manager.cancel(id: alarmID)
    }

    public func cancelAll() async throws {
        // AlarmKit exposes no bulk cancel. Callers should prefer `syncAll`
        // (which reconciles each known alarm) and `cancel(alarmID:)` on deletion.
    }

    public func syncAll(_ alarms: [RiseAndShine.Alarm]) async throws {
        // `schedule` already cancels-then-(re)adds per alarm, so reconciling the
        // provided set is sufficient. Deletions are handled via `cancel(alarmID:)`.
        for alarm in alarms {
            try await schedule(alarm)
        }
    }

    // MARK: - Mapping

    private func makeConfiguration(for alarm: RiseAndShine.Alarm) -> AlarmManager.AlarmConfiguration<RiseAlarmMetadata> {
        AlarmManager.AlarmConfiguration(
            countdownDuration: countdownDuration(for: alarm),
            schedule: makeSchedule(for: alarm),
            attributes: makeAttributes(for: alarm)
            // TODO (Stage 4 — reaction gate): replace the default stop behavior
            // with an open-app App Intent so dismiss routes through the reaction
            // challenge, via `secondaryIntent`/a custom button.
        )
    }

    private func countdownDuration(for alarm: RiseAndShine.Alarm) -> AlarmKit.Alarm.CountdownDuration? {
        guard alarm.snoozeEnabled else { return nil }
        // `postAlert` is the snooze interval applied after the alarm fires.
        return AlarmKit.Alarm.CountdownDuration(
            preAlert: nil,
            postAlert: TimeInterval(alarm.snoozeMinutes * 60)
        )
    }

    private func makeSchedule(for alarm: RiseAndShine.Alarm) -> AlarmKit.Alarm.Schedule {
        if alarm.isOneTime {
            let fireDate = alarm.nextFireDate() ?? Date().addingTimeInterval(60)
            return .fixed(fireDate)
        }
        let time = AlarmKit.Alarm.Schedule.Relative.Time(hour: alarm.hour, minute: alarm.minute)
        let weekdays = alarm.repeatSchedule.days.sorted().map(localeWeekday(from:))
        return .relative(.init(time: time, repeats: .weekly(weekdays)))
    }

    private func makeAttributes(for alarm: RiseAndShine.Alarm) -> AlarmAttributes<RiseAlarmMetadata> {
        let stop = AlarmButton(
            text: LocalizedStringResource(stringLiteral: L10n.AlarmEngine.stopButton),
            textColor: .white,
            systemImageName: "stop.fill"
        )
        let snooze = AlarmButton(
            text: LocalizedStringResource(stringLiteral: L10n.AlarmEngine.snoozeButton),
            textColor: .white,
            systemImageName: "zzz"
        )
        let title = alarm.label.isEmpty ? L10n.AlarmEngine.defaultAlarmTitle : alarm.label
        let alert = AlarmPresentation.Alert(
            title: LocalizedStringResource(stringLiteral: title),
            stopButton: stop,
            secondaryButton: alarm.snoozeEnabled ? snooze : nil,
            secondaryButtonBehavior: alarm.snoozeEnabled ? .countdown : nil
        )
        return AlarmAttributes(
            presentation: AlarmPresentation(alert: alert),
            metadata: RiseAlarmMetadata(alarmID: alarm.id.uuidString),
            tintColor: Brand.primary
        )
    }

    private func map(_ state: AlarmManager.AuthorizationState) -> AlarmAuthorizationStatus {
        switch state {
        case .authorized: return .authorized
        case .denied: return .denied
        case .notDetermined: return .notDetermined
        @unknown default: return .denied
        }
    }

    private func localeWeekday(from day: Weekday) -> Locale.Weekday {
        switch day {
        case .sunday: return .sunday
        case .monday: return .monday
        case .tuesday: return .tuesday
        case .wednesday: return .wednesday
        case .thursday: return .thursday
        case .friday: return .friday
        case .saturday: return .saturday
        }
    }
}
#endif
