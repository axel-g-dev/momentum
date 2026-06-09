import SwiftData
import UIKit

@Observable
final class GoalDetailViewModel {
    func toggleStep(_ step: GoalStep) {
        step.isCompleted.toggle()
        if let goal = step.goal {
            if step.isCompleted {
                checkGoalCompletion(goal)
            } else {
                checkGoalUncompletion(goal)
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

        if goal.repetition == .none {
            goal.status = .completed
        }
        
        HapticManager.shared.notification(type: .success)
    }

    func unmarkCompletedToday(_ goal: Goal) {
        let today = Calendar.current.startOfDay(for: .now)
        goal.history.removeAll {
            Calendar.current.isDate($0.date, inSameDayAs: today)
        }
        
        if goal.status == .completed {
            goal.status = .active
        }

        HapticManager.shared.impact(style: .light)
    }

    func checkGoalCompletion(_ goal: Goal) {
        let allStepsDone = goal.steps.allSatisfy { $0.isCompleted }
        if allStepsDone && !goal.steps.isEmpty {
            if !goal.isCompletedToday {
                let entry = GoalHistory(date: .now, completed: true)
                goal.history.append(entry)
            }

            if goal.repetition == .none {
                goal.status = .completed
            }
        }
    }

    func checkGoalUncompletion(_ goal: Goal) {
        if goal.status == .completed {
            goal.status = .active
        }
        let today = Calendar.current.startOfDay(for: .now)
        goal.history.removeAll {
            Calendar.current.isDate($0.date, inSameDayAs: today)
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
