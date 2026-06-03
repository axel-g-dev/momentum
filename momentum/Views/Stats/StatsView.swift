import SwiftUI
import SwiftData

struct StatsView: View {
    @Query private var goals: [Goal]
    @State private var viewModel = StatsViewModel()

    private var activeGoals: [Goal] {
        goals.filter { $0.status == .active }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Main stats grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    StatCardView(
                        title: String(localized: "stats.active", defaultValue: "Active"),
                        value: "\(viewModel.activeCount)",
                        systemImage: "flame.fill",
                        color: .orange
                    )

                    StatCardView(
                        title: String(localized: "stats.completed", defaultValue: "Completed"),
                        value: "\(viewModel.completedCount)",
                        systemImage: "checkmark.circle.fill",
                        color: .green
                    )

                    StatCardView(
                        title: String(localized: "stats.streak", defaultValue: "Best Streak"),
                        value: "\(viewModel.bestStreak) " + String(localized: "stats.streak.days", defaultValue: "d"),
                        systemImage: "bolt.fill",
                        color: .yellow
                    )

                    StatCardView(
                        title: String(localized: "stats.progress", defaultValue: "Progress"),
                        value: "\(Int(viewModel.globalProgress * 100))%",
                        systemImage: "chart.line.uptrend.xyaxis",
                        color: .accentOcean
                    )
                }
                .padding(.horizontal)

                // Progress overview
                if !activeGoals.isEmpty {
                    activeGoalsSection
                }
            }
            .padding(.vertical)
        }
        .background(Color.backgroundPrimary)
        .navigationTitle(String(localized: "stats.title", defaultValue: "Statistics"))
        .onAppear {
            viewModel.refresh(goals: goals)
        }
        .onChange(of: goals) {
            viewModel.refresh(goals: goals)
        }
        .navigationDestination(for: Goal.self) { goal in
            GoalDetailView(goal: goal)
        }
    }

    // MARK: - Active Goals Overview

    private var activeGoalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "stats.active.goals", defaultValue: "Active Goals"))
                .font(.headline)
                .padding(.horizontal)

            VStack(spacing: 0) {
                let list = activeGoals
                ForEach(Array(list.enumerated()), id: \.element.id) { index, goal in
                    let progress = goal.progress
                    NavigationLink(value: goal) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(goal.title)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.textPrimary)

                                Text("\(Int(progress * 100))%")
                                    .font(.caption)
                                    .foregroundStyle(.textSecondary)
                            }

                            Spacer()

                            // Mini progress ring
                            ZStack {
                                Circle()
                                    .stroke(Color(.systemGray5), lineWidth: 4)

                                Circle()
                                    .trim(from: 0, to: progress)
                                    .stroke(Color.accentOcean, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                    .rotationEffect(.degrees(-90))
                            }
                            .frame(width: 32, height: 32)
                            
                            Image(systemName: "chevron.right")
                                .font(.caption2)
                                .foregroundStyle(Color(.systemGray3))
                                .padding(.leading, 6)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if index < list.count - 1 {
                        Divider()
                            .padding(.leading, 16)
                    }
                }
            }
            .background(Color.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
        }
    }
}

#Preview {
    NavigationStack {
        StatsView()
    }
    .modelContainer(for: Goal.self, inMemory: true)
}
