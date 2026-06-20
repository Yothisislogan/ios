#if DEBUG
import Foundation
import SwiftData

/// Sample data and preconfigured objects for SwiftUI previews. DEBUG-only, so
/// nothing here ships in the app.
@MainActor
enum PreviewData {

    /// An in-memory container, optionally seeded with realistic sample data.
    static func container(withSampleData: Bool = true) -> ModelContainer {
        let container = PersistenceController.makeInMemoryContainer()
        guard withSampleData else { return container }

        let context = container.mainContext
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        // Wake records for the last 14 days. One missed day breaks the streak.
        for offset in 0..<14 {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            let succeeded = offset != 5 // a single snoozed day in the middle
            context.insert(WakeRecord(
                dayStart: day,
                wokeWithoutSnooze: succeeded,
                snoozeCount: succeeded ? 0 : 2,
                dismissReactionMs: succeeded ? Double.random(in: 420...700) : nil
            ))
        }

        // Reaction attempts trending faster over time.
        let contexts: [ReactionContext] = [.trainer, .dismiss]
        for offset in stride(from: 13, through: 0, by: -1) {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: .now) else { continue }
            let average = Double(680 - (13 - offset) * 14) + Double.random(in: -25...25)
            context.insert(ReactionAttempt(
                date: date,
                testType: ReactionTestType.allCases[offset % ReactionTestType.allCases.count],
                context: contexts[offset % contexts.count],
                averageMs: average,
                bestMs: average - 40,
                worstMs: average + 60,
                roundCount: 3,
                passed: average <= 600
            ))
        }

        try? context.save()
        return container
    }

    /// A leaderboard model wired to the mock service and opted in, so previews
    /// show populated standings.
    static func optedInLeaderboardModel() -> LeaderboardModel {
        let model = LeaderboardModel(service: MockLeaderboardService())
        Task { await model.setOptedIn(true) }
        return model
    }
}
#endif
