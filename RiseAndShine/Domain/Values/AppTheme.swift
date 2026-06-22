import SwiftUI

/// Light/dark/system appearance preference. Persisted as the `String` raw value.
public enum AppTheme: String, CaseIterable, Codable, Sendable, Identifiable {
    case system
    case light
    case dark

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .system: return L10n.Theme.system
        case .light: return L10n.Theme.light
        case .dark: return L10n.Theme.dark
        }
    }

    /// Maps to SwiftUI's preferred color scheme. `nil` means follow the system.
    public var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

/// Selectable accent colors, drawn from the We Insure Things brand palette.
/// Persisted as the `String` raw value. WIT Blue is the default.
public enum AppAccentColor: String, CaseIterable, Codable, Sendable, Identifiable {
    case witBlue
    case deepBlue
    case green
    case orange

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .witBlue: return L10n.Accent.witBlue
        case .deepBlue: return L10n.Accent.deepBlue
        case .green: return L10n.Accent.green
        case .orange: return L10n.Accent.orange
        }
    }

    public var color: Color {
        switch self {
        case .witBlue: return Brand.witBlue
        case .deepBlue: return Brand.deepBlue
        case .green: return Brand.green
        case .orange: return Brand.orange
        }
    }
}
