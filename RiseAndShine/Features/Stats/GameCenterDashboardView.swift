import GameKit
import SwiftUI

/// Presents Apple's native Game Center leaderboard dashboard for the wake-up
/// streak board. Used inside a `.sheet`.
struct GameCenterDashboardView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> GKGameCenterViewController {
        let controller = GKGameCenterViewController(
            leaderboardID: LeaderboardConfig.wakeStreakID,
            playerScope: .global,
            timeScope: .allTime
        )
        controller.gameCenterDelegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: GKGameCenterViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(dismiss: dismiss) }

    final class Coordinator: NSObject, GKGameCenterControllerDelegate {
        private let dismiss: DismissAction
        init(dismiss: DismissAction) { self.dismiss = dismiss }

        func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
            dismiss()
        }
    }
}
