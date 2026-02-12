import SwiftUI

/// Main dashboard view displaying streak info, calendar, and action buttons
struct DashboardView: View {
    @StateObject private var viewModel = StreakViewModel()
    @Environment(\.colorScheme) var colorScheme
    @State private var showSettings = false
    @State private var showAnalysis = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Hero Streak Card
                        streakHeroCard
                        
                        // Quick Stats Row
                        statsRow
                        
                        // Motivational Quote
                        motivationalCard
                        
                        // Streak Freeze Card
                        freezeCard
                        
                        // Calendar Heatmap
                        CalendarHeatmapView(viewModel: viewModel)
                        
                        // Practice Button
                        practiceButton
                        
                        // R Sound Lab Card
                        analysisLabCard
                        
                        // Navigation Cards
                        navigationCards
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle(viewModel.streakData.userName.isEmpty ? "Practice Streak" : "Hey \(viewModel.streakData.userName) 🔥")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showSettings = true }) {
                            Label("Settings", systemImage: "gear")
                        }
                        
                        Button(action: viewModel.loadDemoData) {
                            Label("Load Demo Data", systemImage: "wand.and.stars")
                        }
                        
                        Button(role: .destructive, action: viewModel.resetAllData) {
                            Label("Reset All Data", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.title3)
                            .foregroundColor(.tsPrimary)
                    }
                }
            }
            .background(
                NavigationLink(destination: SettingsView(viewModel: viewModel), isActive: $showSettings) {
                    EmptyView()
                }
                .hidden()
            )
            .sheet(isPresented: $viewModel.showPracticeSession) {
                PracticeSessionView(viewModel: viewModel)
            }
            .sheet(isPresented: $showAnalysis) {
                PronunciationAnalysisView()
            }
            .overlay {
                if viewModel.showMilestoneCelebration, let milestone = viewModel.currentMilestone {
                    MilestoneCelebrationView(milestone: milestone) {
                        viewModel.dismissMilestone()
                    }
                }
            }
        }
        .accentColor(.tsPrimary)
    }
    
    // MARK: - Background
    
    private var backgroundGradient: some View {
        Group {
            if colorScheme == .dark {
                LinearGradient(
                    colors: [.tsDarkBg, Color(hex: "0F1535")],
                    startPoint: .top,
                    endPoint: .bottom
                )
            } else {
                LinearGradient(
                    colors: [Color(hex: "F0F4FF"), Color(hex: "E8F4FD")],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
    }
    
    // MARK: - Hero Streak Card
    
    private var streakHeroCard: some View {
        VStack(spacing: 16) {
            // Fire emoji with animation
            Text("🔥")
                .font(.system(size: 56))
                .shadow(color: .tsAccent.opacity(0.5), radius: 20, y: 5)
            
            // Current streak number
            Text("\(viewModel.streakData.currentStreak)")
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: viewModel.streakData.currentStreak > 0
                            ? [.tsAccent, Color(hex: "FF4500")]
                            : [.tsSubtle, .tsSubtle],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text(viewModel.streakData.currentStreak == 1 ? "Day Streak" : "Day Streak")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            // Today's status
            if viewModel.streakData.hasPracticedToday {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.tsSuccess)
                    Text("Practiced Today!")
                        .fontWeight(.medium)
                        .foregroundColor(.tsSuccess)
                }
                .font(.subheadline)
            } else {
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.tsAccent)
                    Text("Practice today to keep your streak!")
                        .fontWeight(.medium)
                        .foregroundColor(.tsAccent)
                }
                .font(.subheadline)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .tsPrimary.opacity(0.1), radius: 20, y: 10)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Current streak: \(viewModel.streakData.currentStreak) days")
    }
    
    // MARK: - Stats Row
    
    private var statsRow: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "Longest",
                value: "\(viewModel.streakData.longestStreak)",
                icon: "trophy.fill",
                color: .tsGold
            )
            
            StatCard(
                title: "Total Days",
                value: "\(viewModel.streakData.totalDaysPracticed)",
                icon: "calendar",
                color: .tsPrimary
            )
            
            StatCard(
                title: "Rate",
                value: "\(Int(viewModel.streakData.completionRate))%",
                icon: "chart.line.uptrend.xyaxis",
                color: .tsSuccess
            )
        }
    }
    
    // MARK: - Motivational Card
    
    private var motivationalCard: some View {
        let quotes = [
            ("Your perfect R sounds aren't missing. They're waiting.", "💬"),
            ("Every session rewires your brain for confident speech.", "🧠"),
            ("You're not just changing sounds — you're reclaiming your voice.", "🗣️"),
            ("The people who break free don't just change how they sound.", "✨"),
            ("Small daily steps lead to the biggest transformations.", "🌱"),
            ("When you stop managing your speech, everything else expands.", "🚀"),
            ("Protection and confidence can't coexist. Choose confidence.", "🛡️")
        ]
        let dayIndex = Calendar.current.component(.day, from: Date()) % quotes.count
        let quote = quotes[dayIndex]
        
        return HStack(spacing: 14) {
            Text(quote.1)
                .font(.title2)
            
            Text(quote.0)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .italic()
                .lineSpacing(2)
            
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
    
    // MARK: - Freeze Card
    
    private var freezeCard: some View {
        Button(action: { viewModel.showStreakFreezeSheet = true }) {
            HStack(spacing: 14) {
                Image(systemName: "snowflake")
                    .font(.title2)
                    .foregroundColor(.tsFreeze)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Streak Freezes")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("Protect your streak on rest days")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Freeze count pills
                HStack(spacing: 4) {
                    ForEach(0..<viewModel.streakData.maxFreezes, id: \.self) { index in
                        Circle()
                            .fill(index < viewModel.streakData.availableFreezes ? Color.tsFreeze : Color.tsSubtle.opacity(0.3))
                            .frame(width: 12, height: 12)
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $viewModel.showStreakFreezeSheet) {
            StreakFreezeView(viewModel: viewModel)
        }
        .accessibilityLabel("Streak freezes: \(viewModel.streakData.availableFreezes) of \(viewModel.streakData.maxFreezes) available")
    }
    
    // MARK: - Practice Button
    
    private var practiceButton: some View {
        Button(action: viewModel.startPractice) {
            HStack(spacing: 12) {
                Image(systemName: viewModel.streakData.hasPracticedToday ? "checkmark.circle.fill" : "play.circle.fill")
                    .font(.title2)
                
                Text(viewModel.streakData.hasPracticedToday ? "Practiced Today ✓" : "Start Practice Session")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                viewModel.streakData.hasPracticedToday
                    ? AnyShapeStyle(Color.tsSuccess.opacity(0.2))
                    : AnyShapeStyle(LinearGradient.tsPrimaryGradient)
            )
            .foregroundColor(viewModel.streakData.hasPracticedToday ? .tsSuccess : .white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: viewModel.streakData.hasPracticedToday ? .clear : .tsPrimary.opacity(0.3), radius: 12, y: 6)
        }
        .disabled(viewModel.streakData.hasPracticedToday)
        .accessibilityLabel(viewModel.streakData.hasPracticedToday ? "Already practiced today" : "Start practice session")
    }
    
    // MARK: - R Sound Lab Card
    
    private var analysisLabCard: some View {
        Button(action: { showAnalysis = true }) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Image(systemName: "waveform.and.magnifyingglass")
                        .font(.title3)
                        .foregroundColor(.purple)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("R Sound Lab")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("FFT analysis · Formant detection · F3 scoring")
                        .font(.caption2)
                        .foregroundColor(.tsSubtle)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title3)
                    .foregroundColor(.purple.opacity(0.6))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.purple.opacity(0.15), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Navigation Cards
    
    private var navigationCards: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                NavigationLink(destination: StatisticsView(viewModel: viewModel)) {
                    NavCard(title: "Statistics", icon: "chart.bar.fill", color: .tsPrimary)
                }
                
                NavigationLink(destination: BadgesView(viewModel: viewModel)) {
                    NavCard(title: "Badges", icon: "medal.fill", color: .tsGold)
                }
            }
        }
    }
    
    // MARK: - Card Background
    
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

// MARK: - Stat Card Component

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            colorScheme == .dark
                ? AnyShapeStyle(Color.tsCardDark.opacity(0.6))
                : AnyShapeStyle(Color.white)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(colorScheme == .dark ? Color.white.opacity(0.06) : Color.clear, lineWidth: 1)
        )
        .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.04), radius: 6, y: 3)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}

// MARK: - Nav Card Component

struct NavCard: View {
    let title: String
    let icon: String
    let color: Color
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            colorScheme == .dark
                ? AnyShapeStyle(Color.tsCardDark.opacity(0.6))
                : AnyShapeStyle(Color.white)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(colorScheme == .dark ? Color.white.opacity(0.06) : Color.clear, lineWidth: 1)
        )
        .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.04), radius: 6, y: 3)
    }
}

#Preview {
    DashboardView()
        .preferredColorScheme(.dark)
}
