import Foundation

enum GoalRepetition: String, CaseIterable, Codable {
    case none
    case daily
    case weekly
    case monthly

    var displayName: LocalizedStringResource {
        switch self {
        case .none: LocalizedStringResource("repetition.none", defaultValue: "None")
        case .daily: LocalizedStringResource("repetition.daily", defaultValue: "Daily")
        case .weekly: LocalizedStringResource("repetition.weekly", defaultValue: "Weekly")
        case .monthly: LocalizedStringResource("repetition.monthly", defaultValue: "Monthly")
        }
    }

    var systemImage: String {
        switch self {
        case .none: "calendar"
        case .daily: "arrow.trianglehead.2.clockwise"
        case .weekly: "calendar.badge.clock"
        case .monthly: "calendar.badge.plus"
        }
    }
}
