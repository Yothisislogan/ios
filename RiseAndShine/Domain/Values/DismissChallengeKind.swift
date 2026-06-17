import Foundation

/// The challenge a user must complete to fully dismiss an alarm.
///
/// The dismiss mechanic is intentionally pluggable: adding a new challenge type
/// means adding a case here plus a corresponding challenge view/controller in
/// the UI layer (wired up in a later stage). Persisted as the `String` raw value.
///
/// Note: `snooze` is always reachable in one tap regardless of the chosen
/// challenge — only *full dismiss* is gated.
public enum DismissChallengeKind: String, CaseIterable, Codable, Sendable, Identifiable {
    /// Plain "stop" button — no wake verification.
    case none
    /// Timed reaction-target challenge (the app's signature gate).
    case reaction
    /// Solve one or more arithmetic problems.
    case math
    /// Scan a registered QR/barcode (e.g. one placed across the room).
    case qrScan
    /// Shake the device vigorously for a short duration.
    case shake

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .none: return L10n.Challenge.none
        case .reaction: return L10n.Challenge.reaction
        case .math: return L10n.Challenge.math
        case .qrScan: return L10n.Challenge.qrScan
        case .shake: return L10n.Challenge.shake
        }
    }

    /// SF Symbol used to represent the challenge in the UI.
    public var systemImageName: String {
        switch self {
        case .none: return "stop.circle"
        case .reaction: return "bolt.circle"
        case .math: return "function"
        case .qrScan: return "qrcode.viewfinder"
        case .shake: return "iphone.gen3.radiowaves.left.and.right"
        }
    }
}
