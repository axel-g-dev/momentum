import SwiftUI
import SwiftData

struct GoalFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = GoalFormViewModel()
    @FocusState private var focusedStepIndex: Int?

    let editingGoal: Goal?

    init(editingGoal: Goal? = nil) {
        self.editingGoal = editingGoal
    }

    private var isEditing: Bool { editingGoal != nil }

    private var navigationTitle: String {
        isEditing
            ? String(localized: "form.title.edit", defaultValue: "Edit Goal")
            : String(localized: "form.title.new", defaultValue: "New Goal")
    }

    var body: some View {
        NavigationStack {
            Form {
                basicInfoSection
                deadlineSection
                reminderSection
                repetitionSection
                stepsSection
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "form.cancel", defaultValue: "Cancel")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "form.save", defaultValue: "Save")) {
                        save()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!viewModel.isValid)
                }
            }
            .onAppear {
                if let editingGoal {
                    viewModel.loadGoal(editingGoal)
                }
            }
        }
    }

    // MARK: - Basic Info

    private var basicInfoSection: some View {
        Section {
            TextField(
                String(localized: "form.title.placeholder", defaultValue: "Goal title"),
                text: $viewModel.title
            )
            .font(.body)

            TextField(
                String(localized: "form.description.placeholder", defaultValue: "Description (optional)"),
                text: $viewModel.goalDescription,
                axis: .vertical
            )
            .lineLimit(3...6)
            .font(.body)
        }
    }

    // MARK: - Deadline

    private var deadlineSection: some View {
        Section {
            Toggle(
                String(localized: "form.deadline.toggle", defaultValue: "Set a deadline"),
                isOn: $viewModel.hasDeadline.animation()
            )
            .tint(.accentOcean)

            if viewModel.hasDeadline {
                DatePicker(
                    String(localized: "form.deadline.date", defaultValue: "Date"),
                    selection: $viewModel.deadline,
                    in: Date.now...,
                    displayedComponents: .date
                )
                .tint(.accentOcean)

                Toggle(
                    String(localized: "form.time.include", defaultValue: "Include specific time"),
                    isOn: $viewModel.hasDeadlineTime.animation()
                )
                .tint(.accentOcean)

                if viewModel.hasDeadlineTime {
                    DatePicker(
                        String(localized: "form.time.picker", defaultValue: "Time"),
                        selection: $viewModel.deadline,
                        in: Date.now...,
                        displayedComponents: .hourAndMinute
                    )
                    .tint(.accentOcean)
                }
            }
        }
    }

    // MARK: - Reminder

    private var reminderSection: some View {
        Section {
            Toggle(
                String(localized: "form.reminder.toggle", defaultValue: "Set a specific reminder"),
                isOn: $viewModel.hasReminder.animation()
            )
            .tint(.accentOcean)

            if viewModel.hasReminder {
                DatePicker(
                    String(localized: "form.reminder.date", defaultValue: "Date"),
                    selection: $viewModel.reminderDate,
                    in: Date.now...,
                    displayedComponents: .date
                )
                .tint(.accentOcean)

                Toggle(
                    String(localized: "form.time.include", defaultValue: "Include specific time"),
                    isOn: $viewModel.hasReminderTime.animation()
                )
                .tint(.accentOcean)

                if viewModel.hasReminderTime {
                    DatePicker(
                        String(localized: "form.time.picker", defaultValue: "Time"),
                        selection: $viewModel.reminderDate,
                        in: Date.now...,
                        displayedComponents: .hourAndMinute
                    )
                    .tint(.accentOcean)
                }
            }
        }
    }

    // MARK: - Repetition

    private var repetitionSection: some View {
        Section {
            Picker(
                String(localized: "form.repetition", defaultValue: "Repetition"),
                selection: $viewModel.repetition
            ) {
                ForEach(GoalRepetition.allCases, id: \.self) { rep in
                    Text(rep.displayName).tag(rep)
                }
            }
        }
    }

    // MARK: - Steps

    private var stepsSection: some View {
        Section {
            ForEach(viewModel.stepInputs) { input in
                if let index = viewModel.stepInputs.firstIndex(where: { $0.id == input.id }) {
                    HStack {
                        Image(systemName: "circle")
                            .foregroundStyle(Color(.systemGray3))
                            .font(.body)

                        TextField(
                            String(localized: "form.step.placeholder", defaultValue: "Step \(index + 1)"),
                            text: $viewModel.stepInputs[index].title
                        )
                        .focused($focusedStepIndex, equals: index)
                        .onSubmit {
                            if index == viewModel.stepInputs.count - 1 {
                                viewModel.addStep()
                                focusedStepIndex = index + 1
                            } else {
                                focusedStepIndex = index + 1
                            }
                        }

                        Button {
                            withAnimation {
                                viewModel.removeStep(at: index)
                            }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(.red)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Button {
                withAnimation {
                    viewModel.addStep()
                    focusedStepIndex = viewModel.stepInputs.count - 1
                }
            } label: {
                Label(
                    String(localized: "form.step.add", defaultValue: "Add a step"),
                    systemImage: "plus.circle.fill"
                )
                .foregroundStyle(.accentOcean)
            }
        } header: {
            Text(String(localized: "form.steps.header", defaultValue: "Steps"))
        }
    }

    // MARK: - Save

    private func save() {
        if let editingGoal {
            viewModel.updateGoal(editingGoal, context: modelContext)
        } else {
            viewModel.saveNewGoal(context: modelContext)
        }
    }
}

#Preview("New Goal") {
    GoalFormView()
        .modelContainer(for: Goal.self, inMemory: true)
}

#Preview("Edit Goal") {
    GoalFormView(editingGoal: Goal(title: "Sample", goalDescription: "A sample goal"))
        .modelContainer(for: Goal.self, inMemory: true)
}
