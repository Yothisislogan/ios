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
        static let settings = String(localized: "tab.settings", defaultValue: "Settings")
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
        static let sunrise = String(localized: "accent.sunrise", defaultValue: "Sunrise")
        static let ocean = String(localized: "accent.ocean", defaultValue: "Ocean")
        static let forest = String(localized: "accent.forest", defaultValue: "Forest")
        static let grape = String(localized: "accent.grape", defaultValue: "Grape")
        static let slate = String(localized: "accent.slate", defaultValue: "Slate")
    }
}
