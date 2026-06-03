import Foundation

enum GoalStatus: String, CaseIterable, Codable {
    case active
    case completed
    case archived

    var displayName: LocalizedStringResource {
        switch self {
        case .active: LocalizedStringResource("status.active", defaultValue: "Active")
        case .completed: LocalizedStringResource("status.completed", defaultValue: "Completed")
        case .archived: LocalizedStringResource("status.archived", defaultValue: "Archived")
        }
    }

    var systemImage: String {
        switch self {
        case .active: "flame.fill"
        case .completed: "checkmark.circle.fill"
        case .archived: "archivebox.fill"
        }
    }
}
