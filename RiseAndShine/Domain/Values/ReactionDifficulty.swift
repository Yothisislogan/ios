import CoreGraphics
import Foundation

/// Difficulty of the reaction-time wake-verification challenge.
///
/// Difficulty controls how many targets must be tapped, how large they are,
/// and the average reaction-time threshold (in milliseconds) required to pass.
/// Persisted as the `String` raw value.
public enum ReactionDifficulty: String, CaseIterable, Codable, Sendable, Identifiable {
    case easy
    case medium
    case hard

    public var id: String { rawValue }

    /// Number of rounds the user must complete.
    public var roundCount: Int {
        switch self {
        case .easy: return 3
        case .medium: return 3
        case .hard: return 5
        }
    }

    /// On-screen target diameter in points. Larger == easier to hit.
    public var targetDiameter: CGFloat {
        switch self {
        case .easy: return 96
        case .medium: return 72
        case .hard: return 52
        }
    }

    /// Maximum average reaction time (ms) allowed to pass the gate.
    public var passThresholdMs: Double {
        switch self {
        case .easy: return 900
        case .medium: return 600
        case .hard: return 450
        }
    }

    public var displayName: String {
        switch self {
        case .easy: return L10n.Difficulty.easy
        case .medium: return L10n.Difficulty.medium
        case .hard: return L10n.Difficulty.hard
        }
    }
}
