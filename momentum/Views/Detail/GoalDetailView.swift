import SwiftUI
import SwiftData

struct GoalDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var goal: Goal
    @State private var viewModel = GoalDetailViewModel()
    @State private var newStepTitle = ""

    var body: some View {
        List {
            // MARK: - Title and Notes
            Section {
                TextField("Titre de l'objectif", text: $goal.title)
                    .font(.title2.weight(.semibold))
                
                TextField("Ajouter des notes...", text: $goal.goalDescription, axis: .vertical)
                    .lineLimit(2...6)
                    .foregroundStyle(.secondary)
            }

            // MARK: - Daily Completion
            if goal.repetition != .none {
                Section {
                    if goal.isCompletedToday {
                        Button {
                            withAnimation {
                                viewModel.unmarkCompletedToday(goal)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text(String(localized: "detail.completed.today", defaultValue: "Completed today"))
                                Spacer()
                                Text(String(localized: "detail.undo", defaultValue: "Undo"))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .listRowBackground(Color.accentOceanLight.opacity(0.3))
                        .tint(.accentOcean)
                    } else {
                        Button {
                            withAnimation(.spring(duration: 0.4)) {
                                viewModel.markCompletedToday(goal)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "circle")
                                Text(String(localized: "detail.markdone", defaultValue: "Mark as done today"))
                            }
                        }
                        .tint(.primary)
                    }
                }
            }

            // MARK: - Details / Metadata
            Section {
                DatePicker("Date limite", selection: Binding(
                    get: { goal.deadline ?? .now },
                    set: { goal.deadline = $0 }
                ), displayedComponents: .date)
                
                Picker("Priorité", selection: $goal.priorityRaw) {
                    ForEach(GoalPriority.allCases, id: \.self) { prio in
                        Text(prio.displayName).tag(prio.rawValue as String?)
                    }
                }
                
                Picker("Répétition", selection: $goal.repetitionRaw) {
                    ForEach(GoalRepetition.allCases, id: \.self) { rep in
                        Text(rep.displayName).tag(rep.rawValue)
                    }
                }
                
                Picker("Catégorie", selection: $goal.categoryRaw) {
                    Text("Aucune").tag(nil as String?)
                    ForEach(GoalCategory.allCases, id: \.self) { cat in
                        Text("\(cat.emoji) \(cat.displayName)").tag(cat.rawValue as String?)
                    }
                }
            } header: {
                Text("Détails")
            }

            // MARK: - Checklist / Steps
            Section {
                let sortedSteps = goal.sortedSteps
                ForEach(sortedSteps) { step in
                    StepRowView(step: step) {
                        withAnimation(.spring(duration: 0.3)) {
                            viewModel.toggleStep(step)
                        }
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let step = sortedSteps[index]
                        goal.steps.removeAll { $0.id == step.id }
                        modelContext.delete(step)
                    }
                }
                
                HStack {
                    Image(systemName: "plus.circle")
                        .foregroundStyle(.tertiary)
                    TextField("Ajouter une sous-tâche...", text: $newStepTitle)
                        .onSubmit {
                            addStep()
                        }
                }
            } header: {
                Text("Sous-tâches")
            }

            // MARK: - Subgoals (Legacy Support)
            if !goal.subGoals.isEmpty {
                Section {
                    ForEach(goal.subGoals) { subGoal in
                        NavigationLink(value: subGoal) {
                            HStack {
                                Image(systemName: subGoal.status == .completed ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(subGoal.status == .completed ? Color.accentOcean : Color(uiColor: .tertiaryLabel))
                                Text(subGoal.title)
                                    .strikethrough(subGoal.status == .completed)
                                    .foregroundStyle(subGoal.status == .completed ? .secondary : .primary)
                            }
                        }
                    }
                } header: {
                    Text("Sous-objectifs (Anciens)")
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Détails")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    if goal.status == .archived {
                        Button {
                            viewModel.unarchiveGoal(goal)
                            dismiss()
                        } label: {
                            Label(String(localized: "detail.unarchive", defaultValue: "Unarchive"), systemImage: "tray.and.arrow.up")
                        }
                    } else {
                        Button {
                            viewModel.archiveGoal(goal)
                            dismiss()
                        } label: {
                            Label(String(localized: "detail.archive", defaultValue: "Archive"), systemImage: "archivebox")
                        }
                    }

                    Button(role: .destructive) {
                        viewModel.deleteGoal(goal, context: modelContext)
                        dismiss()
                    } label: {
                        Label(String(localized: "detail.delete", defaultValue: "Delete"), systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }

    private func addStep() {
        guard !newStepTitle.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let step = GoalStep(title: newStepTitle, isCompleted: false, order: goal.steps.count)
        goal.steps.append(step)
        newStepTitle = ""
    }
}

#Preview {
    NavigationStack {
        GoalDetailView(goal: {
            let goal = Goal(title: "Learn SwiftUI", goalDescription: "Master the fundamentals of SwiftUI framework", repetition: .daily)
            goal.steps = [
                GoalStep(title: "Read official docs", isCompleted: true, order: 0),
                GoalStep(title: "Build a sample project", isCompleted: false, order: 1)
            ]
            return goal
        }())
    }
    .modelContainer(for: Goal.self, inMemory: true)
}
