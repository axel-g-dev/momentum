import Foundation
import SwiftData

@Model
final class Goal {
    var title: String
    var goalDescription: String
    var createdAt: Date
    var deadline: Date?
    var reminderDate: Date?
    var notificationId: String?
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
        reminderDate: Date? = nil,
        repetition: GoalRepetition = .none,
        status: GoalStatus = .active
    ) {
        self.title = title
        self.goalDescription = goalDescription
        self.createdAt = .now
        self.deadline = deadline
        self.reminderDate = reminderDate
        self.notificationId = UUID().uuidString
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
        let total = steps.count
        guard total > 0 else { return 0 }
        var completedCount = 0
        for step in steps {
            if step.isCompleted {
                completedCount += 1
            }
        }
        return Double(completedCount) / Double(total)
    }

    var isCompletedToday: Bool {
        let today = Calendar.current.startOfDay(for: .now)
        for entry in history {
            if entry.completed && entry.date == today {
                return true
            }
        }
        return false
    }

    var currentStreak: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        
        var completedDates = Set<Date>()
        for entry in history {
            if entry.completed {
                completedDates.insert(entry.date)
            }
        }
        
        guard !completedDates.isEmpty else { return 0 }
        
        var expectedDate: Date
        if completedDates.contains(today) {
            expectedDate = today
        } else {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else {
                return 0
            }
            if completedDates.contains(yesterday) {
                expectedDate = yesterday
            } else {
                return 0
            }
        }
        
        var streak = 0
        while completedDates.contains(expectedDate) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: expectedDate) else {
                break
            }
            expectedDate = previousDay
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
