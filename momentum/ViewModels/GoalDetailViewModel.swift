import SwiftData
import UIKit

@Observable
final class GoalDetailViewModel {
    func toggleStep(_ step: GoalStep) {
        step.isCompleted.toggle()
        if let goal = step.goal {
            if step.isCompleted {
                checkAndPropagateCompletion(for: goal)
            } else {
                propagateUncompletion(for: goal)
            }
        }
        HapticManager.shared.impact(style: step.isCompleted ? .medium : .light)
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

    func deleteGoal(_ goal: Goal, context: ModelContext) {
        context.delete(goal)
        HapticManager.shared.notification(type: .warning)
    }

    func archiveGoal(_ goal: Goal) {
        goal.status = .archived
        HapticManager.shared.impact(style: .medium)
    }

    func unarchiveGoal(_ goal: Goal) {
        goal.status = goal.progress >= 1.0 && goal.repetition == .none ? .completed : .active
        HapticManager.shared.impact(style: .medium)
    }
}
