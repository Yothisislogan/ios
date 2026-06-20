import Foundation

/// In-memory `LeaderboardService` for SwiftUI previews and unit tests.
/// Never touches Game Center.
@MainActor
@Observable
public final class MockLeaderboardService: LeaderboardService {
    public private(set) var isAuthenticated: Bool
    public private(set) var lastSubmittedStreak: Int?
    private var entries: [LeaderboardEntry]

    public init(
        isAuthenticated: Bool = true,
        entries: [LeaderboardEntry] = MockLeaderboardService.sampleEntries
    ) {
        self.isAuthenticated = isAuthenticated
        self.entries = entries
    }

    public func authenticate() async { isAuthenticated = true }

    public func submit(streak: Int) async throws {
        guard isAuthenticated else { throw LeaderboardError.notAuthenticated }
        lastSubmittedStreak = streak
    }

    public func loadTopEntries(limit: Int) async throws -> [LeaderboardEntry] {
        guard isAuthenticated else { throw LeaderboardError.notAuthenticated }
        return Array(entries.prefix(limit))
    }

    public func loadLocalEntry() async throws -> LeaderboardEntry? {
        guard isAuthenticated else { throw LeaderboardError.notAuthenticated }
        return entries.first(where: \.isLocalPlayer)
    }

    public static let sampleEntries: [LeaderboardEntry] = [
        LeaderboardEntry(rank: 1, displayName: "EarlyBird", streak: 142, isLocalPlayer: false),
        LeaderboardEntry(rank: 2, displayName: "DawnPatrol", streak: 98, isLocalPlayer: false),
        LeaderboardEntry(rank: 3, displayName: "You", streak: 31, isLocalPlayer: true),
        LeaderboardEntry(rank: 4, displayName: "Snoozer99", streak: 12, isLocalPlayer: false),
    ]
}
