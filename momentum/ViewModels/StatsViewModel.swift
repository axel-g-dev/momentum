import Foundation
import SwiftData

@Observable
final class StatsViewModel {
    var activeCount: Int = 0
    var completedCount: Int = 0
    var bestStreak: Int = 0
    var globalProgress: Double = 0

    func refresh(goals: [Goal]) {
        let active = goals.filter { $0.status == .active }
        let completed = goals.filter { $0.status == .completed }

        activeCount = active.count
        completedCount = completed.count

        // Best streak across all goals
        bestStreak = goals.map(\.currentStreak).max() ?? 0

        // Global progress = average progress of active goals
        if active.isEmpty {
            globalProgress = 0
        } else {
            globalProgress = active.map(\.progress).reduce(0, +) / Double(active.count)
        }
    }
}
