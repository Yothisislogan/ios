import Foundation

/// One reaction session reduced to what the history/stats views need.
/// Decoupled from the `ReactionAttempt` SwiftData model so the aggregation math
/// is pure and unit-testable.
public struct ReactionSample: Equatable, Sendable {
    public let date: Date
    public let averageMs: Double
    public let passed: Bool

    public init(date: Date, averageMs: Double, passed: Bool) {
        self.date = date
        self.averageMs = averageMs
        self.passed = passed
    }
}

/// Aggregate performance statistics across many reaction sessions.
public struct ReactionSummary: Equatable, Sendable {
    public let sessionCount: Int
    /// Lowest (best) single-session average, in ms. `nil` when no sessions.
    public let bestAverageMs: Double?
    /// Mean of session averages, in ms. `nil` when no sessions.
    public let meanAverageMs: Double?
    /// Fraction of sessions that passed, in `0...1`.
    public let passRate: Double

    public init(sessionCount: Int, bestAverageMs: Double?, meanAverageMs: Double?, passRate: Double) {
        self.sessionCount = sessionCount
        self.bestAverageMs = bestAverageMs
        self.meanAverageMs = meanAverageMs
        self.passRate = passRate
    }

    public static let empty = ReactionSummary(sessionCount: 0, bestAverageMs: nil, meanAverageMs: nil, passRate: 0)
}

/// Pure aggregation of reaction-session history.
public enum ReactionStatsCalculator {
    public static func summarize(_ samples: [ReactionSample]) -> ReactionSummary {
        guard !samples.isEmpty else { return .empty }

        let averages = samples.map(\.averageMs)
        let best = averages.min()
        let mean = averages.reduce(0, +) / Double(averages.count)
        let passed = samples.filter(\.passed).count
        let passRate = Double(passed) / Double(samples.count)

        return ReactionSummary(
            sessionCount: samples.count,
            bestAverageMs: best,
            meanAverageMs: mean,
            passRate: passRate
        )
    }
}
