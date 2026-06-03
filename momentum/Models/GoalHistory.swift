import Foundation
import SwiftData

@Model
final class GoalHistory {
    var date: Date
    var completed: Bool
    var goal: Goal?

    init(date: Date = .now, completed: Bool = true) {
        self.date = Calendar.current.startOfDay(for: date)
        self.completed = completed
    }
}
