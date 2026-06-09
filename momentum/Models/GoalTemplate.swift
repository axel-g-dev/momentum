import Foundation

struct GoalTemplate: Identifiable {
    var id: String { title }
    let title: String
    let description: String
    let priority: GoalPriority
    let repetition: GoalRepetition
    let steps: [String]
}

extension GoalTemplate {
    static let templates: [GoalTemplate] = [
        GoalTemplate(
            title: String(localized: "template.sport.title", defaultValue: "Work out 3x/week"),
            description: String(localized: "template.sport.desc", defaultValue: "Stay fit and active with regular physical exercise."),
            priority: .high,
            repetition: .weekly,
            steps: [
                String(localized: "template.sport.step1", defaultValue: "Session 1: Cardio or Strength"),
                String(localized: "template.sport.step2", defaultValue: "Session 2: Mobility or Yoga"),
                String(localized: "template.sport.step3", defaultValue: "Session 3: High Intensity workout")
            ]
        ),
        GoalTemplate(
            title: String(localized: "template.meditate.title", defaultValue: "Meditate"),
            description: String(localized: "template.meditate.desc", defaultValue: "Practice mindfulness and breathing to improve focus and calm."),
            priority: .medium,
            repetition: .daily,
            steps: [
                String(localized: "template.meditate.step1", defaultValue: "Find a quiet and comfortable spot"),
                String(localized: "template.meditate.step2", defaultValue: "Focus on breath for 10 minutes"),
                String(localized: "template.meditate.step3", defaultValue: "Reflect on how you feel")
            ]
        ),
        GoalTemplate(
            title: String(localized: "template.read.title", defaultValue: "Read 30 min/day"),
            description: String(localized: "template.read.desc", defaultValue: "Build a daily reading habit to expand your knowledge."),
            priority: .medium,
            repetition: .daily,
            steps: [
                String(localized: "template.read.step1", defaultValue: "Choose a book"),
                String(localized: "template.read.step2", defaultValue: "Set a quiet timer for 30 minutes"),
                String(localized: "template.read.step3", defaultValue: "Write down one key takeaway")
            ]
        ),
        GoalTemplate(
            title: String(localized: "template.work.title", defaultValue: "Deep Work blocks"),
            description: String(localized: "template.work.desc", defaultValue: "Dedicate uninterrupted blocks of time to high-value projects."),
            priority: .high,
            repetition: .daily,
            steps: [
                String(localized: "template.work.step1", defaultValue: "Silence phone and notifications"),
                String(localized: "template.work.step2", defaultValue: "Work on a task for 90 minutes"),
                String(localized: "template.work.step3", defaultValue: "Take a 15-minute break")
            ]
        )
    ]
}
