import SwiftUI

extension Color {
    static let accentGreen = Color(red: 0.30, green: 0.69, blue: 0.47)
    static let accentGreenLight = Color(red: 0.30, green: 0.69, blue: 0.47).opacity(0.15)
    static let backgroundPrimary = Color(.systemBackground)
    static let backgroundSecondary = Color(.secondarySystemBackground)
    static let backgroundTertiary = Color(.tertiarySystemBackground)
    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
    static let textTertiary = Color(.tertiaryLabel)
    static let destructive = Color(.systemRed)
    static let warning = Color(.systemOrange)
}

extension ShapeStyle where Self == Color {
    static var accentGreen: Color { Color.accentGreen }
    static var accentGreenLight: Color { Color(red: 0.30, green: 0.69, blue: 0.47).opacity(0.15) }
    static var textPrimary: Color { Color(.label) }
    static var textSecondary: Color { Color(.secondaryLabel) }
    static var textTertiary: Color { Color(.tertiaryLabel) }
    static var destructive: Color { Color(.systemRed) }
    static var warning: Color { Color(.systemOrange) }
}
