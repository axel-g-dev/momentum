import SwiftData
import UIKit

struct StepInput: Identifiable, Equatable {
    let id = UUID()
    var title: String
}

@Observable
final class GoalFormViewModel {
    var title: String = ""
    var goalDescription: String = ""
    var hasDeadline: Bool = false
    var hasDeadlineTime: Bool = false
    var deadline: Date = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: .now) ?? .now
    var hasReminder: Bool = false
    var hasReminderTime: Bool = false
    var reminderDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
    var repetition: GoalRepetition = .none
    var stepInputs: [StepInput] = [StepInput(title: "")]
    
    // New Priority support
    var priority: GoalPriority = .medium
    var parentGoal: Goal? = nil

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
        hasDeadlineTime = true
        deadline = goal.deadline ?? Calendar.current.date(byAdding: .weekOfYear, value: 1, to: .now) ?? .now
        hasReminder = goal.reminderDate != nil
        hasReminderTime = true
        reminderDate = goal.reminderDate ?? Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
        repetition = goal.repetition
        priority = goal.priority
        parentGoal = goal.parent
        
        stepInputs = goal.sortedSteps.map { StepInput(title: $0.title) }
        if stepInputs.isEmpty {
            stepInputs = [StepInput(title: "")]
        }
    }

    func loadTemplate(_ template: GoalTemplate) {
        title = template.title
        goalDescription = template.description
        priority = template.priority
        repetition = template.repetition
        stepInputs = template.steps.map { StepInput(title: $0) }
        if stepInputs.isEmpty {
            stepInputs = [StepInput(title: "")]
        }
    }

    func addStep() {
        stepInputs.append(StepInput(title: ""))
        HapticManager.shared.selection()
    }

    func removeStep(at index: Int) {
        guard index >= 0 && index < stepInputs.count else { return }
        stepInputs.remove(at: index)
        HapticManager.shared.impact(style: .light)
    }

    func saveNewGoal(context: ModelContext) {
        let finalDeadline = hasDeadline ? (hasDeadlineTime ? deadline : endOfDay(for: deadline)) : nil
        let finalReminder = hasReminder ? (hasReminderTime ? reminderDate : defaultReminderTime(for: reminderDate)) : nil

        let goal = Goal(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            goalDescription: goalDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            deadline: finalDeadline,
            reminderDate: finalReminder,
            repetition: repetition,
            priority: priority,
            parent: parentGoal
        )

        for (index, stepTitle) in nonEmptyStepTitles.enumerated() {
            let step = GoalStep(title: stepTitle, order: index)
            goal.steps.append(step)
        }

        context.insert(goal)
        
        if let parentGoal {
            parentGoal.subGoals.append(goal)
        }
        
        if hasReminder {
            NotificationService.shared.scheduleGoalReminder(for: goal)
        }
        
        HapticManager.shared.notification(type: .success)
    }

    func updateGoal(_ goal: Goal, context: ModelContext) {
        let finalDeadline = hasDeadline ? (hasDeadlineTime ? deadline : endOfDay(for: deadline)) : nil
        let finalReminder = hasReminder ? (hasReminderTime ? reminderDate : defaultReminderTime(for: reminderDate)) : nil

        goal.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        goal.goalDescription = goalDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        goal.deadline = finalDeadline
        goal.reminderDate = finalReminder
        goal.repetition = repetition
        goal.priority = priority

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
        
        HapticManager.shared.notification(type: .success)
    }

    private func endOfDay(for date: Date) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.hour = 23
        components.minute = 59
        return Calendar.current.date(from: components) ?? date
    }

    private func defaultReminderTime(for date: Date) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.hour = 9
        components.minute = 0
        return Calendar.current.date(from: components) ?? date
    }
}
