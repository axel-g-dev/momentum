import SwiftUI

struct GoalRowView: View {
    let goal: Goal

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title row
            HStack {
                Text(goal.title)
                    .font(.headline)
                    .foregroundStyle(.textPrimary)

                Spacer()

                if goal.currentStreak > 0 {
                    streakBadge
                }
            }

            // Subtitle info
            HStack(spacing: 12) {
                if goal.repetition != .none {
                    Label(goal.repetition.displayName, systemImage: goal.repetition.systemImage)
                        .font(.caption)
                        .foregroundStyle(.textSecondary)
                }

                if let deadline = goal.deadline {
                    Label {
                        Text(deadline, format: .dateTime)
                    } icon: {
                        Image(systemName: "calendar")
                    }
                    .font(.caption)
                    .foregroundStyle(goal.isOverdue ? .destructive : .textSecondary)
                }
            }

            // Progress bar
            if !goal.steps.isEmpty {
                progressBar
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Components

    private var streakBadge: some View {
        HStack(spacing: 2) {
            Image(systemName: "flame.fill")
                .font(.caption2)
            Text("\(goal.currentStreak)")
                .font(.caption.weight(.semibold))
        }
        .foregroundStyle(.accentGreen)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(.accentGreenLight, in: Capsule())
    }

    private var progressBar: some View {
        VStack(alignment: .leading, spacing: 4) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray5))
                        .frame(height: 6)

                    Capsule()
                        .fill(Color.accentGreen)
                        .frame(width: geometry.size.width * goal.progress, height: 6)
                        .animation(.spring(duration: 0.4), value: goal.progress)
                }
            }
            .frame(height: 6)

            Text("\(Int(goal.progress * 100))%")
                .font(.caption2)
                .foregroundStyle(.textSecondary)
        }
    }
}

#Preview {
    List {
        GoalRowView(goal: {
            let goal = Goal(title: "Learn SwiftUI", goalDescription: "Master SwiftUI fundamentals", repetition: .daily)
            goal.steps = [
                GoalStep(title: "Read docs", isCompleted: true, order: 0),
                GoalStep(title: "Build project", isCompleted: false, order: 1),
                GoalStep(title: "Write tests", isCompleted: false, order: 2)
            ]
            return goal
        }())
    }
    .listStyle(.plain)
}
