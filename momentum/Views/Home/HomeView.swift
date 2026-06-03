import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var goals: [Goal]
    @State private var viewModel = GoalListViewModel()
    @State private var showingAddGoal = false

    var body: some View {
        VStack(spacing: 0) {
            filterPicker
            goalList
        }
        .navigationTitle(String(localized: "home.title", defaultValue: "My Goals"))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddGoal = true
                } label: {
                    Image(systemName: "plus")
                        .fontWeight(.semibold)
                }
            }
        }
        .sheet(isPresented: $showingAddGoal) {
            GoalFormView()
        }
        .searchable(
            text: $viewModel.searchText,
            prompt: String(localized: "home.search", defaultValue: "Search goals")
        )
    }

    // MARK: - Filter Picker

    private var filterPicker: some View {
        Picker(String(localized: "home.filter", defaultValue: "Filter"), selection: $viewModel.selectedFilter) {
            Text(GoalStatus.active.displayName).tag(GoalStatus.active)
            Text(GoalStatus.completed.displayName).tag(GoalStatus.completed)
            Text(GoalStatus.archived.displayName).tag(GoalStatus.archived)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    // MARK: - Goal List

    private var goalList: some View {
        let filtered = viewModel.filteredGoals(from: goals)

        return Group {
            if filtered.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(filtered) { goal in
                        NavigationLink(value: goal) {
                            GoalRowView(goal: goal)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            viewModel.deleteGoal(filtered[index], context: modelContext)
                        }
                    }
                }
                .listStyle(.plain)
                .navigationDestination(for: Goal.self) { goal in
                    GoalDetailView(goal: goal)
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ContentUnavailableView {
            Label {
                Text(emptyStateTitle)
            } icon: {
                Image(systemName: emptyStateIcon)
                    .foregroundStyle(.accentGreen)
            }
        } description: {
            Text(emptyStateDescription)
        } actions: {
            if viewModel.selectedFilter == .active {
                Button {
                    showingAddGoal = true
                } label: {
                    Text(String(localized: "home.empty.action", defaultValue: "Create a Goal"))
                }
                .buttonStyle(.borderedProminent)
                .tint(.accentGreen)
            }
        }
    }

    private var emptyStateTitle: String {
        switch viewModel.selectedFilter {
        case .active:
            String(localized: "home.empty.active.title", defaultValue: "No active goals")
        case .completed:
            String(localized: "home.empty.completed.title", defaultValue: "No completed goals")
        case .archived:
            String(localized: "home.empty.archived.title", defaultValue: "No archived goals")
        }
    }

    private var emptyStateDescription: String {
        switch viewModel.selectedFilter {
        case .active:
            String(localized: "home.empty.active.desc", defaultValue: "Start by creating your first goal.")
        case .completed:
            String(localized: "home.empty.completed.desc", defaultValue: "Completed goals will appear here.")
        case .archived:
            String(localized: "home.empty.archived.desc", defaultValue: "Archived goals will appear here.")
        }
    }

    private var emptyStateIcon: String {
        switch viewModel.selectedFilter {
        case .active: "target"
        case .completed: "checkmark.circle"
        case .archived: "archivebox"
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .modelContainer(for: Goal.self, inMemory: true)
}
