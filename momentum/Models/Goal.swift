import Foundation
import SwiftData

@Model
final class Goal {
    var title: String
    var goalDescription: String
    var createdAt: Date
    var deadline: Date?
    var repetitionRaw: String
    var statusRaw: String
    @Relationship(deleteRule: .cascade, inverse: \GoalStep.goal)
    var steps: [GoalStep]
    @Relationship(deleteRule: .cascade, inverse: \GoalHistory.goal)
    var history: [GoalHistory]

    init(
        title: String,
        goalDescription: String = "",
        deadline: Date? = nil,
        repetition: GoalRepetition = .none,
        status: GoalStatus = .active
    ) {
        self.title = title
        self.goalDescription = goalDescription
        self.createdAt = .now
        self.deadline = deadline
        self.repetitionRaw = repetition.rawValue
        self.statusRaw = status.rawValue
        self.steps = []
        self.history = []
    }

    // MARK: - Computed Properties

    var repetition: GoalRepetition {
        get { GoalRepetition(rawValue: repetitionRaw) ?? .none }
        set { repetitionRaw = newValue.rawValue }
    }

    var status: GoalStatus {
        get { GoalStatus(rawValue: statusRaw) ?? .active }
        set { statusRaw = newValue.rawValue }
    }

    var progress: Double {
        guard !steps.isEmpty else { return 0 }
        let completed = steps.filter(\.isCompleted).count
        return Double(completed) / Double(steps.count)
    }

    var isCompletedToday: Bool {
        let today = Calendar.current.startOfDay(for: .now)
        return history.contains { Calendar.current.isDate($0.date, inSameDayAs: today) && $0.completed }
    }

    var currentStreak: Int {
        let calendar = Calendar.current
        let sortedDates = history
            .filter(\.completed)
            .map { calendar.startOfDay(for: $0.date) }
            .sorted(by: >)

        guard !sortedDates.isEmpty else { return 0 }

        let uniqueDates = Array(Set(sortedDates)).sorted(by: >)
        var streak = 0
        var expectedDate = calendar.startOfDay(for: .now)

        // If today isn't completed yet, start counting from yesterday
        if !uniqueDates.contains(expectedDate) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: expectedDate) else {
                return 0
            }
            expectedDate = yesterday
        }

        for date in uniqueDates {
            if calendar.isDate(date, inSameDayAs: expectedDate) {
                streak += 1
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: expectedDate) else {
                    break
                }
                expectedDate = previousDay
            } else if date < expectedDate {
                break
            }
        }

        return streak
    }

    var isOverdue: Bool {
        guard let deadline else { return false }
        return deadline < .now && status == .active
    }

    var sortedSteps: [GoalStep] {
        steps.sorted { $0.order < $1.order }
    }
}
