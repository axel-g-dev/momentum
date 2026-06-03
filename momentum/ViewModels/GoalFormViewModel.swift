import Foundation
import SwiftData

@Observable
final class GoalFormViewModel {
    var title: String = ""
    var goalDescription: String = ""
    var hasDeadline: Bool = false
    var deadline: Date = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: .now) ?? .now
    var hasReminder: Bool = false
    var reminderDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
    var repetition: GoalRepetition = .none
    var stepTitles: [String] = [""]

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var nonEmptyStepTitles: [String] {
        stepTitles.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    func loadGoal(_ goal: Goal) {
        title = goal.title
        goalDescription = goal.goalDescription
        hasDeadline = goal.deadline != nil
        deadline = goal.deadline ?? Calendar.current.date(byAdding: .weekOfYear, value: 1, to: .now) ?? .now
        hasReminder = goal.reminderDate != nil
        reminderDate = goal.reminderDate ?? Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
        repetition = goal.repetition
        stepTitles = goal.sortedSteps.map(\.title)
        if stepTitles.isEmpty {
            stepTitles = [""]
        }
    }

    func addStep() {
        stepTitles.append("")
    }

    func removeStep(at index: Int) {
        guard stepTitles.count > 1 else { return }
        stepTitles.remove(at: index)
    }

    func saveNewGoal(context: ModelContext) {
        let goal = Goal(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            goalDescription: goalDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            deadline: hasDeadline ? deadline : nil,
            reminderDate: hasReminder ? reminderDate : nil,
            repetition: repetition
        )

        for (index, stepTitle) in nonEmptyStepTitles.enumerated() {
            let step = GoalStep(title: stepTitle, order: index)
            goal.steps.append(step)
        }

        context.insert(goal)
        
        if hasReminder {
            NotificationService.shared.scheduleGoalReminder(for: goal)
        }
    }

    func updateGoal(_ goal: Goal, context: ModelContext) {
        goal.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        goal.goalDescription = goalDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        goal.deadline = hasDeadline ? deadline : nil
        goal.reminderDate = hasReminder ? reminderDate : nil
        goal.repetition = repetition

        // Remove old steps
        for step in goal.steps {
            context.delete(step)
        }
        goal.steps.removeAll()

        // Add updated steps
        for (index, stepTitle) in nonEmptyStepTitles.enumerated() {
            let step = GoalStep(title: stepTitle, order: index)
            goal.steps.append(step)
        }
        
        if hasReminder {
            NotificationService.shared.scheduleGoalReminder(for: goal)
        } else {
            NotificationService.shared.cancelGoalReminder(for: goal)
        }
    }
}
