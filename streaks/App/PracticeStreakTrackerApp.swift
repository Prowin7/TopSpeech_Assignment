import SwiftUI

/// App entry point — shows onboarding on first launch, then the dashboard
@main
struct PracticeStreakTrackerApp: App {
    @StateObject private var appViewModel = StreakViewModel()
    
    init() {
        // Clear badge count on launch
        NotificationService.shared.clearBadge()
        
        // Customize navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.largeTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some Scene {
        WindowGroup {
            if appViewModel.streakData.hasCompletedOnboarding {
                DashboardView()
                    .preferredColorScheme(appViewModel.streakData.isDarkMode ? .dark : .light)
                    .environmentObject(appViewModel)
            } else {
                OnboardingView(viewModel: appViewModel) {
                    // Onboarding complete — data is saved automatically
                }
                .preferredColorScheme(.dark)
            }
        }
    }
}
