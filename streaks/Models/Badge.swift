import SwiftUI

/// Gamification badge model
struct Badge: Identifiable, Equatable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let color: Color
    let requirement: String
    
    /// Check if this badge is unlocked given the streak data
    func isUnlocked(with data: StreakData) -> Bool {
        switch id {
        case "first_practice":
            return data.totalDaysPracticed >= 1
        case "three_day_streak":
            return data.longestStreak >= 3
        case "week_warrior":
            return data.longestStreak >= 7
        case "two_week_titan":
            return data.longestStreak >= 14
        case "month_master":
            return data.longestStreak >= 30
        case "freeze_collector":
            return data.totalFreezesEarned >= 3
        case "perfect_week":
            return hasCompletePracticeWeek(data)
        case "early_bird":
            return data.totalDaysPracticed >= 10
        case "dedicated":
            return data.totalDaysPracticed >= 50
        case "century":
            return data.totalDaysPracticed >= 100
        case "r_master":
            return data.longestStreak >= 90
        case "legend":
            return data.longestStreak >= 365
        default:
            return false
        }
    }
    
    private func hasCompletePracticeWeek(_ data: StreakData) -> Bool {
        // Check if any 7 consecutive days are all practiced
        return data.longestStreak >= 7
    }
    
    // MARK: - All Badges
    
    static let all: [Badge] = [
        Badge(id: "first_practice", name: "First Step",
              description: "Complete your first practice session",
              icon: "star.fill", color: .tsAccent, requirement: "1 practice"),
        
        Badge(id: "three_day_streak", name: "Spark",
              description: "Achieve a 3-day practice streak",
              icon: "flame.fill", color: .orange, requirement: "3-day streak"),
        
        Badge(id: "week_warrior", name: "Week Warrior",
              description: "Maintain a 7-day practice streak",
              icon: "shield.fill", color: .tsPrimary, requirement: "7-day streak"),
        
        Badge(id: "two_week_titan", name: "Titan",
              description: "Maintain a 14-day practice streak",
              icon: "bolt.shield.fill", color: .purple, requirement: "14-day streak"),
        
        Badge(id: "month_master", name: "Month Master",
              description: "Maintain a 30-day practice streak",
              icon: "crown.fill", color: .tsGold, requirement: "30-day streak"),
        
        Badge(id: "freeze_collector", name: "Ice Keeper",
              description: "Earn 3 streak freezes",
              icon: "snowflake", color: .tsFreeze, requirement: "3 freezes earned"),
        
        Badge(id: "perfect_week", name: "Perfect Week",
              description: "Practice every day for a full week",
              icon: "checkmark.seal.fill", color: .tsSuccess, requirement: "7 days all practiced"),
        
        Badge(id: "early_bird", name: "Committed",
              description: "Practice for 10 total days",
              icon: "heart.fill", color: .pink, requirement: "10 total days"),
        
        Badge(id: "dedicated", name: "Dedicated",
              description: "Practice for 50 total days",
              icon: "medal.fill", color: .tsPrimary, requirement: "50 total days"),
        
        Badge(id: "century", name: "Century Club",
              description: "Practice for 100 total days",
              icon: "trophy.fill", color: .tsGold, requirement: "100 total days"),
        
        Badge(id: "r_master", name: "R Master",
              description: "90-day streak — true mastery!",
              icon: "graduationcap.fill", color: .tsPrimaryDark, requirement: "90-day streak"),
        
        Badge(id: "legend", name: "Legend",
              description: "365-day streak — legendary dedication!",
              icon: "sparkles", color: .tsGold, requirement: "365-day streak")
    ]
}
