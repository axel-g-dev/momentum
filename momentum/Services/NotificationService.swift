import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()

    private init() {}

    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            return granted
        } catch {
            print("Notification permission error: \(error)")
            return false
        }
    }

    func checkPermissionStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }

    func scheduleDailyReminder(at hour: Int, minute: Int, goals: [Goal] = []) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["daily_reminder"])

        let content = UNMutableNotificationContent()
        content.sound = .default

        // Contextual message based on goals
        if let activeGoal = goals.first(where: { $0.status == .active }) {
            let streakMessages = [
                String(localized: "notification.streak", defaultValue: "Keep going, you're on a great streak!"),
                String(localized: "notification.continue", defaultValue: "Stay consistent — progress adds up.")
            ]
            let defaultMessages = [
                String(localized: "notification.reminder.goal", defaultValue: "You planned to work on your goals today."),
                String(localized: "notification.reminder.progress", defaultValue: "A small step forward is still progress.")
            ]

            content.title = String(localized: "notification.title", defaultValue: "Momentum")

            if activeGoal.currentStreak > 2 {
                content.body = streakMessages.randomElement() ?? streakMessages[0]
            } else {
                content.body = defaultMessages.randomElement() ?? defaultMessages[0]
            }
        } else {
            content.title = String(localized: "notification.title", defaultValue: "Momentum")
            content.body = String(localized: "notification.reminder.default", defaultValue: "Take a moment to review your goals.")
        }

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_reminder", content: content, trigger: trigger)

        center.add(request) { error in
            if let error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
