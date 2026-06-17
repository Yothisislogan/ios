import Foundation

/// The computed result of a reaction-test session.
public struct ReactionScore: Equatable, Sendable {
    /// Mean reaction time across valid rounds, in milliseconds.
    public let averageMs: Double
    /// Fastest single round, in milliseconds.
    public let bestMs: Double
    /// Slowest single round, in milliseconds.
    public let worstMs: Double
    /// Number of rounds counted toward the score.
    public let roundCount: Int
    /// Whether the session passes the configured threshold (and had no
    /// disqualifying errors, e.g. tapping a "no-go" target).
    public let passed: Bool

    public init(averageMs: Double, bestMs: Double, worstMs: Double, roundCount: Int, passed: Bool) {
        self.averageMs = averageMs
        self.bestMs = bestMs
        self.worstMs = worstMs
        self.roundCount = roundCount
        self.passed = passed
    }
}

/// Pure scoring logic for reaction tests, shared by the dismiss gate and the
/// standalone trainer. No UIKit/SwiftUI dependency so it is fully unit-testable.
public enum ReactionScorer {

    /// Scores a completed session.
    ///
    /// - Parameters:
    ///   - roundTimesMs: Reaction time for each completed round, in milliseconds.
    ///   - passThresholdMs: Maximum *average* allowed to pass.
    ///   - errorCount: Disqualifying errors (e.g. tapped a no-go target, or a
    ///     false start). Any error fails the session regardless of timing.
    /// - Returns: A `ReactionScore`, or `nil` if there were no rounds to score.
    public static func score(
        roundTimesMs: [Double],
        passThresholdMs: Double,
        errorCount: Int = 0
    ) -> ReactionScore? {
        guard !roundTimesMs.isEmpty else { return nil }

        let total = roundTimesMs.reduce(0, +)
        let average = total / Double(roundTimesMs.count)
        let best = roundTimesMs.min() ?? average
        let worst = roundTimesMs.max() ?? average
        let passed = errorCount == 0 && average <= passThresholdMs

        return ReactionScore(
            averageMs: average,
            bestMs: best,
            worstMs: worst,
            roundCount: roundTimesMs.count,
            passed: passed
        )
    }
}
