import SwiftUI

/// Onboarding questionnaire to understand the user's R sound difficulty
struct OnboardingView: View {
    @ObservedObject var viewModel: StreakViewModel
    @State private var currentPage = 0
    @State private var userName = ""
    @State private var selectedDifficulties: Set<String> = []
    @State private var selectedSituations: Set<String> = []
    @State private var confidenceLevel = 3
    @State private var experienceLevel = ""
    @State private var animateIn = false
    
    var onComplete: () -> Void
    
    private let totalPages = 5
    
    private let difficultyOptions = [
        ("AR sounds", "car, star, large", "🚗"),
        ("OR sounds", "door, more, floor", "🚪"),
        ("ER sounds", "her, water, bird", "💧"),
        ("IRE sounds", "fire, tire, wire", "🔥"),
        ("AIR sounds", "hair, fair, chair", "💇"),
        ("R blends", "tree, drive, bring", "🌳"),
        ("Starting R", "red, run, rain", "🔴"),
        ("R in my name", "hard to say my own name", "👤")
    ]
    
    private let situationOptions = [
        ("Ordering food & drinks", "☕"),
        ("Phone calls", "📱"),
        ("Work presentations", "💼"),
        ("Meeting new people", "🤝"),
        ("Saying my name", "👋"),
        ("Reading aloud", "📖"),
        ("Voice messages", "🎙️"),
        ("Talking to strangers", "🗣️")
    ]
    
    private let experienceOptions = [
        ("brand_new", "Brand new", "Never tried speech therapy"),
        ("tried_before", "Tried before", "Had therapy but it felt like kids' exercises"),
        ("on_and_off", "On and off", "I practice sometimes but nothing sticks"),
        ("close_enough", "Close enough", "I've accepted 'close enough' pronunciation"),
        ("committed", "Fully committed", "Ready to make a real change this time")
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.tsDarkBg, Color(hex: "0A1628")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                progressDots
                    .padding(.top, 16)
                
                TabView(selection: $currentPage) {
                    welcomePage.tag(0)
                    difficultyPage.tag(1)
                    situationPage.tag(2)
                    confidencePage.tag(3)
                    experiencePage.tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage)
                
                bottomButton
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                animateIn = true
            }
        }
    }
    
    // MARK: - Progress Dots
    
    private var progressDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Capsule()
                    .fill(index <= currentPage ? Color.tsPrimary : Color.tsSubtle.opacity(0.3))
                    .frame(width: index == currentPage ? 28 : 8, height: 8)
                    .animation(.spring(response: 0.3), value: currentPage)
            }
        }
        .padding(.top, 8)
    }
    
    // MARK: - Welcome Page
    
    private var welcomePage: some View {
        VStack(spacing: 28) {
            Spacer()
            
            Text("🗣️")
                .font(.system(size: 72))
                .opacity(animateIn ? 1 : 0)
                .scaleEffect(animateIn ? 1 : 0.5)
            
            VStack(spacing: 12) {
                Text("Welcome to")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Text("Daily Rhythm")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(LinearGradient.tsPrimaryGradient)
                
                Text("by TopSpeech Health")
                    .font(.subheadline)
                    .foregroundColor(.tsSubtle)
            }
            
            Text("Let's personalise your practice.\nA few quick questions to understand\nyour R sound journey.")
                .font(.body)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("What's your name?")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))
                
                TextField("Your name", text: $userName)
                    .font(.body)
                    .padding(14)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .foregroundColor(.white)
                    .autocorrectionDisabled()
            }
            .padding(.horizontal, 4)
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Difficulty Page
    
    private var difficultyPage: some View {
        VStack(spacing: 20) {
            pageHeader(emoji: "🎯", title: "Which R sounds\nare hardest for you?", subtitle: "Select all that apply")
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    ForEach(difficultyOptions, id: \.0) { option in
                        let isSelected = selectedDifficulties.contains(option.0)
                        
                        Button(action: {
                            if isSelected { selectedDifficulties.remove(option.0) }
                            else { selectedDifficulties.insert(option.0) }
                        }) {
                            HStack(spacing: 14) {
                                Text(option.2).font(.title3)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(option.0)
                                        .font(.subheadline).fontWeight(.semibold).foregroundColor(.white)
                                    Text(option.1)
                                        .font(.caption).foregroundColor(.white.opacity(0.5))
                                }
                                
                                Spacer()
                                
                                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(isSelected ? .tsPrimary : .tsSubtle.opacity(0.4))
                                    .font(.title3)
                            }
                            .padding(14)
                            .background(isSelected ? Color.tsPrimary.opacity(0.12) : Color.white.opacity(0.04))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(isSelected ? Color.tsPrimary.opacity(0.4) : Color.clear, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Situation Page
    
    private var situationPage: some View {
        VStack(spacing: 20) {
            pageHeader(emoji: "😰", title: "When is it\nhardest to speak?", subtitle: "Select all that apply")
            
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(situationOptions, id: \.0) { option in
                        let isSelected = selectedSituations.contains(option.0)
                        
                        Button(action: {
                            if isSelected { selectedSituations.remove(option.0) }
                            else { selectedSituations.insert(option.0) }
                        }) {
                            VStack(spacing: 10) {
                                Text(option.1).font(.title)
                                Text(option.0)
                                    .font(.caption).fontWeight(.medium).foregroundColor(.white)
                                    .multilineTextAlignment(.center).lineLimit(2)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18).padding(.horizontal, 8)
                            .background(isSelected ? Color.tsPrimary.opacity(0.12) : Color.white.opacity(0.04))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(isSelected ? Color.tsPrimary.opacity(0.4) : Color.clear, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Confidence Page
    
    private var confidencePage: some View {
        VStack(spacing: 28) {
            Spacer()
            
            pageHeader(emoji: "💪", title: "How confident do you\nfeel speaking?", subtitle: "Be honest — there's no wrong answer")
            
            VStack(spacing: 20) {
                Text(confidenceEmoji)
                    .font(.system(size: 56))
                    .animation(.spring(response: 0.3), value: confidenceLevel)
                
                Text(confidenceLabel)
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack(spacing: 0) {
                    ForEach(1...5, id: \.self) { level in
                        Button(action: { confidenceLevel = level }) {
                            VStack(spacing: 6) {
                                Circle()
                                    .fill(level <= confidenceLevel ? Color.tsPrimary : Color.tsSubtle.opacity(0.3))
                                    .frame(width: level == confidenceLevel ? 32 : 20, height: level == confidenceLevel ? 32 : 20)
                                    .animation(.spring(response: 0.3), value: confidenceLevel)
                                
                                Text("\(level)")
                                    .font(.caption2)
                                    .foregroundColor(level <= confidenceLevel ? .tsPrimary : .tsSubtle)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                HStack {
                    Text("Not confident").font(.caption2).foregroundColor(.tsSubtle)
                    Spacer()
                    Text("Very confident").font(.caption2).foregroundColor(.tsSubtle)
                }
                .padding(.horizontal, 12)
            }
            .padding(24)
            .background(Color.white.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Experience Page
    
    private var experiencePage: some View {
        VStack(spacing: 20) {
            pageHeader(emoji: "📋", title: "Where are you on\nyour speech journey?", subtitle: "This helps us tailor your practice")
            
            VStack(spacing: 10) {
                ForEach(experienceOptions, id: \.0) { option in
                    let isSelected = experienceLevel == option.0
                    
                    Button(action: { experienceLevel = option.0 }) {
                        HStack(spacing: 14) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(option.1)
                                    .font(.subheadline).fontWeight(.semibold).foregroundColor(.white)
                                Text(option.2)
                                    .font(.caption).foregroundColor(.white.opacity(0.5))
                            }
                            
                            Spacer()
                            
                            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(isSelected ? .tsPrimary : .tsSubtle.opacity(0.4))
                                .font(.title3)
                        }
                        .padding(16)
                        .background(isSelected ? Color.tsPrimary.opacity(0.12) : Color.white.opacity(0.04))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(isSelected ? Color.tsPrimary.opacity(0.4) : Color.clear, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Bottom Button
    
    private var bottomButton: some View {
        Button(action: {
            if currentPage < totalPages - 1 {
                withAnimation { currentPage += 1 }
            } else {
                saveOnboardingData()
                onComplete()
            }
        }) {
            HStack(spacing: 8) {
                Text(currentPage < totalPages - 1 ? "Continue" : "Start My Journey")
                    .fontWeight(.bold)
                Image(systemName: currentPage < totalPages - 1 ? "arrow.right" : "sparkles")
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(buttonEnabled ? LinearGradient.tsPrimaryGradient : LinearGradient(colors: [.tsSubtle.opacity(0.3), .tsSubtle.opacity(0.3)], startPoint: .leading, endPoint: .trailing))
            .foregroundColor(buttonEnabled ? .white : .tsSubtle)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: buttonEnabled ? .tsPrimary.opacity(0.3) : .clear, radius: 12, y: 6)
        }
        .disabled(!buttonEnabled)
    }
    
    // MARK: - Helpers
    
    private var buttonEnabled: Bool {
        switch currentPage {
        case 0: return !userName.trimmingCharacters(in: .whitespaces).isEmpty
        case 1: return !selectedDifficulties.isEmpty
        case 2: return !selectedSituations.isEmpty
        case 3: return true
        case 4: return !experienceLevel.isEmpty
        default: return true
        }
    }
    
    private var confidenceEmoji: String {
        ["", "😔", "😕", "😐", "🙂", "😊"][confidenceLevel]
    }
    
    private var confidenceLabel: String {
        ["", "I avoid speaking when I can", "I speak but I'm always anxious", "It depends on the situation", "Mostly confident, some struggles", "Confident but want to improve"][confidenceLevel]
    }
    
    private func pageHeader(emoji: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 10) {
            Text(emoji).font(.system(size: 44))
            Text(title).font(.title2).fontWeight(.bold).foregroundColor(.white).multilineTextAlignment(.center)
            Text(subtitle).font(.subheadline).foregroundColor(.tsSubtle)
        }
        .padding(.top, 12)
    }
    
    private func saveOnboardingData() {
        viewModel.streakData.userName = userName.trimmingCharacters(in: .whitespaces)
        viewModel.streakData.difficultSounds = Array(selectedDifficulties)
        viewModel.streakData.challengingSituations = Array(selectedSituations)
        viewModel.streakData.confidenceLevel = confidenceLevel
        viewModel.streakData.experienceLevel = experienceLevel
        viewModel.streakData.hasCompletedOnboarding = true
        viewModel.objectWillChange.send()
    }
}
