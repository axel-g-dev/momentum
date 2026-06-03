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
    var hasDeadlineTime: Bool = false
    var deadline: Date = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: .now) ?? .now
    var hasReminder: Bool = false
    var hasReminderTime: Bool = false
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
        // Apple style: if time is at 23:59:00 exactly, it was an all day event usually, 
        // but here let's just default to true if they set it. Or since we didn't track it before, default to true.
        hasDeadlineTime = true
        deadline = goal.deadline ?? Calendar.current.date(byAdding: .weekOfYear, value: 1, to: .now) ?? .now
        hasReminder = goal.reminderDate != nil
        hasReminderTime = true
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
        // If no time is specified, we can set deadline to end of day and reminder to 9 AM
        let finalDeadline = hasDeadline ? (hasDeadlineTime ? deadline : endOfDay(for: deadline)) : nil
        let finalReminder = hasReminder ? (hasReminderTime ? reminderDate : defaultReminderTime(for: reminderDate)) : nil

        let goal = Goal(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            goalDescription: goalDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            deadline: finalDeadline,
            reminderDate: finalReminder,
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
        let finalDeadline = hasDeadline ? (hasDeadlineTime ? deadline : endOfDay(for: deadline)) : nil
        let finalReminder = hasReminder ? (hasReminderTime ? reminderDate : defaultReminderTime(for: reminderDate)) : nil

        goal.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        goal.goalDescription = goalDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        goal.deadline = finalDeadline
        goal.reminderDate = finalReminder
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
