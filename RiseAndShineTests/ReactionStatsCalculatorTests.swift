import XCTest
@testable import RiseAndShine

final class ReactionStatsCalculatorTests: XCTestCase {

    private func sample(_ avg: Double, passed: Bool, daysAgo: Int = 0) -> ReactionSample {
        ReactionSample(
            date: Date().addingTimeInterval(TimeInterval(-daysAgo * 86_400)),
            averageMs: avg,
            passed: passed
        )
    }

    func testEmptyIsEmptySummary() {
        XCTAssertEqual(ReactionStatsCalculator.summarize([]), .empty)
    }

    func testAggregatesBestMeanAndPassRate() {
        let summary = ReactionStatsCalculator.summarize([
            sample(500, passed: true),
            sample(700, passed: false),
            sample(600, passed: true),
            sample(400, passed: true),
        ])
        XCTAssertEqual(summary.sessionCount, 4)
        XCTAssertEqual(summary.bestAverageMs, 400)
        XCTAssertEqual(summary.meanAverageMs!, 550, accuracy: 0.0001)
        XCTAssertEqual(summary.passRate, 0.75, accuracy: 0.0001)
    }

    func testSingleSample() {
        let summary = ReactionStatsCalculator.summarize([sample(333, passed: true)])
        XCTAssertEqual(summary.sessionCount, 1)
        XCTAssertEqual(summary.bestAverageMs, 333)
        XCTAssertEqual(summary.meanAverageMs, 333)
        XCTAssertEqual(summary.passRate, 1.0, accuracy: 0.0001)
    }

    func testAllFailedZeroPassRate() {
        let summary = ReactionStatsCalculator.summarize([
            sample(900, passed: false),
            sample(800, passed: false),
        ])
        XCTAssertEqual(summary.passRate, 0.0, accuracy: 0.0001)
        XCTAssertEqual(summary.bestAverageMs, 800)
    }
}
