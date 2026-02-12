import SwiftUI

/// Streak freeze management view showing available freezes and usage rules
struct StreakFreezeView: View {
    @ObservedObject var viewModel: StreakViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                (colorScheme == .dark ? Color.tsDarkBg : Color(hex: "F0F4FF"))
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Hero freeze display
                        freezeHero
                        
                        // How it works
                        howItWorks
                        
                        // Use freeze button
                        if !viewModel.streakData.hasPracticedToday && viewModel.streakData.availableFreezes > 0 {
                            useFreezeButton
                        }
                        
                        // Info card
                        infoCard
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Streak Freeze")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.tsPrimary)
                }
            }
        }
    }
    
    // MARK: - Freeze Hero
    
    private var freezeHero: some View {
        VStack(spacing: 20) {
            // Snowflake icon
            ZStack {
                Circle()
                    .fill(Color.tsFreeze.opacity(0.15))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "snowflake")
                    .font(.system(size: 44))
                    .foregroundColor(.tsFreeze)
            }
            
            // Freeze count
            HStack(spacing: 8) {
                ForEach(0..<viewModel.streakData.maxFreezes, id: \.self) { index in
                    VStack(spacing: 6) {
                        Image(systemName: "snowflake")
                            .font(.title)
                            .foregroundColor(index < viewModel.streakData.availableFreezes ? .tsFreeze : .tsSubtle.opacity(0.3))
                        
                        Text(index < viewModel.streakData.availableFreezes ? "Ready" : "Used")
                            .font(.caption2)
                            .foregroundColor(index < viewModel.streakData.availableFreezes ? .tsFreeze : .tsSubtle)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(index < viewModel.streakData.availableFreezes
                                  ? Color.tsFreeze.opacity(0.1)
                                  : Color.tsSubtle.opacity(0.05))
                    )
                }
            }
            
            Text("\(viewModel.streakData.availableFreezes) of \(viewModel.streakData.maxFreezes) freezes available")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(24)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - How It Works
    
    private var howItWorks: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How Streak Freezes Work")
                .font(.headline)
                .fontWeight(.bold)
            
            FreezeRuleRow(icon: "gift.fill", color: .tsSuccess,
                          text: "Earn 1 freeze for every 7-day streak")
            
            FreezeRuleRow(icon: "tray.full.fill", color: .tsPrimary,
                          text: "Hold up to \(viewModel.streakData.maxFreezes) freezes at a time")
            
            FreezeRuleRow(icon: "shield.fill", color: .tsFreeze,
                          text: "Freezes protect your streak on rest days")
            
            FreezeRuleRow(icon: "bolt.fill", color: .tsAccent,
                          text: "Auto-applied when you miss a day (if available)")
        }
        .padding(20)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Use Freeze Button
    
    private var useFreezeButton: some View {
        Button(action: {
            viewModel.useStreakFreeze()
            dismiss()
        }) {
            HStack(spacing: 10) {
                Image(systemName: "snowflake")
                Text("Use Freeze for Today")
            }
            .font(.headline)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [.tsFreeze, Color(hex: "0096C7")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .tsFreeze.opacity(0.3), radius: 10, y: 5)
        }
    }
    
    // MARK: - Info Card
    
    private var infoCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.tsPrimary)
                .font(.title3)
            
            Text("Freezes are automatically applied when you miss a day, so your streak stays protected. Use them wisely — they're earned through consistent practice!")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color.tsPrimary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
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

// MARK: - Freeze Rule Row

struct FreezeRuleRow: View {
    let icon: String
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
}
