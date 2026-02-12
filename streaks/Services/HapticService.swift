import UIKit

/// Provides haptic feedback for various user interactions
final class HapticService {
    static let shared = HapticService()
    
    private init() {}
    
    /// Light tap for minor interactions (button taps, toggles)
    func lightTap() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Medium tap for moderate interactions (completing steps)
    func mediumTap() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Heavy tap for significant actions (completing practice)
    func heavyTap() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Success feedback (practice completed, milestone reached)
    func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
    
    /// Warning feedback (streak freeze used)
    func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }
    
    /// Error feedback (action failed)
    func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }
    
    /// Selection change feedback (scrolling through items)
    func selectionChanged() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}
