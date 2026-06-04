import UIKit

final class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    /// Haptic feedback for a standard selection or tap
    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    /// Haptic feedback for checking off a step or a light impact
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    /// Haptic feedback for completing a goal (Success) or errors/warnings
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
}
