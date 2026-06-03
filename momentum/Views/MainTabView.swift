import SwiftUI
import SwiftData

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                StatsView()
            }
            .tabItem {
                Label(
                    String(localized: "tab.stats", defaultValue: "Stats"),
                    systemImage: "chart.bar.fill"
                )
            }

            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label(
                    String(localized: "tab.home", defaultValue: "Home"),
                    systemImage: "house.fill"
                )
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label(
                    String(localized: "tab.settings", defaultValue: "Settings"),
                    systemImage: "gearshape.fill"
                )
            }
        }
        .tint(.accentOcean)
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: Goal.self, inMemory: true)
}
