import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var goals: [Goal]
    @State private var viewModel = GoalListViewModel()
    @State private var newGoalText = ""
    @FocusState private var isFocusedOnNewGoal: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 16) {
                        smartListsGrid
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        goalListSection
                    }
                    .padding(.bottom, 80) // Space for bottom bar
                }
            }
            
            // Fast Add Bar
            fastAddBar
        }
        .navigationTitle(String(localized: "home.title", defaultValue: "Mes objectifs"))
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Smart Lists

    private var smartListsGrid: some View {
        HStack(spacing: 12) {
            smartListCard(
                title: "Tous",
                icon: "tray",
                color: .gray,
                count: goals.count,
                isSelected: viewModel.selectedFilter == .active && viewModel.selectedCategoryFilter == nil
            ) {
                withAnimation {
                    viewModel.selectedFilter = .active
                    viewModel.selectedCategoryFilter = nil
                }
            }

            smartListCard(
                title: "Aujourd'hui",
                icon: "calendar",
                color: .blue,
                count: goals.filter { $0.status == .active }.count, // Simplified count for active goals today
                isSelected: viewModel.selectedFilter == .active // We could add a 'today' filter, for now active is fine
            ) {
                withAnimation {
                    viewModel.selectedFilter = .active
                }
            }
            
            smartListCard(
                title: "Terminés",
                icon: "checkmark",
                color: .green,
                count: goals.filter { $0.status == .completed }.count,
                isSelected: viewModel.selectedFilter == .completed
            ) {
                withAnimation {
                    viewModel.selectedFilter = .completed
                }
            }
        }
    }

    private func smartListCard(title: String, icon: String, color: Color, count: Int, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(color)
                        .padding(8)
                        .background(color.opacity(0.15), in: Circle())
                    Spacer()
                    Text("\(count)")
                        .font(.title2.bold())
                        .foregroundStyle(.primary)
                }
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? color : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Goal List

    private var goalListSection: some View {
        let filtered = viewModel.filteredGoals(from: goals)

        return VStack(alignment: .leading, spacing: 0) {
            if filtered.isEmpty {
                Text("Aucun objectif dans cette liste.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(filtered.enumerated()), id: \.element.id) { index, goal in
                        NavigationLink(value: goal) {
                            GoalRowView(goal: goal)
                                .padding(.horizontal)
                        }
                        .buttonStyle(.plain)

                        if index < filtered.count - 1 {
                            Divider()
                                .padding(.leading, 50)
                        }
                    }
                }
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }
        }
        .navigationDestination(for: Goal.self) { goal in
            GoalDetailView(goal: goal)
        }
    }

    // MARK: - Fast Add Bar

    private var fastAddBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 12) {
                Image(systemName: "circle")
                    .font(.title2)
                    .foregroundStyle(.tertiary)
                
                TextField("Nouvel objectif...", text: $newGoalText)
                    .focused($isFocusedOnNewGoal)
                    .onSubmit {
                        createFastGoal()
                    }
                
                if !newGoalText.isEmpty {
                    Button {
                        createFastGoal()
                    } label: {
                        Text("Ajouter")
                            .fontWeight(.semibold)
                            .foregroundStyle(.accentOcean)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(.regularMaterial)
        }
    }

    private func createFastGoal() {
        guard !newGoalText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let goal = Goal(title: newGoalText)
        modelContext.insert(goal)
        newGoalText = ""
        isFocusedOnNewGoal = false
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .modelContainer(for: Goal.self, inMemory: true)
}
