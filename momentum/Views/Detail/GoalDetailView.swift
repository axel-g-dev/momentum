import SwiftUI
import SwiftData

struct GoalDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let goal: Goal
    @State private var viewModel = GoalDetailViewModel()
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var showingAddSubGoal = false

    var body: some View {
        let progress = goal.progress
        let sortedSteps = goal.sortedSteps
        let sortedSubGoals = goal.subGoals.sorted {
            if $0.priority != $1.priority {
                return $0.priority.sortOrder > $1.priority.sortOrder
            }
            return $0.createdAt > $1.createdAt
        }
        
        return ScrollView {
            VStack(spacing: 24) {
                headerSection
                if !goal.steps.isEmpty || !goal.subGoals.isEmpty {
                    progressSection(progress: progress)
                }
                if !goal.steps.isEmpty {
                    stepsSection(sortedSteps: sortedSteps)
                }
                subGoalsSection(sortedSubGoals: sortedSubGoals)
            }
            .padding()
        }
        .background(Color.backgroundPrimary)
        .safeAreaInset(edge: .bottom) {
            if goal.status == .active {
                VStack(spacing: 0) {
                    Divider()
                    doneSection
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                }
                .frame(maxWidth: .infinity)
                .background(.regularMaterial)
            }
        }
        .navigationTitle(goal.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        showingEditSheet = true
                    } label: {
                        Label(
                            String(localized: "detail.edit", defaultValue: "Edit"),
                            systemImage: "pencil"
                        )
                    }

                    if goal.status == .archived {
                        Button {
                            viewModel.unarchiveGoal(goal)
                            dismiss()
                        } label: {
                            Label(
                                String(localized: "detail.unarchive", defaultValue: "Unarchive"),
                                systemImage: "tray.and.arrow.up"
                            )
                        }
                    } else {
                        Button {
                            viewModel.archiveGoal(goal)
                            dismiss()
                        } label: {
                            Label(
                                String(localized: "detail.archive", defaultValue: "Archive"),
                                systemImage: "archivebox"
                            )
                        }
                    }

                    Divider()

                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label(
                            String(localized: "detail.delete", defaultValue: "Delete"),
                            systemImage: "trash"
                        )
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            GoalFormView(editingGoal: goal)
        }
        .sheet(isPresented: $showingAddSubGoal) {
            GoalFormView(editingGoal: nil, parentGoal: goal)
        }
        .alert(
            String(localized: "detail.delete.title", defaultValue: "Delete Goal"),
            isPresented: $showingDeleteAlert
        ) {
            Button(String(localized: "detail.delete.cancel", defaultValue: "Cancel"), role: .cancel) {}
            Button(String(localized: "detail.delete.confirm", defaultValue: "Delete"), role: .destructive) {
                viewModel.deleteGoal(goal, context: modelContext)
                dismiss()
            }
        } message: {
            Text(String(localized: "detail.delete.message", defaultValue: "This action cannot be undone."))
        }
    }

    // MARK: - Done Section (Big button)

    private var doneSection: some View {
        VStack(spacing: 12) {
            if goal.isCompletedToday {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                    Text(String(localized: "detail.completed.today", defaultValue: "Completed today"))
                        .font(.headline)
                }
                .foregroundStyle(.accentOcean)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentOceanLight)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                Button {
                    withAnimation {
                        viewModel.unmarkCompletedToday(goal)
                    }
                } label: {
                    Text(String(localized: "detail.undo", defaultValue: "Undo"))
                        .font(.subheadline)
                }
                .tint(.textSecondary)
            } else {
                Button {
                    withAnimation(.spring(duration: 0.4)) {
                        viewModel.markCompletedToday(goal)
                    }
                } label: {
                    Label(
                        String(localized: "detail.markdone", defaultValue: "Mark as done today"),
                        systemImage: "checkmark.circle"
                    )
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .buttonStyle(.borderedProminent)
                .tint(.accentOcean)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Priority badge only
            Label(goal.priority.displayName, systemImage: goal.priority.iconName)
                .font(.caption.weight(.semibold))
                .foregroundStyle(goal.priority.color)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(goal.priority.color.opacity(0.12), in: Capsule())

            if !goal.goalDescription.isEmpty {
                Text(goal.goalDescription)
                    .font(.body)
                    .foregroundStyle(.textSecondary)
            }

            HStack(spacing: 16) {
                if goal.repetition != .none {
                    Label(goal.repetition.displayName, systemImage: goal.repetition.systemImage)
                        .font(.subheadline)
                        .foregroundStyle(.textSecondary)
                }

                if let deadline = goal.deadline {
                    Label {
                        Text(deadline, format: .dateTime)
                    } icon: {
                        Image(systemName: "calendar")
                    }
                    .font(.subheadline)
                    .foregroundStyle(goal.isOverdue ? .destructive : .textSecondary)
                }

                if goal.currentStreak > 0 {
                    Label {
                        Text("\(goal.currentStreak) " + String(localized: "detail.streak.days", defaultValue: "days"))
                    } icon: {
                        Image(systemName: "flame.fill")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.accentOcean)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Progress (Circle)

    private func progressSection(progress: Double) -> some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 10)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.accentOcean, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(duration: 0.6), value: progress)

                VStack(spacing: 2) {
                    Text("\(Int(progress * 100))%")
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .foregroundStyle(.textPrimary)
                        .contentTransition(.numericText())

                    Text(String(localized: "detail.progress", defaultValue: "Progress"))
                        .font(.caption)
                        .foregroundStyle(.textSecondary)
                }
            }
            .frame(width: 120, height: 120)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    // MARK: - Steps

    private func stepsSection(sortedSteps: [GoalStep]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "detail.steps", defaultValue: "Steps"))
                .font(.headline)
                .foregroundStyle(.textPrimary)

            if sortedSteps.isEmpty {
                Text(String(localized: "detail.steps.empty", defaultValue: "No steps defined."))
                    .font(.subheadline)
                    .foregroundStyle(.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(sortedSteps.enumerated()), id: \.element.id) { index, step in
                        StepRowView(step: step) {
                            withAnimation(.spring(duration: 0.3)) {
                                viewModel.toggleStep(step)
                            }
                        }

                        if index < sortedSteps.count - 1 {
                            Divider()
                                .padding(.leading, 44)
                        }
                    }
                }
                .background(Color.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Sub-goals

    private func subGoalsSection(sortedSubGoals: [Goal]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(String(localized: "detail.subgoals", defaultValue: "Sub-goals"))
                    .font(.headline)
                    .foregroundStyle(.textPrimary)
                
                Spacer()
                
                Button {
                    showingAddSubGoal = true
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.body)
                        .foregroundStyle(.accentOcean)
                }
            }

            if sortedSubGoals.isEmpty {
                Text(String(localized: "detail.subgoals.empty", defaultValue: "No sub-goals defined."))
                    .font(.subheadline)
                    .foregroundStyle(.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(sortedSubGoals.enumerated()), id: \.element.id) { index, subGoal in
                        NavigationLink(value: subGoal) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(subGoal.title)
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(.textPrimary)

                                    HStack(spacing: 8) {
                                        Text(subGoal.priority.displayName)
                                            .font(.caption2.weight(.semibold))
                                            .foregroundStyle(subGoal.priority.color)
                                        
                                        if let deadline = subGoal.deadline {
                                            Text("•")
                                                .font(.caption2)
                                                .foregroundStyle(.textTertiary)
                                            Text(deadline, format: .dateTime.day().month())
                                                .font(.caption2)
                                                .foregroundStyle(.textSecondary)
                                        }
                                    }
                                }

                                Spacer()

                                Text("\(Int(subGoal.progress * 100))%")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.textSecondary)
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption2)
                                    .foregroundStyle(Color(.systemGray3))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        if index < sortedSubGoals.count - 1 {
                            Divider()
                                .padding(.leading, 16)
                        }
                    }
                }
                .background(Color.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

#Preview {
    NavigationStack {
        GoalDetailView(goal: {
            let goal = Goal(title: "Learn SwiftUI", goalDescription: "Master the fundamentals of SwiftUI framework", repetition: .daily)
            goal.steps = [
                GoalStep(title: "Read official docs", isCompleted: true, order: 0),
                GoalStep(title: "Build a sample project", isCompleted: false, order: 1),
                GoalStep(title: "Write unit tests", isCompleted: false, order: 2)
            ]
            return goal
        }())
    }
    .modelContainer(for: Goal.self, inMemory: true)
}
