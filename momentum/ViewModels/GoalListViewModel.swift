import SwiftData
import UIKit

@Observable
final class GoalListViewModel {
    var selectedFilter: GoalStatus = .active
    var selectedCategoryFilter: GoalCategory? = nil
    var searchText: String = ""

    func filteredGoals(from goals: [Goal]) -> [Goal] {
        // Main list only displays top-level goals (parent == nil)
        var result = goals.filter { $0.status == selectedFilter && $0.parent == nil }

        if let selectedCategoryFilter {
            result = result.filter { $0.category == selectedCategoryFilter }
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Priority-first sorting: High > Medium > Low, then newest first
        return result.sorted {
            if $0.priority != $1.priority {
                return $0.priority.sortOrder > $1.priority.sortOrder
            }
            return $0.createdAt > $1.createdAt
        }
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

    func markCompletedToday(_ goal: Goal) {
        guard !goal.isCompletedToday else { return }
        let entry = GoalHistory(date: .now, completed: true)
        goal.history.append(entry)

        // Auto-complete goal if all steps/subgoals are done and repetition is none
        if goal.progress >= 1.0 && goal.repetition == .none {
            goal.status = .completed
        }
        
        HapticManager.shared.notification(type: .success)
    }

    func unmarkCompletedToday(_ goal: Goal) {
        let today = Calendar.current.startOfDay(for: .now)
        goal.history.removeAll {
            Calendar.current.isDate($0.date, inSameDayAs: today)
        }
        HapticManager.shared.impact(style: .light)
    }
}
