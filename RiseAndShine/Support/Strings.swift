import Foundation

/// Central catalog of user-facing strings.
///
/// Every string the user can see is funneled through `L10n` so the app is ready
/// for localization: each entry uses `String(localized:)`, which the Xcode
/// String Catalog (`.xcstrings`) can extract automatically. Keep keys grouped by
/// feature area.
enum L10n {

    enum Tab {
        static let alarms = String(localized: "tab.alarms", defaultValue: "Alarms")
        static let trainer = String(localized: "tab.trainer", defaultValue: "Trainer")
        static let bedtime = String(localized: "tab.bedtime", defaultValue: "Bedtime")
        static let stats = String(localized: "tab.stats", defaultValue: "Stats")
        static let settings = String(localized: "tab.settings", defaultValue: "Settings")
    }

    enum Stats {
        static let title = String(localized: "stats.title", defaultValue: "Stats")
        static let currentStreak = String(localized: "stats.currentStreak", defaultValue: "Current streak")
        static let longestStreak = String(localized: "stats.longestStreak", defaultValue: "Longest streak")
        static func days(_ count: Int) -> String {
            String(localized: "stats.days", defaultValue: "\(count) day(s)")
        }
        static let reactionHistory = String(localized: "stats.reactionHistory", defaultValue: "Reaction Performance")
        static let viewHistory = String(localized: "stats.viewHistory", defaultValue: "View full history")
        static let leaderboard = String(localized: "stats.leaderboard", defaultValue: "Leaderboard")
        static let noData = String(localized: "stats.noData", defaultValue: "No data yet")
        static let noDataDetail = String(localized: "stats.noData.detail", defaultValue: "Complete a reaction test or dismiss an alarm to start tracking your performance.")
    }

    enum History {
        static let title = String(localized: "history.title", defaultValue: "History")
        static let best = String(localized: "history.best", defaultValue: "Best")
        static let average = String(localized: "history.average", defaultValue: "Average")
        static let sessions = String(localized: "history.sessions", defaultValue: "Sessions")
        static let passRate = String(localized: "history.passRate", defaultValue: "Pass rate")
        static let chartTitle = String(localized: "history.chartTitle", defaultValue: "Average reaction time")
        static func ms(_ value: Double) -> String {
            String(localized: "history.ms", defaultValue: "\(Int(value.rounded())) ms")
        }
        static let filterAll = String(localized: "history.filter.all", defaultValue: "All")
        static let filterTrainer = String(localized: "history.filter.trainer", defaultValue: "Trainer")
        static let filterDismiss = String(localized: "history.filter.dismiss", defaultValue: "Alarm dismiss")
    }

    enum Leaderboard {
        static let title = String(localized: "leaderboard.title", defaultValue: "Wake-Up Streak Leaderboard")
        static let optInTitle = String(localized: "leaderboard.optIn.title", defaultValue: "Join the global leaderboard")
        static let optInDetail = String(localized: "leaderboard.optIn.detail", defaultValue: "Opt in to compare your wake-up streak with players worldwide via Game Center. Your Game Center alias is shown; you can opt out any time.")
        static let optInToggle = String(localized: "leaderboard.optIn.toggle", defaultValue: "Share my streak")
        static let connecting = String(localized: "leaderboard.connecting", defaultValue: "Connecting to Game Center…")
        static let retry = String(localized: "leaderboard.retry", defaultValue: "Try again")
        static let openDashboard = String(localized: "leaderboard.openDashboard", defaultValue: "Open Game Center")
        static let yourRank = String(localized: "leaderboard.yourRank", defaultValue: "Your rank")
        static let notRankedYet = String(localized: "leaderboard.notRankedYet", defaultValue: "Build a streak to appear on the board.")
        static func rank(_ value: Int) -> String {
            String(localized: "leaderboard.rank", defaultValue: "#\(value)")
        }
        static let errorNotAuthenticated = String(localized: "leaderboard.error.notAuthenticated", defaultValue: "Sign in to Game Center to use the leaderboard.")
        static let errorUnavailable = String(localized: "leaderboard.error.unavailable", defaultValue: "The leaderboard is currently unavailable.")
    }

    enum Placeholder {
        static let comingSoon = String(localized: "placeholder.comingSoon", defaultValue: "Coming soon")
        static func alarms(count: Int) -> String {
            String(
                localized: "placeholder.alarms.count",
                defaultValue: "\(count) alarm(s) stored. The alarm list arrives in the next stage.",
                comment: "Shown on the Alarms placeholder tab during early development."
            )
        }
    }

    enum Repeat {
        static let never = String(localized: "repeat.never", defaultValue: "Never")
        static let everyday = String(localized: "repeat.everyday", defaultValue: "Every day")
        static let weekdays = String(localized: "repeat.weekdays", defaultValue: "Weekdays")
        static let weekends = String(localized: "repeat.weekends", defaultValue: "Weekends")
    }

    enum Difficulty {
        static let easy = String(localized: "difficulty.easy", defaultValue: "Easy")
        static let medium = String(localized: "difficulty.medium", defaultValue: "Medium")
        static let hard = String(localized: "difficulty.hard", defaultValue: "Hard")
    }

    enum ReactionTest {
        static let simpleVisual = String(localized: "reactionTest.simpleVisual", defaultValue: "Simple Visual")
        static let goNoGo = String(localized: "reactionTest.goNoGo", defaultValue: "Go / No-Go")
        static let sequence = String(localized: "reactionTest.sequence", defaultValue: "Sequence")
        static let simpleVisualDetail = String(localized: "reactionTest.simpleVisual.detail", defaultValue: "Tap each target the instant it appears.")
        static let goNoGoDetail = String(localized: "reactionTest.goNoGo.detail", defaultValue: "Tap green targets. Don't tap red ones.")
        static let sequenceDetail = String(localized: "reactionTest.sequence.detail", defaultValue: "Tap the numbers in order, as fast as you can.")
    }

    enum Challenge {
        static let none = String(localized: "challenge.none", defaultValue: "Tap to stop")
        static let reaction = String(localized: "challenge.reaction", defaultValue: "Reaction test")
        static let math = String(localized: "challenge.math", defaultValue: "Math problem")
        static let qrScan = String(localized: "challenge.qrScan", defaultValue: "Scan a code")
        static let shake = String(localized: "challenge.shake", defaultValue: "Shake to dismiss")
    }

    enum Theme {
        static let system = String(localized: "theme.system", defaultValue: "System")
        static let light = String(localized: "theme.light", defaultValue: "Light")
        static let dark = String(localized: "theme.dark", defaultValue: "Dark")
    }

    enum Accent {
        static let witBlue = String(localized: "accent.witBlue", defaultValue: "WIT Blue")
        static let deepBlue = String(localized: "accent.deepBlue", defaultValue: "Deep Blue")
        static let green = String(localized: "accent.green", defaultValue: "Green")
        static let orange = String(localized: "accent.orange", defaultValue: "Orange")
    }
}
