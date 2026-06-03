import SwiftUI

extension Color {
    static let accentOcean = Color(red: 0.0, green: 0.478, blue: 1.0)
    static let accentOceanLight = Color(red: 0.0, green: 0.478, blue: 1.0).opacity(0.15)
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
    static var accentOcean: Color { Color.accentOcean }
    static var accentOceanLight: Color { Color.accentOceanLight }
    static var textPrimary: Color { Color(.label) }
    static var textSecondary: Color { Color(.secondaryLabel) }
    static var textTertiary: Color { Color(.tertiaryLabel) }
    static var destructive: Color { Color(.systemRed) }
    static var warning: Color { Color(.systemOrange) }
}
