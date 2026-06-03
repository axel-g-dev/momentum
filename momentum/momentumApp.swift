import SwiftUI
import SwiftData

@main
struct MomentumApp: App {
    var sharedModelContainer: ModelContainer = {
        // Pre-create Application Support directory if it doesn't exist
        // to prevent SwiftData Sandbox write/stat crash on some iOS Simulators
        let fileManager = FileManager.default
        if let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            if !fileManager.fileExists(atPath: appSupportURL.path) {
                try? fileManager.createDirectory(at: appSupportURL, withIntermediateDirectories: true, attributes: nil)
            }
        }

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

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}
