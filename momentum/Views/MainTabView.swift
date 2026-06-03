import SwiftUI
import SwiftData

struct MainTabView: View {
    @State private var selectedTab = 1
    @State private var isLoading = true
    @State private var loadingProgress: Double = 0.0

    var body: some View {
        ZStack {
            if isLoading {
                splashView
            } else {
                tabView
            }
        }
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

    private var splashView: some View {
        VStack(spacing: 28) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [.accentOcean.opacity(0.15), .accentOcean.opacity(0.02)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "gauge.trend.up.fill")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundStyle(.accentOcean)
            }
            .shadow(color: .accentOcean.opacity(0.2), radius: 10, x: 0, y: 5)
            
            VStack(spacing: 8) {
                Text("Momentum")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(.textPrimary)
                    .tracking(1.5)
                
                Text(String(localized: "splash.subtitle", defaultValue: "Chaque jour compte"))
                    .font(.subheadline)
                    .foregroundStyle(.textTertiary)
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray5))
                        .frame(width: 180, height: 4)
                    
                    Capsule()
                        .fill(Color.accentOcean)
                        .frame(width: 180 * loadingProgress, height: 4)
                }
                .clipShape(Capsule())
            }
            .padding(.bottom, 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundPrimary)
        .onAppear {
            withAnimation(.linear(duration: 1.2)) {
                loadingProgress = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                withAnimation(.easeOut(duration: 0.3)) {
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: Goal.self, inMemory: true)
}
