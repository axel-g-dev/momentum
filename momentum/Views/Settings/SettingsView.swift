import SwiftUI
import SwiftData

struct SettingsView: View {
    @Query private var goals: [Goal]
    @State private var viewModel = SettingsViewModel()
    var body: some View {
        Form {
            notificationsSection
            aboutSection
        }
        .navigationTitle(String(localized: "settings.title", defaultValue: "Settings"))
        .task {
            await viewModel.checkPermission()
        }
    }

    // MARK: - Notifications

    private var notificationsSection: some View {
        Section {
            Toggle(
                String(localized: "settings.notifications.toggle", defaultValue: "Daily Reminder"),
                isOn: $viewModel.notificationsEnabled
            )
            .tint(.accentOcean)
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
                .tint(.accentOcean)
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
                Text(String(localized: "settings.developer", defaultValue: "Developer"))
                Spacer()
                Text("axel'")
                    .foregroundStyle(.textSecondary)
            }
            
            HStack {
                Text(String(localized: "settings.version", defaultValue: "Version"))
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "–")
                    .foregroundStyle(.textSecondary)
            }

            HStack {
                Text(String(localized: "settings.build", defaultValue: "Build"))
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "–")
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
