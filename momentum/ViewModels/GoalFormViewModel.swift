import Foundation
import SwiftData

struct StepInput: Identifiable, Equatable {
    let id = UUID()
    var title: String
}

@Observable
final class GoalFormViewModel {
    var title: String = ""
    var goalDescription: String = ""
    var hasDeadline: Bool = false
    var deadline: Date = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: .now) ?? .now
    var hasReminder: Bool = false
    var reminderDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
    var repetition: GoalRepetition = .none
    var stepInputs: [StepInput] = [StepInput(title: "")]

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var nonEmptyStepTitles: [String] {
        stepInputs.map(\.title).filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    func loadGoal(_ goal: Goal) {
        title = goal.title
        goalDescription = goal.goalDescription
        hasDeadline = goal.deadline != nil
        deadline = goal.deadline ?? Calendar.current.date(byAdding: .weekOfYear, value: 1, to: .now) ?? .now
        hasReminder = goal.reminderDate != nil
        reminderDate = goal.reminderDate ?? Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
        repetition = goal.repetition
        stepInputs = goal.sortedSteps.map { StepInput(title: $0.title) }
        if stepInputs.isEmpty {
            stepInputs = [StepInput(title: "")]
        }
    }

    func addStep() {
        stepInputs.append(StepInput(title: ""))
    }

    func removeStep(at index: Int) {
        guard stepInputs.count > 1 else { return }
        stepInputs.remove(at: index)
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
