import Foundation
import SwiftData

/// A scheduled alarm.
///
/// Persistence notes:
/// - The fire time is stored as `hour`/`minute` *components*, never an absolute
///   `Date`. Concrete fire dates are derived on demand via
///   `AlarmOccurrenceCalculator`, so the alarm behaves correctly across
///   time-zone changes and DST transitions.
/// - Enum-valued settings are stored as their raw `String`/`Int` values for
///   SwiftData robustness, with typed computed accessors layered on top.
@Model
public final class Alarm {
    /// Stable identifier used for notification request ids and widget lookups.
    @Attribute(.unique) public var id: UUID

    public var label: String
    public var hour: Int
    public var minute: Int
    public var isEnabled: Bool

    /// Bitmask of repeat weekdays (0 == one-time). See `RepeatSchedule`.
    public var repeatDaysMask: Int

    // Sound & feedback
    public var soundId: String
    public var volume: Double
    public var gradualVolumeEnabled: Bool
    public var vibrationEnabled: Bool
    public var vibrationPatternId: String

    // Snooze
    public var snoozeEnabled: Bool
    public var snoozeMinutes: Int
    public var maxSnoozeCount: Int
    public var escalateSnoozeDifficulty: Bool

    // Dismiss challenge / reaction gate
    public var dismissChallengeRaw: String
    public var reactionGateEnabled: Bool
    public var reactionDifficultyRaw: String

    // Smart wake window
    public var smartWakeEnabled: Bool
    public var smartWakeWindowMinutes: Int

    // Bookkeeping
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        label: String = "",
        hour: Int,
        minute: Int,
        isEnabled: Bool = true,
        repeatDaysMask: Int = 0,
        soundId: String = AlarmSoundCatalog.defaultSoundId,
        volume: Double = 0.8,
        gradualVolumeEnabled: Bool = false,
        vibrationEnabled: Bool = true,
        vibrationPatternId: String = "standard",
        snoozeEnabled: Bool = true,
        snoozeMinutes: Int = 9,
        maxSnoozeCount: Int = 3,
        escalateSnoozeDifficulty: Bool = false,
        dismissChallenge: DismissChallengeKind = .reaction,
        reactionGateEnabled: Bool = true,
        reactionDifficulty: ReactionDifficulty = .medium,
        smartWakeEnabled: Bool = false,
        smartWakeWindowMinutes: Int = 15,
        createdAt: Date = .now
    ) {
        self.id = id
        self.label = label
        self.hour = hour
        self.minute = minute
        self.isEnabled = isEnabled
        self.repeatDaysMask = repeatDaysMask
        self.soundId = soundId
        self.volume = volume
        self.gradualVolumeEnabled = gradualVolumeEnabled
        self.vibrationEnabled = vibrationEnabled
        self.vibrationPatternId = vibrationPatternId
        self.snoozeEnabled = snoozeEnabled
        self.snoozeMinutes = snoozeMinutes
        self.maxSnoozeCount = maxSnoozeCount
        self.escalateSnoozeDifficulty = escalateSnoozeDifficulty
        self.dismissChallengeRaw = dismissChallenge.rawValue
        self.reactionGateEnabled = reactionGateEnabled
        self.reactionDifficultyRaw = reactionDifficulty.rawValue
        self.smartWakeEnabled = smartWakeEnabled
        self.smartWakeWindowMinutes = smartWakeWindowMinutes
        self.createdAt = createdAt
        self.updatedAt = createdAt
    }
}

// MARK: - Typed accessors

public extension Alarm {
    var repeatSchedule: RepeatSchedule {
        get { RepeatSchedule(mask: repeatDaysMask) }
        set { repeatDaysMask = newValue.mask }
    }

    var dismissChallenge: DismissChallengeKind {
        get { DismissChallengeKind(rawValue: dismissChallengeRaw) ?? .none }
        set { dismissChallengeRaw = newValue.rawValue }
    }

    var reactionDifficulty: ReactionDifficulty {
        get { ReactionDifficulty(rawValue: reactionDifficultyRaw) ?? .medium }
        set { reactionDifficultyRaw = newValue.rawValue }
    }

    var sound: AlarmSound {
        AlarmSoundCatalog.sound(forId: soundId) ?? AlarmSoundCatalog.radar
    }

    /// `true` when this alarm fires only once (no repeat days).
    var isOneTime: Bool { repeatDaysMask == 0 }
}

// MARK: - Derived scheduling

public extension Alarm {
    /// Next time this alarm should fire after `reference`, or `nil` if disabled.
    func nextFireDate(after reference: Date = .now, calendar: Calendar = .current) -> Date? {
        guard isEnabled else { return nil }
        return AlarmOccurrenceCalculator.nextFireDate(
            hour: hour,
            minute: minute,
            weekdays: repeatSchedule.days,
            after: reference,
            calendar: calendar
        )
    }

    /// Localized "h:mm a" / "HH:mm" time string honoring the user's settings.
    func timeString(use24Hour: Bool, locale: Locale = .current) -> String {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        let calendar = Calendar.current
        let date = calendar.date(from: components) ?? .now
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.setLocalizedDateFormatFromTemplate(use24Hour ? "Hmm" : "hmma")
        return formatter.string(from: date)
    }
}
