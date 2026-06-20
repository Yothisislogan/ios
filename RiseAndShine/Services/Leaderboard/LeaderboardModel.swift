import Foundation
import Observation

/// Observable coordinator the UI binds to. Holds leaderboard state and enforces
/// the opt-in gate, delegating I/O to an injected `LeaderboardService`.
///
/// The model never authenticates or submits unless `optedIn` is `true`, so the
/// opt-in toggle in Settings is the single switch controlling all Game Center
/// activity.
@MainActor
@Observable
public final class LeaderboardModel {
    public enum Status: Equatable {
        case optedOut
        case connecting
        case ready
        case failed(String)
    }

    private let service: any LeaderboardService

    public private(set) var status: Status = .optedOut
    public private(set) var topEntries: [LeaderboardEntry] = []
    public private(set) var localEntry: LeaderboardEntry?

    /// Mirrors the persisted opt-in preference; set by the host from settings.
    public private(set) var optedIn: Bool = false

    public init(service: any LeaderboardService) {
        self.service = service
    }

    /// Exposes the underlying service (e.g. to present Game Center sign-in UI).
    public var underlyingService: any LeaderboardService { service }

    /// Reflects the user's opt-in preference and connects/disconnects to match.
    public func setOptedIn(_ value: Bool) async {
        optedIn = value
        if value {
            await connect()
        } else {
            status = .optedOut
            topEntries = []
            localEntry = nil
        }
    }

    /// Authenticates (if needed) and loads current standings.
    public func connect() async {
        guard optedIn else { status = .optedOut; return }
        status = .connecting
        await service.authenticate()
        guard service.isAuthenticated else {
            status = .failed(L10n.Leaderboard.errorNotAuthenticated)
            return
        }
        await refresh()
    }

    /// Reloads top entries and the local player's standing.
    public func refresh() async {
        guard optedIn, service.isAuthenticated else { return }
        do {
            async let top = service.loadTopEntries(limit: 25)
            async let mine = service.loadLocalEntry()
            topEntries = try await top
            localEntry = try await mine
            status = .ready
        } catch {
            status = .failed((error as? LeaderboardError)?.errorDescription ?? error.localizedDescription)
        }
    }

    /// Submits the player's current streak if opted in and authenticated.
    /// Safe to call from the dismiss flow; silently no-ops when opted out.
    public func submitIfEnabled(streak: Int) async {
        guard optedIn, service.isAuthenticated else { return }
        do {
            try await service.submit(streak: streak)
            await refresh()
        } catch {
            status = .failed((error as? LeaderboardError)?.errorDescription ?? error.localizedDescription)
        }
    }
}
