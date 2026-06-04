import Foundation

@Observable
final class StatsViewModel {
    var activeCount: Int = 0
    var completedCount: Int = 0
    var bestStreak: Int = 0
    var globalProgress: Double = 0

    func refresh(goals: [Goal]) {
        var activeProgressSum: Double = 0
        var maxStreak = 0
        var activeC = 0
        var completedC = 0
        
        for goal in goals {
            maxStreak = max(maxStreak, goal.currentStreak)
            if goal.status == .active {
                activeC += 1
                activeProgressSum += goal.progress
            } else if goal.status == .completed {
                completedC += 1
            }
        }
        
        self.activeCount = activeC
        self.completedCount = completedC
        self.bestStreak = maxStreak
        self.globalProgress = activeC > 0 ? (activeProgressSum / Double(activeC)) : 0
    }
}
