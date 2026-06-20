import GameKit
import UIKit

/// Game Center implementation of `LeaderboardService`.
///
/// Authentication is required by GameKit before any score submission or entry
/// loading. If GameKit needs to show Apple's sign-in UI, we present it from the
/// top-most view controller — authentication is only ever triggered by an
/// explicit user opt-in, so the UI is guaranteed to be on screen. Nothing here
/// runs until the user opts in.
@MainActor
@Observable
public final class GameCenterService: LeaderboardService {

    public private(set) var isAuthenticated: Bool = false

    public init() {}

    public func authenticate() async {
        let localPlayer = GKLocalPlayer.local

        if localPlayer.isAuthenticated {
            isAuthenticated = true
            return
        }

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            var didResume = false
            let resumeOnce = {
                if !didResume { didResume = true; continuation.resume() }
            }
            localPlayer.authenticateHandler = { viewController, _ in
                if let viewController {
                    UIApplication.topViewController()?.present(viewController, animated: true)
                    // Keep waiting; the handler fires again once sign-in finishes.
                } else {
                    self.isAuthenticated = localPlayer.isAuthenticated
                    resumeOnce()
                }
            }
        }
    }

    public func submit(streak: Int) async throws {
        guard GKLocalPlayer.local.isAuthenticated else { throw LeaderboardError.notAuthenticated }
        do {
            try await GKLeaderboard.submitScore(
                streak,
                context: 0,
                player: GKLocalPlayer.local,
                leaderboardIDs: [LeaderboardConfig.wakeStreakID]
            )
        } catch {
            throw LeaderboardError.underlying(error.localizedDescription)
        }
    }

    public func loadTopEntries(limit: Int) async throws -> [LeaderboardEntry] {
        guard GKLocalPlayer.local.isAuthenticated else { throw LeaderboardError.notAuthenticated }
        guard limit > 0 else { return [] }

        let board = try await loadBoard()
        do {
            let (_, entries, _) = try await board.loadEntries(
                for: .global,
                timeScope: .allTime,
                range: NSRange(location: 1, length: limit)
            )
            return entries.map { Self.map($0) }
        } catch {
            throw LeaderboardError.underlying(error.localizedDescription)
        }
    }

    public func loadLocalEntry() async throws -> LeaderboardEntry? {
        guard GKLocalPlayer.local.isAuthenticated else { throw LeaderboardError.notAuthenticated }

        let board = try await loadBoard()
        do {
            let (local, _, _) = try await board.loadEntries(
                for: .global,
                timeScope: .allTime,
                range: NSRange(location: 1, length: 1)
            )
            guard let local else { return nil }
            return Self.map(local, forceLocal: true)
        } catch {
            throw LeaderboardError.underlying(error.localizedDescription)
        }
    }

    private func loadBoard() async throws -> GKLeaderboard {
        do {
            let boards = try await GKLeaderboard.loadLeaderboards(IDs: [LeaderboardConfig.wakeStreakID])
            guard let board = boards.first else { throw LeaderboardError.unavailable }
            return board
        } catch let error as LeaderboardError {
            throw error
        } catch {
            throw LeaderboardError.underlying(error.localizedDescription)
        }
    }

    private static func map(_ entry: GKLeaderboard.Entry, forceLocal: Bool = false) -> LeaderboardEntry {
        LeaderboardEntry(
            rank: entry.rank,
            displayName: entry.player.displayName,
            streak: entry.score,
            isLocalPlayer: forceLocal || entry.player == GKLocalPlayer.local
        )
    }
}

extension UIApplication {
    /// The top-most presented view controller in the active foreground scene,
    /// used to present Game Center's sign-in UI.
    static func topViewController() -> UIViewController? {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
        let root = scene?.windows.first(where: \.isKeyWindow)?.rootViewController
        var top = root
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }
}
