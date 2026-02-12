import SwiftUI

/// Badge gallery showing unlocked and locked gamification badges
struct BadgesView: View {
    @ObservedObject var viewModel: StreakViewModel
    @Environment(\.colorScheme) var colorScheme
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ZStack {
            (colorScheme == .dark ? Color.tsDarkBg : Color(hex: "F0F4FF"))
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Progress header
                    progressHeader
                    
                    // Badge grid
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(Badge.all) { badge in
                            BadgeCard(
                                badge: badge,
                                isUnlocked: viewModel.streakData.unlockedBadgeIds.contains(badge.id)
                            )
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Badges")
        .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: - Progress Header
    
    private var progressHeader: some View {
        let unlocked = viewModel.streakData.unlockedBadgeIds.count
        let total = Badge.all.count
        let progress = total > 0 ? Double(unlocked) / Double(total) : 0
        
        return VStack(spacing: 12) {
            HStack {
                Text("🏅 \(unlocked) / \(total) Badges Unlocked")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.tsPrimary)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.tsSubtle.opacity(0.2))
                        .frame(height: 8)
                    
                    Capsule()
                        .fill(LinearGradient.tsPrimaryGradient)
                        .frame(width: geometry.size.width * progress, height: 8)
                        .animation(.easeInOut(duration: 0.5), value: progress)
                }
            }
            .frame(height: 8)
        }
        .padding(20)
        .background(
            colorScheme == .dark
                ? AnyShapeStyle(Color.tsCardDark.opacity(0.6))
                : AnyShapeStyle(Color.white)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.04), radius: 6, y: 3)
    }
}

// MARK: - Badge Card

struct BadgeCard: View {
    let badge: Badge
    let isUnlocked: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 12) {
            // Badge icon
            ZStack {
                Circle()
                    .fill(isUnlocked ? badge.color.opacity(0.15) : Color.tsSubtle.opacity(0.1))
                    .frame(width: 56, height: 56)
                
                Image(systemName: isUnlocked ? badge.icon : "lock.fill")
                    .font(.title2)
                    .foregroundColor(isUnlocked ? badge.color : .tsSubtle.opacity(0.4))
            }
            
            // Badge name
            Text(badge.name)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(isUnlocked ? .primary : .secondary)
                .lineLimit(1)
            
            // Description
            Text(isUnlocked ? badge.description : badge.requirement)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 12)
        .background(
            colorScheme == .dark
                ? AnyShapeStyle(Color.tsCardDark.opacity(isUnlocked ? 0.6 : 0.3))
                : AnyShapeStyle(Color.white.opacity(isUnlocked ? 1.0 : 0.6))
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isUnlocked ? badge.color.opacity(0.3) : Color.clear,
                    lineWidth: 1.5
                )
        )
        .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.04), radius: 6, y: 3)
        .opacity(isUnlocked ? 1.0 : 0.7)
        .accessibilityLabel("\(badge.name): \(isUnlocked ? "Unlocked. \(badge.description)" : "Locked. Requirement: \(badge.requirement)")")
    }
}
