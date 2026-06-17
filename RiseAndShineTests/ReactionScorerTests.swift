import XCTest
@testable import RiseAndShine

final class ReactionScorerTests: XCTestCase {

    func testEmptyRoundsReturnsNil() {
        XCTAssertNil(ReactionScorer.score(roundTimesMs: [], passThresholdMs: 600))
    }

    func testAverageBestWorstComputedCorrectly() {
        let score = ReactionScorer.score(roundTimesMs: [400, 500, 600], passThresholdMs: 600)
        XCTAssertNotNil(score)
        XCTAssertEqual(score!.averageMs, 500, accuracy: 0.0001)
        XCTAssertEqual(score!.bestMs, 400)
        XCTAssertEqual(score!.worstMs, 600)
        XCTAssertEqual(score!.roundCount, 3)
    }

    func testPassesWhenAverageAtOrBelowThreshold() {
        // Average exactly 600 with threshold 600 should pass (inclusive).
        let score = ReactionScorer.score(roundTimesMs: [600, 600, 600], passThresholdMs: 600)
        XCTAssertEqual(score?.passed, true)
    }

    func testFailsWhenAverageAboveThreshold() {
        let score = ReactionScorer.score(roundTimesMs: [700, 800, 900], passThresholdMs: 600)
        XCTAssertEqual(score?.passed, false)
    }

    func testAnyErrorFailsRegardlessOfTiming() {
        // Fast times, but a no-go violation disqualifies the session.
        let score = ReactionScorer.score(roundTimesMs: [200, 220, 210], passThresholdMs: 600, errorCount: 1)
        XCTAssertEqual(score?.passed, false)
        // Timing stats are still reported for history purposes.
        XCTAssertEqual(score?.averageMs, 210, accuracy: 0.0001)
    }

    func testSingleRound() {
        let score = ReactionScorer.score(roundTimesMs: [333], passThresholdMs: 600)
        XCTAssertEqual(score?.averageMs, 333)
        XCTAssertEqual(score?.bestMs, 333)
        XCTAssertEqual(score?.worstMs, 333)
        XCTAssertEqual(score?.passed, true)
    }
}
