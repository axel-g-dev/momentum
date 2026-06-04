import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var goals: [Goal]
    @State private var viewModel = GoalListViewModel()
    @State private var showingAddGoal = false
    @State private var selectedTemplate: GoalTemplate? = nil

    var body: some View {
        VStack(spacing: 0) {
            filterPicker
            categoryPillsFilter
            goalList
        }
        .navigationTitle(String(localized: "home.title", defaultValue: "my goals")) // lowercase per preferences
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
        .sheet(isPresented: $showingAddGoal, onDismiss: {
            selectedTemplate = nil
        }) {
            GoalFormView(editingGoal: nil, parentGoal: nil, initialTemplate: selectedTemplate)
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

    // MARK: - Category Pills Filter

    private var categoryPillsFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // "All" pill
                Button {
                    withAnimation(.spring(duration: 0.25)) {
                        viewModel.selectedCategoryFilter = nil
                    }
                } label: {
                    Text(String(localized: "category.all", defaultValue: "All"))
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(viewModel.selectedCategoryFilter == nil ? Color.accentOcean : Color.backgroundSecondary)
                        .foregroundStyle(viewModel.selectedCategoryFilter == nil ? .white : .textPrimary)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                
                ForEach(GoalCategory.allCases) { category in
                    Button {
                        withAnimation(.spring(duration: 0.25)) {
                            viewModel.selectedCategoryFilter = category
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(category.emoji)
                            Text(category.displayName)
                        }
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(viewModel.selectedCategoryFilter == category ? category.color : Color.backgroundSecondary)
                        .foregroundStyle(viewModel.selectedCategoryFilter == category ? .white : .textPrimary)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
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
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                viewModel.deleteGoal(goal, context: modelContext)
                            } label: {
                                Label(String(localized: "home.action.delete", defaultValue: "Delete"), systemImage: "trash")
                            }

                            if goal.status != .archived {
                                Button {
                                    withAnimation {
                                        viewModel.archiveGoal(goal)
                                    }
                                } label: {
                                    Label(String(localized: "home.action.archive", defaultValue: "Archive"), systemImage: "archivebox")
                                }
                                .tint(.orange)
                            } else {
                                Button {
                                    withAnimation {
                                        viewModel.restoreGoal(goal)
                                    }
                                } label: {
                                    Label(String(localized: "home.action.unarchive", defaultValue: "Unarchive"), systemImage: "tray.and.arrow.up")
                                }
                                .tint(.blue)
                            }
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            if goal.status == .active {
                                if goal.isCompletedToday {
                                    Button {
                                        withAnimation {
                                            viewModel.unmarkCompletedToday(goal)
                                        }
                                    } label: {
                                        Label(String(localized: "home.action.undonetoday", defaultValue: "Undo Today"), systemImage: "xmark.circle")
                                    }
                                    .tint(.gray)
                                } else {
                                    Button {
                                        withAnimation {
                                            viewModel.markCompletedToday(goal)
                                        }
                                    } label: {
                                        Label(String(localized: "home.action.donetoday", defaultValue: "Done Today"), systemImage: "checkmark.circle.fill")
                                    }
                                    .tint(.green)
                                }
                            }
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
        VStack(spacing: 20) {
            Spacer()
            
            ContentUnavailableView {
                Label {
                    Text(emptyStateTitle)
                } icon: {
                    Image(systemName: emptyStateIcon)
                        .foregroundStyle(.accentOcean)
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
                    .tint(.accentOcean)
                }
            }
            
            if viewModel.selectedFilter == .active && goals.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text(String(localized: "home.templates.header", defaultValue: "Or start with a template:"))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.textSecondary)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(GoalTemplate.templates) { template in
                                Button {
                                    selectedTemplate = template
                                    showingAddGoal = true
                                } label: {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text(template.category.emoji)
                                                .font(.title3)
                                            Spacer()
                                            Text(template.priority.displayName)
                                                .font(.caption2.weight(.bold))
                                                .foregroundStyle(template.priority.color)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(template.priority.color.opacity(0.12), in: Capsule())
                                        }
                                        
                                        Text(template.title)
                                            .font(.headline)
                                            .foregroundStyle(.textPrimary)
                                            .lineLimit(1)
                                        
                                        Text(template.description)
                                            .font(.caption2)
                                            .foregroundStyle(.textSecondary)
                                            .lineLimit(2)
                                            .multilineTextAlignment(.leading)
                                    }
                                    .padding()
                                    .frame(width: 200, height: 110)
                                    .background(Color.backgroundSecondary)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 40)
            } else {
                Spacer()
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
