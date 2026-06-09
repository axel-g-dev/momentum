import SwiftUI

struct GoalRowView: View {
    let goal: Goal
    var onToggle: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Interactive circle / progress
            Button {
                onToggle?()
            } label: {
                if goal.isCompletedToday || goal.status == .completed {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24, weight: .regular))
                        .foregroundStyle(.accentOcean)
                        .frame(width: 24, height: 24)
                } else if !goal.steps.isEmpty {
                    circularProgress(progress: goal.progress)
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 24, weight: .regular))
                        .foregroundStyle(Color(.systemGray4))
                        .frame(width: 24, height: 24)
                }
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                // Title
                HStack(spacing: 6) {
                    if goal.priority != .medium {
                        Text(goal.priority.prioritySymbol)
                            .font(.subheadline.bold())
                            .foregroundStyle(goal.priority.color)
                    }
                    Text(goal.title)
                        .font(.headline)
                        .foregroundStyle(goal.status == .completed ? .textSecondary : .textPrimary)
                        .strikethrough(goal.status == .completed)
                }

                // Subtitle metadata
                HStack(spacing: 8) {
                    if goal.repetition != .none {
                        HStack(spacing: 2) {
                            Image(systemName: goal.repetition.systemImage)
                            Text(goal.repetition.displayName)
                        }
                    }

                    if let deadline = goal.deadline {
                        HStack(spacing: 2) {
                            Image(systemName: "calendar")
                            Text(deadline, format: .dateTime.day().month())
                        }
                        .foregroundStyle(goal.isOverdue ? .destructive : .textSecondary)
                    }
                }
                .font(.caption)
                .foregroundStyle(.textSecondary)
                .lineLimit(1)
            }

            Spacer()

            if goal.currentStreak > 0 {
                streakBadge
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
        .foregroundStyle(.accentOcean)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(.accentOceanLight, in: Capsule())
    }

    private func circularProgress(progress: Double) -> some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 2)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.accentOcean, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: 22, height: 22)
        .padding(1)
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
