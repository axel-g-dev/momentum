import SwiftUI

enum GoalCategory: String, CaseIterable, Identifiable, Codable {
    case sport
    case work
    case health
    case personal
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .sport: return String(localized: "category.sport", defaultValue: "Sport")
        case .work: return String(localized: "category.work", defaultValue: "Work")
        case .health: return String(localized: "category.health", defaultValue: "Health")
        case .personal: return String(localized: "category.personal", defaultValue: "Personal")
        }
    }
    
    var emoji: String {
        switch self {
        case .sport: return "🏃"
        case .work: return "💼"
        case .health: return "🧘"
        case .personal: return "🎯"
        }
    }
    
    var iconName: String {
        switch self {
        case .sport: return "figure.run"
        case .work: return "briefcase"
        case .health: return "figure.mind.and.body"
        case .personal: return "target"
        }
    }
    
    var color: Color {
        switch self {
        case .sport: return .orange
        case .work: return .blue
        case .health: return .green
        case .personal: return .purple
        }
    }
}
