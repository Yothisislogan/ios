import Foundation
import SwiftData

/// App-wide user preferences and defaults.
///
/// Modeled as a single persisted record (see `PersistenceController.loadSettings`),
/// which keeps preferences queryable alongside the rest of the SwiftData store
/// and ready for future per-profile expansion.
@Model
public final class AppSettings {
    // Defaults applied to newly created alarms
    public var defaultSnoozeMinutes: Int
    public var defaultSoundId: String
    public var defaultReactionDifficultyRaw: String

    // Display / formatting
    public var uses24HourFormat: Bool
    public var hapticsEnabled: Bool
    public var themeRaw: String
    public var accentColorRaw: String

    // Bedtime / sleep schedule (minutes-from-midnight, time-zone independent)
    public var bedtimeReminderEnabled: Bool
    public var targetBedtimeMinutes: Int
    public var targetWakeMinutes: Int
    public var bedtimeReminderLeadMinutes: Int

    /// Opt-in to the global Game Center wake-up-streak leaderboard. Off by
    /// default: no Game Center authentication or score submission happens until
    /// the user explicitly enables this.
    public var leaderboardOptIn: Bool

    public init(
        defaultSnoozeMinutes: Int = 9,
        defaultSoundId: String = AlarmSoundCatalog.defaultSoundId,
        defaultReactionDifficulty: ReactionDifficulty = .medium,
        uses24HourFormat: Bool = false,
        hapticsEnabled: Bool = true,
        theme: AppTheme = .system,
        accentColor: AppAccentColor = .witBlue,
        bedtimeReminderEnabled: Bool = false,
        targetBedtimeMinutes: Int = 23 * 60,   // 11:00 PM
        targetWakeMinutes: Int = 7 * 60,        // 7:00 AM
        bedtimeReminderLeadMinutes: Int = 30,
        leaderboardOptIn: Bool = false
    ) {
        self.defaultSnoozeMinutes = defaultSnoozeMinutes
        self.defaultSoundId = defaultSoundId
        self.defaultReactionDifficultyRaw = defaultReactionDifficulty.rawValue
        self.uses24HourFormat = uses24HourFormat
        self.hapticsEnabled = hapticsEnabled
        self.themeRaw = theme.rawValue
        self.accentColorRaw = accentColor.rawValue
        self.bedtimeReminderEnabled = bedtimeReminderEnabled
        self.targetBedtimeMinutes = targetBedtimeMinutes
        self.targetWakeMinutes = targetWakeMinutes
        self.bedtimeReminderLeadMinutes = bedtimeReminderLeadMinutes
        self.leaderboardOptIn = leaderboardOptIn
    }
}

public extension AppSettings {
    var defaultReactionDifficulty: ReactionDifficulty {
        get { ReactionDifficulty(rawValue: defaultReactionDifficultyRaw) ?? .medium }
        set { defaultReactionDifficultyRaw = newValue.rawValue }
    }

    var theme: AppTheme {
        get { AppTheme(rawValue: themeRaw) ?? .system }
        set { themeRaw = newValue.rawValue }
    }

    var accentColor: AppAccentColor {
        get { AppAccentColor(rawValue: accentColorRaw) ?? .witBlue }
        set { accentColorRaw = newValue.rawValue }
    }
}
