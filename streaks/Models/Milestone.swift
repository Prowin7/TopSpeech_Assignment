import Foundation

/// Defines streak milestones that trigger celebrations
struct Milestone: Identifiable, Equatable {
    let id: Int
    let days: Int
    let title: String
    let description: String
    let emoji: String
    
    /// All milestone definitions
    static let all: [Milestone] = [
        Milestone(id: 3, days: 3, title: "Getting Started!", description: "3 days of practice — you're building a habit!", emoji: "🌱"),
        Milestone(id: 7, days: 7, title: "One Week Strong!", description: "7 days in a row — consistency is key!", emoji: "🔥"),
        Milestone(id: 14, days: 14, title: "Two Weeks!", description: "14 days of dedication — you're on fire!", emoji: "⭐"),
        Milestone(id: 21, days: 21, title: "Habit Formed!", description: "21 days — they say it takes 21 days to build a habit!", emoji: "💪"),
        Milestone(id: 30, days: 30, title: "One Month!", description: "30 days of consistent practice — incredible!", emoji: "🏆"),
        Milestone(id: 60, days: 60, title: "Two Months!", description: "60 days — your dedication is truly inspiring!", emoji: "💎"),
        Milestone(id: 90, days: 90, title: "Quarter Master!", description: "90 days of practice — you're unstoppable!", emoji: "👑"),
        Milestone(id: 180, days: 180, title: "Half Year Hero!", description: "180 days — six months of commitment!", emoji: "🌟"),
        Milestone(id: 365, days: 365, title: "One Year Legend!", description: "365 days — a full year of practice!", emoji: "🎉")
    ]
    
    /// Get the next uncelebrated milestone for a given streak
    static func nextMilestone(for streak: Int, lastCelebrated: Int) -> Milestone? {
        return all.first { $0.days <= streak && $0.days > lastCelebrated }
    }
    
    /// Get all achieved milestones for a given streak
    static func achievedMilestones(for streak: Int) -> [Milestone] {
        return all.filter { $0.days <= streak }
    }
}
