import Foundation

/// The main data model holding all streak-related information
struct StreakData: Codable {
    /// Dictionary of practice days keyed by date string "yyyy-MM-dd"
    var practiceDays: [String: PracticeDay]
    
    /// Number of streak freezes currently available
    var availableFreezes: Int
    
    /// Maximum freezes a user can hold at once
    var maxFreezes: Int
    
    /// Total freezes earned all time
    var totalFreezesEarned: Int
    
    /// The date the user started using the app
    var joinDate: Date
    
    /// Preferred notification hour (0-23)
    var notificationHour: Int
    
    /// Preferred notification minute (0-59)
    var notificationMinute: Int
    
    /// Whether notifications are enabled
    var notificationsEnabled: Bool
    
    /// Whether dark mode is enabled
    var isDarkMode: Bool
    
    // MARK: - Onboarding Profile
    
    /// User's name from onboarding
    var userName: String
    
    /// Which R sounds are hardest (e.g. "AR sounds", "R blends")
    var difficultSounds: [String]
    
    /// Challenging speaking situations (e.g. "Phone calls", "Ordering food")
    var challengingSituations: [String]
    
    /// Confidence level 1-5
    var confidenceLevel: Int
    
    /// Experience level identifier
    var experienceLevel: String
    
    /// Whether onboarding has been completed
    var hasCompletedOnboarding: Bool
    
    /// Unlocked badge IDs
    var unlockedBadgeIds: Set<String>
    
    /// Last milestone that was celebrated (to avoid re-showing)
    var lastCelebratedMilestone: Int
    
    // MARK: - Defaults
    
    init() {
        self.practiceDays = [:]
        self.availableFreezes = 0
        self.maxFreezes = 3
        self.totalFreezesEarned = 0
        self.joinDate = Date()
        self.notificationHour = 9
        self.notificationMinute = 0
        self.notificationsEnabled = true
        self.isDarkMode = true
        self.userName = ""
        self.difficultSounds = []
        self.challengingSituations = []
        self.confidenceLevel = 3
        self.experienceLevel = ""
        self.hasCompletedOnboarding = false
        self.unlockedBadgeIds = []
        self.lastCelebratedMilestone = 0
    }
    
    // MARK: - Computed Properties
    
    /// Current streak count
    var currentStreak: Int {
        calculateCurrentStreak()
    }
    
    /// Longest streak ever achieved
    var longestStreak: Int {
        calculateLongestStreak()
    }
    
    /// Total days practiced
    var totalDaysPracticed: Int {
        practiceDays.values.filter { $0.didPractice }.count
    }
    
    /// Whether the user has practiced today
    var hasPracticedToday: Bool {
        let todayKey = Date().dateKey
        return practiceDays[todayKey]?.didPractice ?? false
    }
    
    /// Days since joining
    var daysSinceJoining: Int {
        max(1, joinDate.daysBetween(Date()))
    }
    
    /// Practice completion rate as a percentage
    var completionRate: Double {
        guard daysSinceJoining > 0 else { return 0 }
        return Double(totalDaysPracticed) / Double(daysSinceJoining) * 100
    }
    
    /// Best day of the week for practice (0 = Sunday)
    var bestPracticeDay: String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        var weekdayCounts = [Int: Int]()
        for (key, day) in practiceDays where day.didPractice {
            if let date = formatter.date(from: key) {
                let weekday = calendar.component(.weekday, from: date)
                weekdayCounts[weekday, default: 0] += 1
            }
        }
        
        guard let bestDay = weekdayCounts.max(by: { $0.value < $1.value })?.key else {
            return "N/A"
        }
        
        let dayNames = ["", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        return dayNames[bestDay]
    }
    
    /// Average streak length
    var averageStreakLength: Double {
        let streaks = allStreakLengths()
        guard !streaks.isEmpty else { return 0 }
        return Double(streaks.reduce(0, +)) / Double(streaks.count)
    }
    
    // MARK: - Streak Calculations
    
    private func calculateCurrentStreak() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())
        
        // If haven't practiced today, start checking from yesterday
        let todayKey = Date().dateKey
        if !(practiceDays[todayKey]?.didPractice ?? false) &&
            !(practiceDays[todayKey]?.usedFreeze ?? false) {
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
        }
        
        while true {
            let key = checkDate.dateKey
            if let day = practiceDays[key], (day.didPractice || day.usedFreeze) {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else {
                break
            }
        }
        
        return streak
    }
    
    private func calculateLongestStreak() -> Int {
        guard !practiceDays.isEmpty else { return 0 }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let calendar = Calendar.current
        
        let sortedDates = practiceDays.keys
            .compactMap { formatter.date(from: $0) }
            .filter { practiceDays[$0.dateKey]?.didPractice == true || practiceDays[$0.dateKey]?.usedFreeze == true }
            .sorted()
        
        guard !sortedDates.isEmpty else { return 0 }
        
        var longest = 1
        var current = 1
        
        for i in 1..<sortedDates.count {
            let diff = calendar.dateComponents([.day], from: calendar.startOfDay(for: sortedDates[i-1]),
                                                to: calendar.startOfDay(for: sortedDates[i])).day ?? 0
            if diff == 1 {
                current += 1
                longest = max(longest, current)
            } else if diff > 1 {
                current = 1
            }
        }
        
        return longest
    }
    
    private func allStreakLengths() -> [Int] {
        guard !practiceDays.isEmpty else { return [] }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let calendar = Calendar.current
        
        let sortedDates = practiceDays.keys
            .compactMap { formatter.date(from: $0) }
            .filter { practiceDays[$0.dateKey]?.didPractice == true || practiceDays[$0.dateKey]?.usedFreeze == true }
            .sorted()
        
        guard !sortedDates.isEmpty else { return [] }
        
        var streaks: [Int] = []
        var current = 1
        
        for i in 1..<sortedDates.count {
            let diff = calendar.dateComponents([.day], from: calendar.startOfDay(for: sortedDates[i-1]),
                                                to: calendar.startOfDay(for: sortedDates[i])).day ?? 0
            if diff == 1 {
                current += 1
            } else {
                streaks.append(current)
                current = 1
            }
        }
        streaks.append(current)
        
        return streaks
    }
}
