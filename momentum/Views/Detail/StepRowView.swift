import SwiftUI

struct StepRowView: View {
    let step: GoalStep
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: step.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(step.isCompleted ? .accentOcean : Color(.systemGray3))
                    .animation(.easeInOut(duration: 0.2), value: step.isCompleted)

                Text(step.title)
                    .font(.body)
                    .foregroundStyle(step.isCompleted ? .textTertiary : .textPrimary)
                    .strikethrough(step.isCompleted)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 0) {
        StepRowView(step: GoalStep(title: "Read documentation", isCompleted: true, order: 0)) {}
        Divider().padding(.leading, 44)
        StepRowView(step: GoalStep(title: "Build a project", isCompleted: false, order: 1)) {}
    }
    .background(Color(.secondarySystemBackground))
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .padding()
}
