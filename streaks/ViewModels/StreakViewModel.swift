import SwiftUI
import Combine

/// Main ViewModel handling all streak logic, practice tracking, and state management
@MainActor
final class StreakViewModel: ObservableObject {
    // MARK: - Published State
    
    @Published var streakData: StreakData
    @Published var showMilestoneCelebration = false
    @Published var currentMilestone: Milestone?
    @Published var showPracticeSession = false
    @Published var practiceSessionStep = 0
    @Published var isPracticing = false
    @Published var showStreakFreezeSheet = false
    @Published var selectedMonth: Date = Date()
    @Published var notificationPermissionGranted = false
    
    // MARK: - Services
    
    private let persistence = PersistenceService.shared
    private let notifications = NotificationService.shared
    private let haptics = HapticService.shared
    
    // MARK: - Init
    
    init() {
        self.streakData = PersistenceService.shared.load()
        checkForMissedDays()
        checkNotificationPermission()
    }
    
    // MARK: - Practice Actions
    
    /// Start a mock practice session
    func startPractice() {
        guard !streakData.hasPracticedToday else { return }
        showPracticeSession = true
        practiceSessionStep = 0
        isPracticing = true
        haptics.lightTap()
    }
    
    /// Advance to the next step in the practice simulation
    func nextPracticeStep() {
        practiceSessionStep += 1
        haptics.mediumTap()
    }
    
    /// Complete the practice session and mark today as practiced
    func completePractice() {
        let todayKey = Date().dateKey
        
        var practiceDay = streakData.practiceDays[todayKey] ?? PracticeDay(dateKey: todayKey)
        practiceDay.didPractice = true
        practiceDay.completedAt = Date()
        practiceDay.practiceDurationSeconds = Int.random(in: 600...900) // Mock 10-15 mins
        
        streakData.practiceDays[todayKey] = practiceDay
        
        // Check for freeze earnings (1 freeze per 7-day streak, max 3)
        checkFreezeEarnings()
        
        // Check for badge unlocks
        updateBadges()
        
        // Save
        save()
        
        // Haptic feedback
        haptics.success()
        
        // Close practice session
        isPracticing = false
        showPracticeSession = false
        
        // Check for milestone celebrations
        checkMilestones()
    }
    
    /// Cancel the practice session
    func cancelPractice() {
        isPracticing = false
        showPracticeSession = false
        practiceSessionStep = 0
    }
    
    // MARK: - Streak Freeze
    
    /// Use a streak freeze for today
    func useStreakFreeze() {
        guard streakData.availableFreezes > 0 else { return }
        
        let todayKey = Date().dateKey
        var practiceDay = streakData.practiceDays[todayKey] ?? PracticeDay(dateKey: todayKey)
        practiceDay.usedFreeze = true
        
        streakData.practiceDays[todayKey] = practiceDay
        streakData.availableFreezes -= 1
        
        save()
        haptics.warning()
    }
    
    /// Check if the user has earned new freezes
    private func checkFreezeEarnings() {
        let currentStreak = streakData.currentStreak
        let freezesDeserved = currentStreak / 7
        let newFreezes = freezesDeserved - streakData.totalFreezesEarned
        
        if newFreezes > 0 {
            let freezesToAdd = min(newFreezes, streakData.maxFreezes - streakData.availableFreezes)
            if freezesToAdd > 0 {
                streakData.availableFreezes += freezesToAdd
                streakData.totalFreezesEarned += freezesToAdd
            }
        }
    }
    
    // MARK: - Missed Days / Freeze Auto-Apply
    
    /// Check for missed days and auto-apply freezes if available
    private func checkForMissedDays() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var checkDate = calendar.date(byAdding: .day, value: -1, to: today)!
        
        // Only check the last 2 days for auto-freeze
        for _ in 0..<2 {
            let key = checkDate.dateKey
            let day = streakData.practiceDays[key]
            
            // If day exists and is already handled, skip
            if let day = day, (day.didPractice || day.usedFreeze) {
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
                continue
            }
            
            // If day is missed and we have freezes, auto-apply
            if day == nil || (!day!.didPractice && !day!.usedFreeze) {
                // Only auto-apply if there's a streak to protect
                let previousKey = calendar.date(byAdding: .day, value: -1, to: checkDate)!.dateKey
                let previousDay = streakData.practiceDays[previousKey]
                
                if let prev = previousDay, (prev.didPractice || prev.usedFreeze), streakData.availableFreezes > 0 {
                    var newDay = PracticeDay(dateKey: key)
                    newDay.usedFreeze = true
                    streakData.practiceDays[key] = newDay
                    streakData.availableFreezes -= 1
                    save()
                }
            }
            
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
        }
    }
    
    // MARK: - Milestones
    
    /// Check if a milestone should be celebrated
    private func checkMilestones() {
        let streak = streakData.currentStreak
        
        if let milestone = Milestone.nextMilestone(for: streak, lastCelebrated: streakData.lastCelebratedMilestone) {
            currentMilestone = milestone
            streakData.lastCelebratedMilestone = milestone.days
            save()
            
            // Slight delay for better UX
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.showMilestoneCelebration = true
                self?.haptics.success()
            }
        }
    }
    
    /// Dismiss milestone celebration
    func dismissMilestone() {
        showMilestoneCelebration = false
        currentMilestone = nil
    }
    
    // MARK: - Badges
    
    /// Update unlocked badges
    private func updateBadges() {
        for badge in Badge.all {
            if badge.isUnlocked(with: streakData) {
                streakData.unlockedBadgeIds.insert(badge.id)
            }
        }
    }
    
    // MARK: - Calendar Navigation
    
    /// Move to the previous month
    func previousMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) {
            selectedMonth = newDate
            haptics.selectionChanged()
        }
    }
    
    /// Move to the next month
    func nextMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) {
            selectedMonth = newDate
            haptics.selectionChanged()
        }
    }
    
    // MARK: - Notifications
    
    /// Check current notification permission status
    func checkNotificationPermission() {
        notifications.checkPermission { [weak self] granted in
            self?.notificationPermissionGranted = granted
        }
    }
    
    /// Request notification permission
    func requestNotificationPermission() {
        notifications.requestPermission { [weak self] granted in
            self?.notificationPermissionGranted = granted
            if granted {
                self?.scheduleNotification()
            }
        }
    }
    
    /// Schedule or update the daily reminder
    func scheduleNotification() {
        guard streakData.notificationsEnabled else {
            notifications.cancelDailyReminder()
            return
        }
        notifications.scheduleDailyReminder(
            hour: streakData.notificationHour,
            minute: streakData.notificationMinute
        )
    }
    
    /// Toggle notifications on/off
    func toggleNotifications(_ enabled: Bool) {
        streakData.notificationsEnabled = enabled
        if enabled {
            requestNotificationPermission()
        } else {
            notifications.cancelDailyReminder()
        }
        save()
    }
    
    /// Update notification time
    func updateNotificationTime(hour: Int, minute: Int) {
        streakData.notificationHour = hour
        streakData.notificationMinute = minute
        if streakData.notificationsEnabled {
            scheduleNotification()
        }
        save()
    }
    
    // MARK: - Persistence
    
    /// Save current state to disk
    private func save() {
        persistence.save(streakData)
    }
    
    /// Reset all data (for testing)
    func resetAllData() {
        persistence.clearAll()
        streakData = StreakData()
        haptics.warning()
    }
    
    // MARK: - Demo Data (for easy testing / screenshots)
    
    /// Generate sample practice history for demo purposes
    func loadDemoData() {
        var data = StreakData()
        data.joinDate = Date().addingDays(-45)
        
        // Create a realistic practice history
        let calendar = Calendar.current
        for dayOffset in stride(from: -44, through: 0, by: 1) {
            let date = calendar.date(byAdding: .day, value: dayOffset, to: calendar.startOfDay(for: Date()))!
            let key = date.dateKey
            
            // ~85% practice rate with some gaps
            let shouldPractice = dayOffset > -3 || Bool.random() ? (Int.random(in: 1...100) <= 85) : true
            
            if shouldPractice {
                var day = PracticeDay(dateKey: key)
                day.didPractice = true
                day.completedAt = date
                day.practiceDurationSeconds = Int.random(in: 600...900)
                data.practiceDays[key] = day
            }
        }
        
        // Ensure today is not yet practiced so user can test
        let todayKey = Date().dateKey
        data.practiceDays.removeValue(forKey: todayKey)
        
        data.availableFreezes = 2
        data.totalFreezesEarned = 4
        data.lastCelebratedMilestone = 7
        
        // Unlock some badges
        for badge in Badge.all {
            if badge.isUnlocked(with: data) {
                data.unlockedBadgeIds.insert(badge.id)
            }
        }
        
        streakData = data
        save()
        haptics.success()
    }
}
