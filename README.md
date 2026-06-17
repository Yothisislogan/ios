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

## iOS reliability constraints (important)

iOS does **not** let an app run arbitrary code at a scheduled time while
backgrounded or locked. Alarms therefore fire via **local notifications**, and
the app cannot guarantee custom audio/UI at the exact fire instant without
notification delivery. The planned design (later stages) accounts for this:

- Critical-alert entitlement is used where appropriate so the alarm sounds even
  in silent/Do-Not-Disturb modes (requires an Apple entitlement request).
- The reaction challenge is presented when the user **opens the notification or
  the app**; a fallback dismiss path ensures a user is never locked out of
  silencing an alarm.
- Snooze is always reachable in a single tap; only *full dismiss* is gated.

These behaviors are implemented from Stage 3 onward.

## Build status / stages

This codebase is being built incrementally:

1. **✅ Scaffold + data model + persistence** *(current)*
2. ⬜ Alarm list + create/edit UI
3. ⬜ Local notification scheduling + reliable firing
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
