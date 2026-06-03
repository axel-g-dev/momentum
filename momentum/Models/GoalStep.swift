import Foundation
import SwiftData

@Model
final class GoalStep {
    var title: String
    var isCompleted: Bool
    var order: Int
    var goal: Goal?

    init(title: String, isCompleted: Bool = false, order: Int = 0) {
        self.title = title
        self.isCompleted = isCompleted
        self.order = order
    }
}
