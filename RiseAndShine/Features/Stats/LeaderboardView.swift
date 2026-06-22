import SwiftData
import SwiftUI

/// The opt-in global wake-up-streak leaderboard (Game Center).
///
/// Opt-in is the single switch: until the user enables it, no Game Center
/// authentication, submission, or loading occurs. The toggle persists to
/// `AppSettings.leaderboardOptIn` and drives `LeaderboardModel`.
struct LeaderboardView: View {
    /// The player's current (active) streak, passed from the dashboard so it can
    /// be submitted once connected.
    let currentStreak: Int

    @Environment(LeaderboardModel.self) private var model
    @Environment(\.modelContext) private var context
    @Query private var settingsList: [AppSettings]

    @State private var showingDashboard = false

    var body: some View {
        List {
            optInSection

            if model.optedIn {
                switch model.status {
                case .connecting:
                    Section {
                        HStack(spacing: 12) {
                            ProgressView()
                            Text(L10n.Leaderboard.connecting)
                        }
                    }
                case .failed(let message):
                    Section {
                        Label(message, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(Brand.warning)
                        Button(L10n.Leaderboard.retry) { Task { await connect() } }
                    }
                case .ready:
                    rankSection
                    standingsSection
                case .optedOut:
                    EmptyView()
                }
            }
        }
        .navigationTitle(L10n.Leaderboard.title)
        .navigationBarTitleDisplayMode(.inline)
        .task { await syncOnAppear() }
        .sheet(isPresented: $showingDashboard) {
            GameCenterDashboardView()
                .ignoresSafeArea()
        }
    }

    // MARK: - Sections

    private var optInSection: some View {
        Section {
            Toggle(L10n.Leaderboard.optInToggle, isOn: optInBinding)
        } header: {
            Text(L10n.Leaderboard.optInTitle)
        } footer: {
            Text(L10n.Leaderboard.optInDetail)
        }
    }

    private var rankSection: some View {
        Section {
            HStack {
                Text(L10n.Leaderboard.yourRank)
                Spacer()
                if let local = model.localEntry {
                    Text(L10n.Leaderboard.rank(local.rank))
                        .font(.headline)
                        .monospacedDigit()
                } else {
                    Text(L10n.Leaderboard.notRankedYet)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.trailing)
                }
            }
            Button {
                showingDashboard = true
            } label: {
                Label(L10n.Leaderboard.openDashboard, systemImage: "rosette")
            }
        }
    }

    private var standingsSection: some View {
        Section {
            ForEach(model.topEntries) { entry in
                HStack {
                    Text(L10n.Leaderboard.rank(entry.rank))
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                        .frame(minWidth: 44, alignment: .leading)
                    Text(entry.displayName)
                        .fontWeight(entry.isLocalPlayer ? .bold : .regular)
                    Spacer()
                    Text(L10n.Stats.days(entry.streak))
                        .monospacedDigit()
                }
                .listRowBackground(entry.isLocalPlayer ? Color.accentColor.opacity(0.12) : nil)
            }
        }
    }

    // MARK: - Logic

    private var optInBinding: Binding<Bool> {
        Binding(
            get: { model.optedIn },
            set: { newValue in
                settings.leaderboardOptIn = newValue
                try? context.save()
                Task {
                    await model.setOptedIn(newValue)
                    if newValue { await model.submitIfEnabled(streak: currentStreak) }
                }
            }
        )
    }

    private var settings: AppSettings {
        settingsList.first ?? PersistenceController.loadSettings(in: context)
    }

    private func syncOnAppear() async {
        // Reflect the persisted preference into the model, then submit the
        // latest streak so the board is up to date when viewed.
        if settings.leaderboardOptIn, !model.optedIn {
            await model.setOptedIn(true)
        }
        if model.optedIn {
            await model.submitIfEnabled(streak: currentStreak)
        }
    }

    private func connect() async {
        await model.connect()
        if model.status == .ready {
            await model.submitIfEnabled(streak: currentStreak)
        }
    }
}

#if DEBUG
#Preview("Opted in") {
    NavigationStack {
        LeaderboardView(currentStreak: 31)
            .modelContainer(PreviewData.container(withSampleData: true))
            .environment(PreviewData.optedInLeaderboardModel())
    }
}

#Preview("Opted out") {
    NavigationStack {
        LeaderboardView(currentStreak: 0)
            .modelContainer(PreviewData.container(withSampleData: false))
            .environment(LeaderboardModel(service: MockLeaderboardService(isAuthenticated: false)))
    }
}
#endif
