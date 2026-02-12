import SwiftUI

/// Settings view for notification preferences and app configuration
struct SettingsView: View {
    @ObservedObject var viewModel: StreakViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedTime: Date
    @State private var showResetAlert = false
    
    init(viewModel: StreakViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        
        // Initialize time picker with current notification time
        var components = DateComponents()
        components.hour = viewModel.streakData.notificationHour
        components.minute = viewModel.streakData.notificationMinute
        let date = Calendar.current.date(from: components) ?? Date()
        self._selectedTime = State(initialValue: date)
    }
    
    var body: some View {
        ZStack {
            (colorScheme == .dark ? Color.tsDarkBg : Color(hex: "F0F4FF"))
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Appearance section
                    appearanceSection
                    
                    // Notifications section
                    notificationSection
                    
                    // App info section
                    appInfoSection
                    
                    // Data section
                    dataSection
                }
                .padding(20)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .alert("Reset All Data?", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                viewModel.resetAllData()
            }
        } message: {
            Text("This will permanently delete all your practice history, streaks, badges, and settings. This cannot be undone.")
        }
    }
    
    // MARK: - Appearance
    
    private var appearanceSection: some View {
        VStack(spacing: 16) {
            SectionHeader(icon: "paintbrush.fill", title: "Appearance", color: .purple)
            
            Toggle(isOn: Binding(
                get: { viewModel.streakData.isDarkMode },
                set: { newValue in
                    viewModel.streakData.isDarkMode = newValue
                    viewModel.objectWillChange.send()
                }
            )) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Dark Mode")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(viewModel.streakData.isDarkMode ? "Dark theme active" : "Light theme active")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .tint(.purple)
        }
        .padding(20)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Notifications
    
    private var notificationSection: some View {
        VStack(spacing: 16) {
            SectionHeader(icon: "bell.fill", title: "Notifications", color: .tsPrimary)
            
            // Enable toggle
            Toggle(isOn: Binding(
                get: { viewModel.streakData.notificationsEnabled },
                set: { viewModel.toggleNotifications($0) }
            )) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Daily Reminders")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("Get notified to practice every day")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .tint(.tsPrimary)
            
            if viewModel.streakData.notificationsEnabled {
                Divider().opacity(0.3)
                
                // Time picker
                DatePicker(
                    "Reminder Time",
                    selection: $selectedTime,
                    displayedComponents: .hourAndMinute
                )
                .font(.subheadline)
                .onChange(of: selectedTime) { _, newValue in
                    let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                    viewModel.updateNotificationTime(
                        hour: components.hour ?? 9,
                        minute: components.minute ?? 0
                    )
                }
                
                // Permission status
                if !viewModel.notificationPermissionGranted {
                    Divider().opacity(0.3)
                    
                    Button(action: viewModel.requestNotificationPermission) {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.tsAccent)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Permission Required")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                Text("Tap to enable notification permissions")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(20)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - App Info
    
    private var appInfoSection: some View {
        VStack(spacing: 16) {
            SectionHeader(icon: "info.circle.fill", title: "About", color: .tsSuccess)
            
            InfoRow(label: "App", value: "Practice Streak Tracker")
            Divider().opacity(0.3)
            InfoRow(label: "Version", value: "1.0.0")
            Divider().opacity(0.3)
            InfoRow(label: "Platform", value: "TopSpeech Health")
            Divider().opacity(0.3)
            InfoRow(label: "Website", value: "topspeech.health")
        }
        .padding(20)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Data Section
    
    private var dataSection: some View {
        VStack(spacing: 16) {
            SectionHeader(icon: "externaldrive.fill", title: "Data", color: .tsAccent)
            
            // Load demo data
            Button(action: viewModel.loadDemoData) {
                HStack {
                    Image(systemName: "wand.and.stars")
                        .foregroundColor(.tsPrimary)
                    Text("Load Demo Data")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)
            
            Divider().opacity(0.3)
            
            // Reset all data
            Button(action: { showResetAlert = true }) {
                HStack {
                    Image(systemName: "trash.fill")
                        .foregroundColor(.red)
                    Text("Reset All Data")
                        .font(.subheadline)
                        .foregroundColor(.red)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
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

// MARK: - Section Header

struct SectionHeader: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Info Row

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}
