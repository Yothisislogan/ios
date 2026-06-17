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

/// Selectable accent colors. Persisted as the `String` raw value.
public enum AppAccentColor: String, CaseIterable, Codable, Sendable, Identifiable {
    case sunrise
    case ocean
    case forest
    case grape
    case slate

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .sunrise: return L10n.Accent.sunrise
        case .ocean: return L10n.Accent.ocean
        case .forest: return L10n.Accent.forest
        case .grape: return L10n.Accent.grape
        case .slate: return L10n.Accent.slate
        }
    }

    public var color: Color {
        switch self {
        case .sunrise: return Color(red: 0.98, green: 0.55, blue: 0.25)
        case .ocean: return Color(red: 0.16, green: 0.52, blue: 0.92)
        case .forest: return Color(red: 0.20, green: 0.62, blue: 0.40)
        case .grape: return Color(red: 0.56, green: 0.35, blue: 0.86)
        case .slate: return Color(red: 0.40, green: 0.46, blue: 0.56)
        }
    }
}
