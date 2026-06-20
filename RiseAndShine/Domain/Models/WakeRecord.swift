import Foundation
import SwiftData

/// A per-day record of how the user's first alarm of the day went.
///
/// This is the data source for the **wake-up streak** (consecutive days the
/// first alarm was dismissed without snoozing), which feeds both the local
/// stats dashboard and the opt-in Game Center leaderboard.
///
/// One record represents one calendar day (the first alarm of that day). The
/// recording logic that creates these is wired up alongside the dismiss flow in
/// a later stage; the model and the streak math live here now.
@Model
public final class WakeRecord {
    @Attribute(.unique) public var id: UUID

    /// Start of the calendar day (in the user's calendar) this record covers.
    /// Stored normalized to midnight so days compare cleanly.
    public var dayStart: Date

    /// `true` if the first alarm was dismissed without any snooze.
    public var wokeWithoutSnooze: Bool

    /// How many times the user snoozed before finally dismissing.
    public var snoozeCount: Int

    /// Best reaction time (ms) recorded while dismissing, if a reaction gate
    /// was used. `nil` when no reaction challenge was involved.
    public var dismissReactionMs: Double?

    /// The alarm responsible for this wake, if known.
    public var alarmId: UUID?

    public init(
        id: UUID = UUID(),
        dayStart: Date,
        wokeWithoutSnooze: Bool,
        snoozeCount: Int = 0,
        dismissReactionMs: Double? = nil,
        alarmId: UUID? = nil
    ) {
        self.id = id
        self.dayStart = dayStart
        self.wokeWithoutSnooze = wokeWithoutSnooze
        self.snoozeCount = snoozeCount
        self.dismissReactionMs = dismissReactionMs
        self.alarmId = alarmId
    }
}
