import SwiftUI

enum GoalPriority: String, CaseIterable, Identifiable, Codable, Comparable {
    case low
    case medium
    case high
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .high: return String(localized: "priority.high", defaultValue: "High")
        case .medium: return String(localized: "priority.medium", defaultValue: "Medium")
        case .low: return String(localized: "priority.low", defaultValue: "Low")
        }
    }
    
    var iconName: String {
        switch self {
        case .high: return "exclamationmark.3"
        case .medium: return "exclamationmark.2"
        case .low: return "exclamationmark"
        }
    }
    
    var prioritySymbol: String {
        switch self {
        case .high: return "!!!"
        case .medium: return "!!"
        case .low: return "!"
        }
    }
    
    var color: Color {
        switch self {
        case .high: return .red
        case .medium: return .orange
        case .low: return .blue
        }
    }
    
    var sortOrder: Int {
        switch self {
        case .high: return 3
        case .medium: return 2
        case .low: return 1
        }
    }
    
    static func < (lhs: GoalPriority, rhs: GoalPriority) -> Bool {
        return lhs.sortOrder < rhs.sortOrder
    }
}
