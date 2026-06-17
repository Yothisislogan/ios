import Foundation
import SwiftData

/// The context in which a reaction test was performed.
public enum ReactionContext: String, Codable, Sendable {
    /// Practice session in the standalone trainer.
    case trainer
    /// Attempt made to dismiss a ringing alarm.
    case dismiss
}

/// A persisted record of one completed reaction-test session, used for the
/// trainer history chart and the statistics dashboard.
@Model
public final class ReactionAttempt {
    @Attribute(.unique) public var id: UUID
    public var date: Date

    public var testTypeRaw: String
    public var contextRaw: String

    public var averageMs: Double
    public var bestMs: Double
    public var worstMs: Double
    public var roundCount: Int
    public var errorCount: Int
    public var passed: Bool

    /// The alarm this attempt was associated with, if it was a dismiss attempt.
    public var relatedAlarmId: UUID?

    public init(
        id: UUID = UUID(),
        date: Date = .now,
        testType: ReactionTestType,
        context: ReactionContext,
        averageMs: Double,
        bestMs: Double,
        worstMs: Double,
        roundCount: Int,
        errorCount: Int = 0,
        passed: Bool,
        relatedAlarmId: UUID? = nil
    ) {
        self.id = id
        self.date = date
        self.testTypeRaw = testType.rawValue
        self.contextRaw = context.rawValue
        self.averageMs = averageMs
        self.bestMs = bestMs
        self.worstMs = worstMs
        self.roundCount = roundCount
        self.errorCount = errorCount
        self.passed = passed
        self.relatedAlarmId = relatedAlarmId
    }
}

public extension ReactionAttempt {
    var testType: ReactionTestType {
        get { ReactionTestType(rawValue: testTypeRaw) ?? .simpleVisual }
        set { testTypeRaw = newValue.rawValue }
    }

    var context: ReactionContext {
        get { ReactionContext(rawValue: contextRaw) ?? .trainer }
        set { contextRaw = newValue.rawValue }
    }

    /// Convenience initializer from a computed `ReactionScore`.
    convenience init(
        score: ReactionScore,
        testType: ReactionTestType,
        context: ReactionContext,
        errorCount: Int = 0,
        relatedAlarmId: UUID? = nil,
        date: Date = .now
    ) {
        self.init(
            date: date,
            testType: testType,
            context: context,
            averageMs: score.averageMs,
            bestMs: score.bestMs,
            worstMs: score.worstMs,
            roundCount: score.roundCount,
            errorCount: errorCount,
            passed: score.passed,
            relatedAlarmId: relatedAlarmId
        )
    }
}
