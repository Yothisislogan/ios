import Foundation

/// Game Center configuration constants.
///
/// The leaderboard with this ID must be created in **App Store Connect**
/// (Features → Game Center → Leaderboards) as a *Classic* leaderboard with
/// "High to Low" sort (a higher streak ranks better) and integer formatting.
public enum LeaderboardConfig {
    /// Leaderboard identifier shared with App Store Connect.
    public static let wakeStreakID = "com.weinsurethings.RiseAndShine.wakeStreak"
}

/// One row of a leaderboard.
public struct LeaderboardEntry: Identifiable, Equatable, Sendable {
    public var id: String { "\(rank)-\(displayName)" }
    public let rank: Int
    public let displayName: String
    public let streak: Int
    public let isLocalPlayer: Bool

    public init(rank: Int, displayName: String, streak: Int, isLocalPlayer: Bool) {
        self.rank = rank
        self.displayName = displayName
        self.streak = streak
        self.isLocalPlayer = isLocalPlayer
    }
}

/// Errors surfaced to the UI from a leaderboard backend.
public enum LeaderboardError: LocalizedError, Equatable {
    case notAuthenticated
    case unavailable
    case underlying(String)

    public var errorDescription: String? {
        switch self {
        case .notAuthenticated: return L10n.Leaderboard.errorNotAuthenticated
        case .unavailable: return L10n.Leaderboard.errorUnavailable
        case .underlying(let message): return message
        }
    }
}

/// Abstraction over the leaderboard backend so the UI is testable and the
/// concrete provider (Game Center) is swappable. All methods are no-ops or
/// throw `.notAuthenticated` until the player has opted in and authenticated.
@MainActor
public protocol LeaderboardService: AnyObject {
    var isAuthenticated: Bool { get }

    /// Begins authentication. Implementations should be safe to call repeatedly.
    func authenticate() async

    /// Submits the player's current wake-up streak.
    func submit(streak: Int) async throws

    /// Loads the top `limit` global entries (all-time).
    func loadTopEntries(limit: Int) async throws -> [LeaderboardEntry]

    /// Loads the local player's own entry, if ranked.
    func loadLocalEntry() async throws -> LeaderboardEntry?
}
