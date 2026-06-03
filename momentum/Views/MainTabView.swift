import SwiftUI
import SwiftData

struct MainTabView: View {
    @State private var selectedTab = 1

    var body: some View {
        tabView
    }

    private var tabView: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                StatsView()
            }
            .tabItem {
                Label(
                    String(localized: "tab.stats", defaultValue: "Stats"),
                    systemImage: "chart.bar.fill"
                )
            }
            .tag(0)

            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label(
                    String(localized: "tab.home", defaultValue: "Home"),
                    systemImage: "house.fill"
                )
            }
            .tag(1)

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label(
                    String(localized: "tab.settings", defaultValue: "Settings"),
                    systemImage: "gearshape.fill"
                )
            }
            .tag(2)
        }
        .tint(.accentOcean)
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: Goal.self, inMemory: true)
}
