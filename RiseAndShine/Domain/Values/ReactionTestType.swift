import Foundation

/// The variants of reaction test available in the standalone trainer and,
/// where applicable, as the dismiss gate.
///
/// Persisted as the `String` raw value.
public enum ReactionTestType: String, CaseIterable, Codable, Sendable, Identifiable {
    /// Tap each target as soon as it appears.
    case simpleVisual
    /// Tap on "go" targets, withhold on "no-go" (e.g. red) targets.
    case goNoGo
    /// Tap targets in a required numeric/sequence order.
    case sequence

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .simpleVisual: return L10n.ReactionTest.simpleVisual
        case .goNoGo: return L10n.ReactionTest.goNoGo
        case .sequence: return L10n.ReactionTest.sequence
        }
    }

    public var detail: String {
        switch self {
        case .simpleVisual: return L10n.ReactionTest.simpleVisualDetail
        case .goNoGo: return L10n.ReactionTest.goNoGoDetail
        case .sequence: return L10n.ReactionTest.sequenceDetail
        }
    }
}
