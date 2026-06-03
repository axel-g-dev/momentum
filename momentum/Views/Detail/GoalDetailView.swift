import SwiftUI
import SwiftData

struct GoalDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let goal: Goal
    @State private var viewModel = GoalDetailViewModel()
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                progressSection
                stepsSection
                if goal.repetition != .none {
                    dailyCompletionSection
                }
            }
            .padding()
        }
        .background(Color.backgroundPrimary)
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

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
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

    // MARK: - Progress

    private var progressSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 10)

                Circle()
                    .trim(from: 0, to: goal.progress)
                    .stroke(Color.accentOcean, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(duration: 0.6), value: goal.progress)

                VStack(spacing: 2) {
                    Text("\(Int(goal.progress * 100))%")
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

    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "detail.steps", defaultValue: "Steps"))
                .font(.headline)
                .foregroundStyle(.textPrimary)

            if goal.sortedSteps.isEmpty {
                Text(String(localized: "detail.steps.empty", defaultValue: "No steps defined."))
                    .font(.subheadline)
                    .foregroundStyle(.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 0) {
                    ForEach(goal.sortedSteps) { step in
                        StepRowView(step: step) {
                            withAnimation(.spring(duration: 0.3)) {
                                viewModel.toggleStep(step)
                            }
                        }

                        if step.id != goal.sortedSteps.last?.id {
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

    // MARK: - Daily Completion

    private var dailyCompletionSection: some View {
        VStack(spacing: 12) {
            if goal.isCompletedToday {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.accentOcean)
                    Text(String(localized: "detail.completed.today", defaultValue: "Completed today"))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.accentOcean)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentOceanLight)
                .clipShape(RoundedRectangle(cornerRadius: 12))

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
