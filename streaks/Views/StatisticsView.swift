import SwiftUI

/// Statistics and insights view showing practice analytics
struct StatisticsView: View {
    @ObservedObject var viewModel: StreakViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            (colorScheme == .dark ? Color.tsDarkBg : Color(hex: "F0F4FF"))
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Overview card
                    overviewCard
                    
                    // Streak stats
                    streakStatsCard
                    
                    // Practice insights
                    insightsCard
                    
                    // Weekly pattern
                    weeklyPatternCard
                }
                .padding(20)
            }
        }
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: - Overview Card
    
    private var overviewCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 6) {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.tsPrimary)
                Text("Overview")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                OverviewStatItem(title: "Total Days", value: "\(viewModel.streakData.totalDaysPracticed)", icon: "calendar.badge.checkmark", color: .tsPrimary)
                OverviewStatItem(title: "Member Since", value: viewModel.streakData.joinDate.shortDate, icon: "person.fill", color: .tsSuccess)
                OverviewStatItem(title: "Completion", value: "\(Int(viewModel.streakData.completionRate))%", icon: "percent", color: .tsAccent)
                OverviewStatItem(title: "Freezes Used", value: "\(viewModel.streakData.totalFreezesEarned)", icon: "snowflake", color: .tsFreeze)
            }
        }
        .padding(20)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Streak Stats
    
    private var streakStatsCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.tsAccent)
                Text("Streak Stats")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                StatRow(label: "Current Streak", value: "\(viewModel.streakData.currentStreak) days", color: .tsAccent)
                Divider().opacity(0.3)
                StatRow(label: "Longest Streak", value: "\(viewModel.streakData.longestStreak) days", color: .tsGold)
                Divider().opacity(0.3)
                StatRow(label: "Average Streak", value: String(format: "%.1f days", viewModel.streakData.averageStreakLength), color: .tsPrimary)
                Divider().opacity(0.3)
                StatRow(label: "Freezes Available", value: "\(viewModel.streakData.availableFreezes)/\(viewModel.streakData.maxFreezes)", color: .tsFreeze)
            }
        }
        .padding(20)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Insights
    
    private var insightsCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 6) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.tsGold)
                Text("Insights")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                StatRow(label: "Best Practice Day", value: viewModel.streakData.bestPracticeDay, color: .tsSuccess)
                Divider().opacity(0.3)
                StatRow(label: "Days as Member", value: "\(viewModel.streakData.daysSinceJoining)", color: .tsPrimary)
                Divider().opacity(0.3)
                
                // Milestone progress
                let nextMilestone = nextUpcomingMilestone
                StatRow(
                    label: "Next Milestone",
                    value: nextMilestone != nil ? "\(nextMilestone!.days) days (\(nextMilestone!.emoji))" : "All achieved! 🎉",
                    color: .tsAccent
                )
            }
        }
        .padding(20)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Weekly Pattern
    
    private var weeklyPatternCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 6) {
                Image(systemName: "chart.bar.xaxis")
                    .foregroundColor(.tsPrimary)
                Text("Weekly Pattern")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(weeklyData, id: \.day) { item in
                    VStack(spacing: 6) {
                        // Bar
                        RoundedRectangle(cornerRadius: 4)
                            .fill(item.count > 0
                                  ? LinearGradient(colors: [.tsPrimary, .tsPrimaryDark], startPoint: .top, endPoint: .bottom)
                                  : LinearGradient(colors: [Color.tsSubtle.opacity(0.2)], startPoint: .top, endPoint: .bottom)
                            )
                            .frame(height: max(8, CGFloat(item.count) * 12))
                        
                        // Label
                        Text(item.day)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 120, alignment: .bottom)
        }
        .padding(20)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Helpers
    
    private var nextUpcomingMilestone: Milestone? {
        Milestone.all.first { $0.days > viewModel.streakData.currentStreak }
    }
    
    private var weeklyData: [(day: String, count: Int)] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        
        var counts = [Int](repeating: 0, count: 7)
        
        for (key, day) in viewModel.streakData.practiceDays where day.didPractice {
            if let date = formatter.date(from: key) {
                let weekday = calendar.component(.weekday, from: date) - 1
                counts[weekday] += 1
            }
        }
        
        return dayNames.enumerated().map { (index, name) in
            (day: name, count: counts[index])
        }
    }
    
    private var cardBackground: some View {
        Group {
            if colorScheme == .dark {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
            }
        }
    }
}

// MARK: - Components

struct OverviewStatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct StatRow: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}
