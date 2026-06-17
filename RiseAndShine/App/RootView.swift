import SwiftData
import SwiftUI

/// Stage 1 placeholder shell.
///
/// This establishes the tab structure the app will grow into (Alarms,
/// Trainer, Bedtime, Stats, Settings) and proves the SwiftData container is
/// wired up by reporting the current alarm count. Feature screens are filled
/// in starting in Stage 2.
struct RootView: View {
    @Query private var alarms: [Alarm]

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

            placeholder(
                title: L10n.Tab.settings,
                systemImage: "gearshape.fill",
                message: L10n.Placeholder.comingSoon
            )
            .tabItem { Label(L10n.Tab.settings, systemImage: "gearshape.fill") }
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

#Preview {
    RootView()
        .modelContainer(PersistenceController.makeInMemoryContainer())
}
