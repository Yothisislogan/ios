import Charts
import SwiftData
import SwiftUI

/// Full reaction-test history: a trend chart of session averages, aggregate
/// stats, and a list of past sessions, filterable by where they came from.
struct ReactionHistoryView: View {
    @Query(sort: \ReactionAttempt.date, order: .reverse) private var attempts: [ReactionAttempt]

    /// `nil` == all contexts.
    @State private var filter: ReactionContext?

    private var filtered: [ReactionAttempt] {
        guard let filter else { return attempts }
        return attempts.filter { $0.context == filter }
    }

    private var summary: ReactionSummary {
        ReactionStatsCalculator.summarize(filtered.map(\.reactionSample))
    }

    var body: some View {
        List {
            Section {
                Picker(L10n.History.title, selection: $filter) {
                    Text(L10n.History.filterAll).tag(ReactionContext?.none)
                    Text(L10n.History.filterTrainer).tag(ReactionContext?.some(.trainer))
                    Text(L10n.History.filterDismiss).tag(ReactionContext?.some(.dismiss))
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)
            }

            if filtered.isEmpty {
                Section {
                    ContentUnavailableView(L10n.Stats.noData, systemImage: "bolt.slash")
                }
            } else {
                summarySection
                chartSection
                sessionsSection
            }
        }
        .navigationTitle(L10n.History.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var summarySection: some View {
        Section {
            HStack {
                metric(L10n.History.best, summary.bestAverageMs.map(L10n.History.ms) ?? "—")
                Divider()
                metric(L10n.History.average, summary.meanAverageMs.map(L10n.History.ms) ?? "—")
                Divider()
                metric(L10n.History.passRate, summary.passRate.formatted(.percent.precision(.fractionLength(0))))
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var chartSection: some View {
        Section(L10n.History.chartTitle) {
            // Chart oldest -> newest for a natural left-to-right trend.
            Chart(Array(filtered.reversed())) { attempt in
                LineMark(
                    x: .value("Date", attempt.date),
                    y: .value("Milliseconds", attempt.averageMs)
                )
                .interpolationMethod(.catmullRom)
                PointMark(
                    x: .value("Date", attempt.date),
                    y: .value("Milliseconds", attempt.averageMs)
                )
                .symbolSize(40)
                .foregroundStyle(attempt.passed ? Brand.success : Brand.warning)
            }
            .frame(height: 200)
            .accessibilityLabel(L10n.History.chartTitle)
        }
    }

    private var sessionsSection: some View {
        Section(L10n.History.sessions) {
            ForEach(filtered) { attempt in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(attempt.testType.displayName)
                        Text(attempt.date, format: .dateTime.month().day().hour().minute())
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(L10n.History.ms(attempt.averageMs))
                        .monospacedDigit()
                    Image(systemName: attempt.passed ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(attempt.passed ? Brand.success : Brand.warning)
                        .accessibilityLabel(attempt.passed ? "Passed" : "Failed")
                }
            }
        }
    }

    private func metric(_ title: String, _ value: String) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.headline).monospacedDigit()
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(value)")
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        ReactionHistoryView()
            .modelContainer(PreviewData.container(withSampleData: true))
    }
}
#endif
