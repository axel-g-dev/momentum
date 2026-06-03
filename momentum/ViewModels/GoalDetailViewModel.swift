import Foundation
import SwiftData

@Observable
final class GoalDetailViewModel {
    func toggleStep(_ step: GoalStep) {
        step.isCompleted.toggle()
    }

    func markCompletedToday(_ goal: Goal) {
        guard !goal.isCompletedToday else { return }
        let entry = GoalHistory(date: .now, completed: true)
        goal.history.append(entry)

        // Auto-complete goal if all steps are done
        if goal.progress >= 1.0 && goal.repetition == .none {
            goal.status = .completed
        }
    }

    func unmarkCompletedToday(_ goal: Goal) {
        let today = Calendar.current.startOfDay(for: .now)
        goal.history.removeAll {
            Calendar.current.isDate($0.date, inSameDayAs: today)
        }
    }

    func deleteGoal(_ goal: Goal, context: ModelContext) {
        context.delete(goal)
    }

    func archiveGoal(_ goal: Goal) {
        goal.status = .archived
    }
}
