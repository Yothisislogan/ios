import SwiftData
import SwiftUI

/// Root tab shell. Establishes the app's five tabs (Alarms, Trainer, Bedtime,
/// Stats, Settings). The Stats tab is fully implemented; the others are
/// placeholders filled in by later stages.
///
/// `RootView` owns the `LeaderboardModel` (a `@MainActor @Observable`) and
/// injects it into the environment so the Stats/Leaderboard screens share one
/// instance. It uses the real Game Center service; nothing connects until the
/// user opts in.
struct RootView: View {
    @Environment(\.modelContext) private var context
    @Query private var alarms: [Alarm]
    @Query private var settingsList: [AppSettings]

    @State private var leaderboard = LeaderboardModel(service: GameCenterService())

    var body: some View {
        TabView {
            placeholder(
                title: L10n.Tab.alarms,
                systemImage: "alarm",
                message: L10n.Placeholder.alarms(count: alarms.count)
            )
            .tabItem { Label(L10n.Tab.alarms, systemImage: "alarm") }

            placeholder(
                title: L10n.Tab.trainer,
                systemImage: "bolt.fill",
                message: L10n.Placeholder.comingSoon
            )
            .tabItem { Label(L10n.Tab.trainer, systemImage: "bolt.fill") }

            placeholder(
                title: L10n.Tab.bedtime,
                systemImage: "bed.double.fill",
                message: L10n.Placeholder.comingSoon
            )
            .tabItem { Label(L10n.Tab.bedtime, systemImage: "bed.double.fill") }

            StatsView()
                .tabItem { Label(L10n.Tab.stats, systemImage: "chart.bar.fill") }

            placeholder(
                title: L10n.Tab.settings,
                systemImage: "gearshape.fill",
                message: L10n.Placeholder.comingSoon
            )
            .tabItem { Label(L10n.Tab.settings, systemImage: "gearshape.fill") }
        }
        .environment(leaderboard)
        .task {
            // Ensure settings exist and reflect a prior opt-in into the model.
            let settings = settingsList.first ?? PersistenceController.loadSettings(in: context)
            if settings.leaderboardOptIn, !leaderboard.optedIn {
                await leaderboard.setOptedIn(true)
            }
        }
    }

    @ViewBuilder
    private func placeholder(title: String, systemImage: String, message: String) -> some View {
        NavigationStack {
            ContentUnavailableView {
                Label(title, systemImage: systemImage)
            } description: {
                Text(message)
            }
            .navigationTitle(title)
        }
    }
}

#if DEBUG
#Preview {
    RootView()
        .modelContainer(PreviewData.container(withSampleData: true))
}
#endif
