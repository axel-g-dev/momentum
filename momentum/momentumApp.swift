import SwiftUI
import SwiftData

@main
struct MomentumApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Goal.self,
            GoalStep.self,
            GoalHistory.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @AppStorage("appLanguage") private var appLanguage: String = "system"

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.locale, appLanguage == "system" ? .current : Locale(identifier: appLanguage))
        }
        .modelContainer(sharedModelContainer)
    }
}
