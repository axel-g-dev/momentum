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

            content.title = String(localized: "notification.title", defaultValue: "momentum")

            if activeGoal.currentStreak > 2 {
                content.body = streakMessages.randomElement() ?? streakMessages[0]
            } else {
                content.body = defaultMessages.randomElement() ?? defaultMessages[0]
            }
        } else {
            content.title = String(localized: "notification.title", defaultValue: "momentum")
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

    func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily_reminder"])
    }

    func scheduleGoalReminder(for goal: Goal) {
        let center = UNUserNotificationCenter.current()
        // Always cancel existing reminder for this goal to avoid duplicates
        cancelGoalReminder(for: goal)

        guard let reminderDate = goal.reminderDate else { return }

        // Don't schedule if date is in the past
        if reminderDate < .now { return }

        let content = UNMutableNotificationContent()
        content.title = String(localized: "notification.title", defaultValue: "momentum")
        content.sound = .default

        // Motivational messages with goal name — Apple style
        let goalTitle = goal.title
        let messages = [
            String(format: String(localized: "notification.goal.push", defaultValue: "Time to work on \"%@\". Let's go!"), goalTitle),
            String(format: String(localized: "notification.goal.encourage", defaultValue: "Your goal \"%@\" is waiting for you."), goalTitle),
            String(format: String(localized: "notification.goal.motivate", defaultValue: "One step closer to \"%@\" — stay focused."), goalTitle),
            String(format: String(localized: "notification.goal.remind", defaultValue: "Don't forget: \"%@\". You've got this."), goalTitle)
        ]
        content.body = messages.randomElement() ?? messages[0]

        // Determine trigger based on repetition type
        let trigger: UNNotificationTrigger
        switch goal.repetition {
        case .daily:
            // Repeat every day at the same time
            let components = Calendar.current.dateComponents([.hour, .minute], from: reminderDate)
            trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        case .weekly:
            // Repeat every week on the same day and time
            let components = Calendar.current.dateComponents([.weekday, .hour, .minute], from: reminderDate)
            trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        case .none:
            // One-shot reminder
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
            trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        }

        let identifier: String
        if let existingId = goal.notificationId {
            identifier = existingId
        } else {
            let newId = UUID().uuidString
            goal.notificationId = newId
            identifier = newId
        }

        let request = UNNotificationRequest(identifier: "goal_reminder_\(identifier)", content: content, trigger: trigger)

        center.add(request) { error in
            if let error {
                print("Failed to schedule goal reminder: \(error)")
            }
        }
    }

    func cancelGoalReminder(for goal: Goal) {
        guard let notificationId = goal.notificationId else { return }
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["goal_reminder_\(notificationId)"])
    }
}
