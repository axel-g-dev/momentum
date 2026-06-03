import Foundation
import UserNotifications

@Observable
final class SettingsViewModel {
    var notificationsEnabled: Bool {
        didSet { UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled") }
    }
    var reminderHour: Int {
        didSet { UserDefaults.standard.set(reminderHour, forKey: "reminderHour") }
    }
    var reminderMinute: Int {
        didSet { UserDefaults.standard.set(reminderMinute, forKey: "reminderMinute") }
    }
    var permissionGranted: Bool = false

    init() {
        let defaults = UserDefaults.standard
        self.notificationsEnabled = defaults.bool(forKey: "notificationsEnabled")

        // Default to 9:00 AM if not set
        if defaults.object(forKey: "reminderHour") == nil {
            self.reminderHour = 9
            self.reminderMinute = 0
        } else {
            self.reminderHour = defaults.integer(forKey: "reminderHour")
            self.reminderMinute = defaults.integer(forKey: "reminderMinute")
        }
    }

    var reminderDate: Date {
        get {
            var components = DateComponents()
            components.hour = reminderHour
            components.minute = reminderMinute
            return Calendar.current.date(from: components) ?? .now
        }
        set {
            let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            reminderHour = components.hour ?? 9
            reminderMinute = components.minute ?? 0
        }
    }

    func requestPermission() async {
        let granted = await NotificationService.shared.requestPermission()
        await MainActor.run {
            permissionGranted = granted
            if !granted {
                notificationsEnabled = false
            }
        }
    }

    func checkPermission() async {
        let status = await NotificationService.shared.checkPermissionStatus()
        await MainActor.run {
            permissionGranted = status == .authorized
        }
    }

    func updateNotificationSchedule(goals: [Goal]) {
        if notificationsEnabled {
            NotificationService.shared.scheduleDailyReminder(
                at: reminderHour,
                minute: reminderMinute,
                goals: goals
            )
        } else {
            NotificationService.shared.cancelAllNotifications()
        }
    }
}
