import SwiftUI

/// The We Insure Things brand palette, the single source of truth for color
/// across the app. Use the semantic accessors (`primary`, `success`, …) in
/// feature code so a future palette tweak only touches this file.
enum Brand {
    // MARK: Raw palette
    /// Primary brand blue — "WIT Blue".
    static let witBlue = Color(hex: 0x00AEEF)
    /// Darker blue for hover/pressed states — "Deep WIT Blue".
    static let deepBlue = Color(hex: 0x007EAE)
    /// Dark background — "Ink / Navy".
    static let inkNavy = Color(hex: 0x06121D)
    /// Light background tint — "Ice Blue".
    static let iceBlue = Color(hex: 0xEAF8FD)
    /// Muted/secondary text — "Soft Gray".
    static let softGray = Color(hex: 0x6B7280)
    /// Success / positive — brand green.
    static let green = Color(hex: 0x33D17A)
    /// Warning / punchy accent — brand orange.
    static let orange = Color(hex: 0xFF9F1C)
    /// Text on brand-colored surfaces.
    static let onBrand = Color.white

    // MARK: Semantic roles
    /// Default app tint / interactive elements.
    static let primary = witBlue
    /// Pressed/hover variant of `primary`.
    static let primaryPressed = deepBlue
    /// Positive outcomes (passed reaction tests, on-time wakes).
    static let success = green
    /// Cautionary outcomes (failed/late, attention-needed).
    static let warning = orange
    /// Secondary text role.
    static let secondaryText = softGray
}
