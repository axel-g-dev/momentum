import SwiftUI
import SwiftData

struct SettingsView: View {
    @Query private var goals: [Goal]
    @State private var viewModel = SettingsViewModel()
    @AppStorage("appLanguage") private var appLanguage: String = "system"

    var body: some View {
        Form {
            preferencesSection
            notificationsSection
            aboutSection
        }
        .navigationTitle(String(localized: "settings.title", defaultValue: "Settings"))
        .task {
            await viewModel.checkPermission()
        }
    }

    // MARK: - Preferences

    private var preferencesSection: some View {
        Section {
            Picker(String(localized: "settings.language", defaultValue: "Language"), selection: $appLanguage) {
                Text(String(localized: "settings.language.system", defaultValue: "System")).tag("system")
                Text("English").tag("en")
                Text("Français").tag("fr")
            }
        } header: {
            Text(String(localized: "settings.preferences.header", defaultValue: "Preferences"))
        }
    }

    // MARK: - Notifications

    private var notificationsSection: some View {
        Section {
            Toggle(
                String(localized: "settings.notifications.toggle", defaultValue: "Daily Reminder"),
                isOn: $viewModel.notificationsEnabled
            )
            .tint(.accentGreen)
            .onChange(of: viewModel.notificationsEnabled) { _, enabled in
                if enabled && !viewModel.permissionGranted {
                    Task {
                        await viewModel.requestPermission()
                        viewModel.updateNotificationSchedule(goals: goals)
                    }
                } else {
                    viewModel.updateNotificationSchedule(goals: goals)
                }
            }

            if viewModel.notificationsEnabled {
                DatePicker(
                    String(localized: "settings.notifications.time", defaultValue: "Reminder Time"),
                    selection: $viewModel.reminderDate,
                    displayedComponents: .hourAndMinute
                )
                .tint(.accentGreen)
                .onChange(of: viewModel.reminderDate) {
                    viewModel.updateNotificationSchedule(goals: goals)
                }
            }

            if !viewModel.permissionGranted {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.warning)
                        .font(.caption)

                    Text(String(localized: "settings.notifications.denied", defaultValue: "Notifications are disabled in system settings."))
                        .font(.caption)
                        .foregroundStyle(.textSecondary)
                }
            }
        } header: {
            Text(String(localized: "settings.notifications.header", defaultValue: "Notifications"))
        } footer: {
            Text(String(localized: "settings.notifications.footer", defaultValue: "Receive a daily reminder to work on your goals."))
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        Section {
            HStack {
                Text(String(localized: "settings.version", defaultValue: "Version"))
                Spacer()
                Text("1.0.1")
                    .foregroundStyle(.textSecondary)
            }

            HStack {
                Text(String(localized: "settings.build", defaultValue: "Build"))
                Spacer()
                Text("1")
                    .foregroundStyle(.textSecondary)
            }
        } header: {
            Text(String(localized: "settings.about.header", defaultValue: "About"))
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .modelContainer(for: Goal.self, inMemory: true)
}
