# Rise & Shine

A native iOS alarm clock whose signature feature is a **reaction-time
wake-verification challenge**: to fully dismiss an alarm you must prove you're
awake by passing a timed tap test. Reliability of alarm firing is the project's
top priority.

- **Platform:** iOS 17+, Swift 6, SwiftUI
- **Architecture:** MVVM with `@Observable` view models; domain logic (alarm
  scheduling, reaction scoring) is kept free of UI and SwiftData so it is
  unit-testable in isolation.
- **Persistence:** SwiftData
- **Dependencies:** none at runtime. [XcodeGen](https://github.com/yonaskolb/XcodeGen)
  is used only as a build-time tool to generate the Xcode project.

## Getting started

The Xcode project is generated from `project.yml` (it is not committed — see
`.gitignore`). On a Mac with Xcode 16+:

```sh
brew install xcodegen   # one-time
xcodegen generate       # creates RiseAndShine.xcodeproj
open RiseAndShine.xcodeproj
```

Set your signing team in Xcode (Target → Signing & Capabilities) before running
on a device. Then build & run the `RiseAndShine` scheme, or run tests with
`Cmd-U` (or `xcodebuild test -scheme RiseAndShine -destination 'platform=iOS Simulator,name=iPhone 15'`).

## Project layout

```
RiseAndShine/
  App/          App entry point and the root tab shell
  Domain/
    Models/     SwiftData @Model types (Alarm, ReactionAttempt, AppSettings)
    Values/     Codable value types & enums (Weekday, RepeatSchedule, …)
    Scheduling/ AlarmOccurrenceCalculator — pure next-fire-date logic
    Reaction/   ReactionScorer — pure reaction-test scoring logic
  Persistence/  SwiftData ModelContainer factory
  Support/      Centralized user-facing strings (L10n)
  Resources/    Asset catalog
RiseAndShineTests/   Unit tests for the pure domain logic
```

## Design decisions

- **Alarms store hour/minute + a weekday bitmask, not absolute `Date`s.**
  Concrete fire times are derived on demand with `Calendar`, so alarms behave
  correctly across time-zone changes and DST transitions.
- **Enum settings persist as raw `String`/`Int`** with typed computed accessors,
  which is the most robust SwiftData mapping.
- **Pure domain logic is isolated from SwiftData/SwiftUI** so the scheduling and
  scoring rules are fully covered by fast unit tests.

## Alarm firing: hybrid AlarmKit + notifications

iOS does **not** let an app run arbitrary code at a scheduled time while
backgrounded or locked. The app schedules through a single `AlarmScheduling`
abstraction with two interchangeable backends, chosen at runtime by
`AlarmSchedulerFactory`:

- **AlarmKit** (`AlarmKitAlarmScheduler`, iOS 26+) — true system alarms that
  **break through silent mode and Focus** and present a system alerting UI on
  the Lock Screen / Dynamic Island, with stop/snooze buttons wired to App
  Intents. Requires the `NSAlarmKitUsageDescription` Info.plist key and one-time
  `requestAuthorization()`.
- **Local notifications** (`NotificationAlarmScheduler`, iOS 17+) — the fallback
  below iOS 26. Cannot break through the ringer switch; uses a time-sensitive
  interruption level (the free `usernotifications.time-sensitive` entitlement),
  and can sound in silent mode only with the approval-gated critical-alert
  entitlement.

The pure `NotificationRequestPlanner` (Alarm → notification requests) is
unit-tested; the system-touching backends are thin wrappers around it / AlarmKit.

> **Enabling AlarmKit:** the AlarmKit files are gated behind
> `canImport(AlarmKit) && RISE_ENABLE_ALARMKIT` and the flag is **off by
> default**, so the default build uses notifications. They were authored against
> the iOS 26 SDK but **not compiled here** — add `RISE_ENABLE_ALARMKIT` to
> `SWIFT_ACTIVE_COMPILATION_CONDITIONS`, build on Xcode 26, and reconcile any API
> differences before shipping the AlarmKit path.

Regardless of backend: the reaction challenge appears when the user opens the
app from the alarm, a fallback path ensures no one is locked out of silencing an
alarm, and snooze is always reachable in one tap (only *full dismiss* is gated).
The reaction-gate hand-off is wired in Stage 4.

## Build status / stages

This codebase is being built incrementally:

1. **✅ Scaffold + data model + persistence** *(current)*
2. ⬜ Alarm list + create/edit UI
3. 🟡 Reliable firing — `AlarmScheduling` abstraction + notification backend +
   AlarmKit backend (behind a flag) landed; app-launch sync + permission UX pending
4. ⬜ Reaction-timer challenge as the dismiss gate
5. ⬜ Standalone Reaction Trainer + history
6. ⬜ Bedtime/sleep schedule + statistics
7. ⬜ Widgets + Live Activity
8. ⬜ Remaining QOL features + polish + accessibility

## Verifying on a Mac

This stage was authored in a Linux environment without Xcode, so it has **not**
been compiled here. After `xcodegen generate`, confirm:

1. The project opens and the `RiseAndShine` scheme builds.
2. The app launches to a four-tab shell; the Alarms tab reports the stored
   alarm count (proving the SwiftData container is wired up).
3. `Cmd-U` runs the unit tests in `RiseAndShineTests` and they pass.
