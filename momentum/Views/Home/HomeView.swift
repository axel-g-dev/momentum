import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var goals: [Goal]
    @State private var viewModel = GoalListViewModel()
    @State private var showingAddGoal = false
    @State private var selectedTemplate: GoalTemplate? = nil

    var body: some View {
        List {
            // MARK: - Smart Lists Grid
            Section {
                smartListsGrid
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())

            // MARK: - My Lists / Goals
            Section {
                let filtered = viewModel.filteredGoals(from: goals)
                if filtered.isEmpty {
                    Text("Aucun objectif dans cette liste.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 20)
                } else {
                    ForEach(filtered) { goal in
                        NavigationLink(value: goal) {
                            GoalRowView(goal: goal) {
                                if goal.isCompletedToday {
                                    viewModel.unmarkCompletedToday(goal)
                                } else {
                                    viewModel.markCompletedToday(goal)
                                }
                            }
                        }
                        // Swipe actions
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                viewModel.deleteGoal(goal, context: modelContext)
                            } label: {
                                Label("Supprimer", systemImage: "trash")
                            }

                            if goal.status != .archived {
                                Button {
                                    withAnimation { viewModel.archiveGoal(goal) }
                                } label: {
                                    Label("Archiver", systemImage: "archivebox")
                                }
                                .tint(.orange)
                            } else {
                                Button {
                                    withAnimation { viewModel.restoreGoal(goal) }
                                } label: {
                                    Label("Désarchiver", systemImage: "tray.and.arrow.up")
                                }
                                .tint(.blue)
                            }
                        }
                    }
                }
            } header: {
                Text("Mes objectifs")
                    .font(.title3.bold())
                    .foregroundStyle(.primary)
                    .textCase(nil)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Objectifs")
        .searchable(text: $viewModel.searchText, prompt: "Rechercher")
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button {
                    selectedTemplate = nil
                    showingAddGoal = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                        Text("Nouvel objectif")
                            .font(.headline)
                    }
                }
                
                Spacer()
                
                Button("Ajouter liste") {
                    // Future enhancement: List management
                }
            }
        }
        .sheet(isPresented: $showingAddGoal) {
            GoalFormView(editingGoal: nil, parentGoal: nil, initialTemplate: selectedTemplate)
        }
    }

    // MARK: - Smart Lists

    private var smartListsGrid: some View {
        let columns = [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ]
        
        return LazyVGrid(columns: columns, spacing: 16) {
            smartListCard(
                title: "Aujourd'hui",
                icon: "calendar",
                color: .blue,
                count: goals.filter { $0.status == .active }.count,
                isSelected: viewModel.selectedFilter == .active && viewModel.selectedCategoryFilter == nil
            ) {
                withAnimation {
                    viewModel.selectedFilter = .active
                    viewModel.selectedCategoryFilter = nil
                }
            }
            
            smartListCard(
                title: "Terminés",
                icon: "checkmark",
                color: .gray,
                count: goals.filter { $0.status == .completed }.count,
                isSelected: viewModel.selectedFilter == .completed
            ) {
                withAnimation {
                    viewModel.selectedFilter = .completed
                    viewModel.selectedCategoryFilter = nil
                }
            }
            
            smartListCard(
                title: "Tous",
                icon: "tray",
                color: .gray,
                count: goals.count,
                isSelected: false // Only selected when actively filtering all, but "Aujourd'hui" acts as our main view
            ) {
                withAnimation {
                    viewModel.selectedFilter = .active
                    viewModel.selectedCategoryFilter = nil
                }
            }
            
            smartListCard(
                title: "Archivés",
                icon: "archivebox",
                color: .orange,
                count: goals.filter { $0.status == .archived }.count,
                isSelected: viewModel.selectedFilter == .archived
            ) {
                withAnimation {
                    viewModel.selectedFilter = .archived
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }

    private func smartListCard(title: String, icon: String, color: Color, count: Int, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    Image(systemName: icon)
                        .font(.title2.weight(.medium))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(color, in: Circle())
                    
                    Spacer()
                    
                    Text("\(count)")
                        .font(.title.bold())
                        .foregroundStyle(isSelected ? .white : .primary)
                }
                
                Text(title)
                    .font(.headline)
                    .foregroundStyle(isSelected ? .white : .secondary)
            }
            .padding(12)
            .background(isSelected ? color : Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .modelContainer(for: Goal.self, inMemory: true)
}
