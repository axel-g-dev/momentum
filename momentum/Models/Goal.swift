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
    var categoryRaw: String?
    var priorityRaw: String?
    

    
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
        status: GoalStatus = .active,
        category: GoalCategory? = nil,
        priority: GoalPriority = .medium
    ) {
        self.title = title
        self.goalDescription = goalDescription
        self.createdAt = .now
        self.deadline = deadline
        self.reminderDate = reminderDate
        self.notificationId = UUID().uuidString
        self.repetitionRaw = repetition.rawValue
        self.statusRaw = status.rawValue
        self.categoryRaw = category?.rawValue
        self.priorityRaw = priority.rawValue
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

    var category: GoalCategory? {
        get {
            guard let categoryRaw else { return nil }
            return GoalCategory(rawValue: categoryRaw)
        }
        set {
            categoryRaw = newValue?.rawValue
        }
    }

    var priority: GoalPriority {
        get {
            guard let priorityRaw else { return .medium }
            return GoalPriority(rawValue: priorityRaw) ?? .medium
        }
        set {
            priorityRaw = newValue.rawValue
        }
    }

    var progress: Double {
        let totalItems = Double(steps.count)
        guard totalItems > 0 else { return 0 }
        let completedSteps = steps.reduce(0.0) { $0 + ($1.isCompleted ? 1.0 : 0.0) }
        return completedSteps / totalItems
    }

    var isCompletedToday: Bool {
        let today = Calendar.current.startOfDay(for: .now)
        return history.contains { $0.completed && $0.date == today }
    }

    var currentStreak: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        
        let completedDates = Set(history.compactMap { $0.completed ? $0.date : nil })
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
