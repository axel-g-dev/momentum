import Foundation
import SwiftData
import UIKit

@Observable
final class GoalDetailViewModel {
    func toggleStep(_ step: GoalStep) {
        step.isCompleted.toggle()
        HapticManager.shared.impact(style: step.isCompleted ? .medium : .light)
    }

    func markCompletedToday(_ goal: Goal) {
        guard !goal.isCompletedToday else { return }
        let entry = GoalHistory(date: .now, completed: true)
        goal.history.append(entry)

        // Auto-complete goal if all steps are done
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
    }

    func deleteGoal(_ goal: Goal, context: ModelContext) {
        context.delete(goal)
        HapticManager.shared.notification(type: .warning)
    }

    func archiveGoal(_ goal: Goal) {
        goal.status = .archived
    }

    func unarchiveGoal(_ goal: Goal) {
        goal.status = goal.progress >= 1.0 && goal.repetition == .none ? .completed : .active
    }
}
