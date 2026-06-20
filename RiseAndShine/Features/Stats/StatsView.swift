import SwiftData
import SwiftUI

/// The Stats tab: wake-up streak, reaction-performance summary, and an entry
/// point to the full history and the opt-in global leaderboard.
struct StatsView: View {
    @Query(sort: \WakeRecord.dayStart, order: .reverse) private var wakeRecords: [WakeRecord]
    @Query(sort: \ReactionAttempt.date, order: .reverse) private var attempts: [ReactionAttempt]

    private var dailyResults: [WakeDayResult] {
        WakeStreakCalculator.dailyResults(from: wakeRecords)
    }

    private var streaks: WakeStreaks {
        WakeStreakCalculator.streaks(for: dailyResults)
    }

    /// The streak only counts as "current" if its last success was today or
    /// yesterday; otherwise it has lapsed and we show zero.
    private var displayedCurrentStreak: Int {
        WakeStreakCalculator.isCurrentStreakActive(results: dailyResults) ? streaks.current : 0
    }

    private var reactionSummary: ReactionSummary {
        ReactionStatsCalculator.summarize(attempts.map(\.reactionSample))
    }

    private var hasData: Bool { !wakeRecords.isEmpty || !attempts.isEmpty }

    var body: some View {
        NavigationStack {
            Group {
                if hasData {
                    content
                } else {
                    ContentUnavailableView {
                        Label(L10n.Stats.noData, systemImage: "chart.line.uptrend.xyaxis")
                    } description: {
                        Text(L10n.Stats.noDataDetail)
                    }
                }
            }
            .navigationTitle(L10n.Stats.title)
        }
    }

    private var content: some View {
        List {
            Section {
                HStack(spacing: 12) {
                    StatCard(
                        title: L10n.Stats.currentStreak,
                        value: L10n.Stats.days(displayedCurrentStreak),
                        systemImage: "flame.fill"
                    )
                    StatCard(
                        title: L10n.Stats.longestStreak,
                        value: L10n.Stats.days(streaks.longest),
                        systemImage: "trophy.fill"
                    )
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            Section(L10n.Stats.reactionHistory) {
                if reactionSummary.sessionCount > 0 {
                    summaryRow(L10n.History.best, bestText)
                    summaryRow(L10n.History.average, averageText)
                    summaryRow(L10n.History.sessions, "\(reactionSummary.sessionCount)")
                    summaryRow(L10n.History.passRate, passRateText)
                }
                NavigationLink(L10n.Stats.viewHistory) {
                    ReactionHistoryView()
                }
            }

            Section {
                NavigationLink {
                    LeaderboardView(currentStreak: displayedCurrentStreak)
                } label: {
                    Label(L10n.Stats.leaderboard, systemImage: "globe")
                }
            }
        }
    }

    private func summaryRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value).foregroundStyle(.secondary).monospacedDigit()
        }
    }

    private var bestText: String {
        reactionSummary.bestAverageMs.map { L10n.History.ms($0) } ?? "—"
    }
    private var averageText: String {
        reactionSummary.meanAverageMs.map { L10n.History.ms($0) } ?? "—"
    }
    private var passRateText: String {
        reactionSummary.passRate.formatted(.percent.precision(.fractionLength(0)))
    }
}

/// A compact metric tile used on the dashboard.
private struct StatCard: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: systemImage)
                .font(.caption)
                .foregroundStyle(.secondary)
                .labelStyle(.titleAndIcon)
            Text(value)
                .font(.title2.bold())
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(value)")
    }
}

extension ReactionAttempt {
    /// Projection into the pure stats model.
    var reactionSample: ReactionSample {
        ReactionSample(date: date, averageMs: averageMs, passed: passed)
    }
}

#if DEBUG
#Preview("With data") {
    StatsView()
        .modelContainer(PreviewData.container(withSampleData: true))
        .environment(PreviewData.optedInLeaderboardModel())
}

#Preview("Empty") {
    StatsView()
        .modelContainer(PreviewData.container(withSampleData: false))
        .environment(LeaderboardModel(service: MockLeaderboardService(isAuthenticated: false)))
}
#endif
