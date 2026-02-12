import Foundation
import UserNotifications

/// Handles scheduling and managing local push notifications for practice reminders
final class NotificationService {
    static let shared = NotificationService()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private let dailyReminderIdentifier = "com.topspeech.dailyReminder"
    
    private init() {}
    
    // MARK: - Permission
    
    /// Request notification permission from the user
    func requestPermission(completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Notification permission error: \(error.localizedDescription)")
                }
                completion(granted)
            }
        }
    }
    
    /// Check current notification authorization status
    func checkPermission(completion: @escaping (Bool) -> Void) {
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }
    
    // MARK: - Scheduling
    
    /// Schedule a daily practice reminder notification
    func scheduleDailyReminder(hour: Int, minute: Int) {
        // Remove any existing reminders first
        cancelDailyReminder()
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Time to Practice! 🗣️"
        content.body = motivationalMessage()
        content.sound = .default
        content.badge = 1
        
        // Create the daily trigger
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: dailyReminderIdentifier,
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("❌ Failed to schedule notification: \(error.localizedDescription)")
            } else {
                print("✅ Daily reminder scheduled for \(hour):\(String(format: "%02d", minute))")
            }
        }
    }
    
    /// Cancel the daily reminder
    func cancelDailyReminder() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [dailyReminderIdentifier])
    }
    
    /// Clear badge count
    func clearBadge() {
        notificationCenter.setBadgeCount(0) { error in
            if let error = error {
                print("❌ Failed to clear badge: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Motivational Messages
    
    private func motivationalMessage() -> String {
        let messages = [
            "Your R sounds are getting better every day! Keep the streak alive. 🔥",
            "Just 15 minutes today to keep your speech journey on track!",
            "Consistency is the key to perfect pronunciation. Let's practice!",
            "Don't break your streak! Your future self will thank you. 💪",
            "Every practice session brings you closer to confident speech. 🌟",
            "Ready to conquer those R sounds? Let's do this!",
            "Your streak is counting on you! Time for today's practice. ⭐",
            "Small daily steps lead to big pronunciation improvements!",
            "You've got this! Let's make today count. 🎯",
            "Practice makes progress — start your session now!"
        ]
        return messages.randomElement() ?? messages[0]
    }
}
