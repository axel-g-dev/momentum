import SwiftData
import UIKit

@Observable
final class GoalListViewModel {
    var selectedFilter: GoalStatus = .active
    var searchText: String = ""

    func filteredGoals(from goals: [Goal]) -> [Goal] {
        // Main list only displays top-level goals (parent == nil)
        var result = goals.filter { $0.status == selectedFilter && $0.parent == nil }

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

        // Cascade to steps
        for step in goal.steps {
            step.isCompleted = true
        }

        // Cascade to sub-goals
        for subGoal in goal.subGoals {
            markSubGoalsCompleted(subGoal)
        }

        if goal.repetition == .none {
            goal.status = .completed
        }

        // Propagate upward to parent
        if let parent = goal.parent {
            checkAndPropagateCompletion(for: parent)
        }
        
        HapticManager.shared.notification(type: .success)
    }

    private func markSubGoalsCompleted(_ goal: Goal) {
        if !goal.isCompletedToday {
            let entry = GoalHistory(date: .now, completed: true)
            goal.history.append(entry)
        }
        
        for step in goal.steps {
            step.isCompleted = true
        }

        for subGoal in goal.subGoals {
            markSubGoalsCompleted(subGoal)
        }

        if goal.repetition == .none {
            goal.status = .completed
        }
    }

    func unmarkCompletedToday(_ goal: Goal) {
        let today = Calendar.current.startOfDay(for: .now)
        goal.history.removeAll {
            Calendar.current.isDate($0.date, inSameDayAs: today)
        }
        
        if goal.status == .completed {
            goal.status = .active
        }

        // Propagate uncompletion upward to parents
        if let parent = goal.parent {
            propagateUncompletion(for: parent)
        }

        HapticManager.shared.impact(style: .light)
    }

    private func propagateUncompletion(for goal: Goal) {
        if goal.status == .completed {
            goal.status = .active
        }
        let today = Calendar.current.startOfDay(for: .now)
        goal.history.removeAll {
            Calendar.current.isDate($0.date, inSameDayAs: today)
        }

        if let parent = goal.parent {
            propagateUncompletion(for: parent)
        }
    }

    func checkAndPropagateCompletion(for goal: Goal) {
        let allStepsDone = goal.steps.allSatisfy { $0.isCompleted }
        let allSubGoalsDone = goal.subGoals.allSatisfy { $0.status == .completed || $0.isCompletedToday }

        if allStepsDone && allSubGoalsDone {
            if !goal.isCompletedToday {
                let entry = GoalHistory(date: .now, completed: true)
                goal.history.append(entry)
            }

            if goal.repetition == .none {
                goal.status = .completed
            }

            if let parent = goal.parent {
                checkAndPropagateCompletion(for: parent)
            }
        }
    }
}
