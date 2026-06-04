import Foundation
import SwiftData
import SwiftUI
import UIKit

@Observable
final class GoalListViewModel {
    var selectedFilter: GoalStatus = .active
    var searchText: String = ""

    func filteredGoals(from goals: [Goal]) -> [Goal] {
        var result = goals.filter { $0.status == selectedFilter }

        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result.sorted { $0.createdAt > $1.createdAt }
    }

    func deleteGoal(_ goal: Goal, context: ModelContext) {
        context.delete(goal)
        HapticManager.shared.notification(type: .warning)
    }

    func archiveGoal(_ goal: Goal) {
        goal.status = .archived
        HapticManager.shared.impact(style: .light)
    }

    func restoreGoal(_ goal: Goal) {
        goal.status = .active
        HapticManager.shared.impact(style: .medium)
    }

    func completeGoal(_ goal: Goal) {
        goal.status = .completed
        HapticManager.shared.notification(type: .success)
    }
}
