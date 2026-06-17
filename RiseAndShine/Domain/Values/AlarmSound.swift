import Foundation

/// A selectable alarm sound.
///
/// For Stage 1 this models the *catalog* of built-in sounds plus a hook for
/// user-imported custom sounds. Only the stable `id` is persisted on `Alarm`
/// (`soundId`); the catalog resolves an id back to a displayable sound. Actual
/// audio playback and the bundled audio files are wired up in a later stage.
public struct AlarmSound: Identifiable, Equatable, Sendable, Hashable {
    public let id: String
    public let displayName: String
    /// File name (within the app bundle) for built-in sounds, or a stored
    /// file URL string for custom imports. `nil` for the silent option.
    public let fileName: String?
    public let isCustom: Bool

    public init(id: String, displayName: String, fileName: String?, isCustom: Bool = false) {
        self.id = id
        self.displayName = displayName
        self.fileName = fileName
        self.isCustom = isCustom
    }
}

/// Catalog of built-in sounds. Custom (user-imported) sounds are resolved
/// separately at runtime in a later stage.
public enum AlarmSoundCatalog {
    public static let radar = AlarmSound(id: "radar", displayName: "Radar", fileName: "radar.caf")
    public static let chimes = AlarmSound(id: "chimes", displayName: "Chimes", fileName: "chimes.caf")
    public static let beacon = AlarmSound(id: "beacon", displayName: "Beacon", fileName: "beacon.caf")
    public static let sunrise = AlarmSound(id: "sunrise", displayName: "Sunrise", fileName: "sunrise.caf")
    public static let classicBell = AlarmSound(id: "classic_bell", displayName: "Classic Bell", fileName: "classic_bell.caf")
    public static let signal = AlarmSound(id: "signal", displayName: "Signal", fileName: "signal.caf")

    public static let builtIns: [AlarmSound] = [radar, chimes, beacon, sunrise, classicBell, signal]

    /// The system-default sound id used when none is otherwise specified.
    public static let defaultSoundId = radar.id

    public static func sound(forId id: String) -> AlarmSound? {
        builtIns.first { $0.id == id }
    }
}
