import SwiftUI

/// Compact practice session — fits on a single screen without scrolling
struct PracticeSessionView: View {
    @ObservedObject var viewModel: StreakViewModel
    @Environment(\.dismiss) var dismiss
    @State private var timerValue = 0
    @State private var isTimerRunning = false
    @State private var timer: Timer?
    @State private var showCompletion = false
    @State private var animateProgress = false
    @State private var pulseScale: CGFloat = 1.0
    
    private let exerciseSteps = [
        ExerciseStep(
            title: "The Growl",
            instruction: "Make a gentle \"grrrr\" sound — wake up the muscles in your tongue.",
            icon: "waveform.path",
            duration: "30s",
            tip: "Like a cat purring. Relaxed, not forced."
        ),
        ExerciseStep(
            title: "Hidden Position",
            instruction: "Tongue tip behind lower teeth, back raised toward soft palate. Hold & breathe.",
            icon: "mouth.fill",
            duration: "60s",
            tip: "The secret R position most therapy misses."
        ),
        ExerciseStep(
            title: "Buttercup",
            instruction: "Say \"buttercup\" slowly. Focus on the \"er\" — let it stretch naturally.",
            icon: "mic.fill",
            duration: "5×",
            tip: "The magic is in the 'er' sound."
        ),
        ExerciseStep(
            title: "Vocalic R",
            instruction: "Say each slowly: car · door · her · fire · chair — all 5 R types.",
            icon: "text.bubble.fill",
            duration: "3× each",
            tip: "Don't drill — seduce the words."
        ),
        ExerciseStep(
            title: "Sentence Flow",
            instruction: "\"The red car drove around the corner\" — whisper, confident, then friendly.",
            icon: "quote.bubble.fill",
            duration: "3×",
            tip: "Emotional investment changes everything."
        )
    ]
    
    private let encouragements = [
        "You're not just changing sounds — you're reclaiming your voice. 💪",
        "Every session rewires your brain for confident speech.",
        "Your perfect R sounds aren't missing. They're waiting.",
        "Small daily steps lead to the biggest transformations."
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.tsDarkBg.ignoresSafeArea()
                
                if showCompletion {
                    completionView
                } else {
                    exerciseView
                }
            }
            .navigationTitle("Practice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        stopTimer()
                        viewModel.cancelPractice()
                        dismiss()
                    }
                    .foregroundColor(.tsSubtle)
                }
            }
        }
        .preferredColorScheme(.dark)
        .interactiveDismissDisabled()
    }
    
    // MARK: - Exercise View (Single Screen)
    
    private var exerciseView: some View {
        let stepIndex = min(viewModel.practiceSessionStep, exerciseSteps.count - 1)
        let step = exerciseSteps[stepIndex]
        
        return VStack(spacing: 0) {
            // Progress bar
            HStack(spacing: 4) {
                ForEach(0..<exerciseSteps.count, id: \.self) { index in
                    Capsule()
                        .fill(index <= viewModel.practiceSessionStep ? Color.tsPrimary : Color.tsSubtle.opacity(0.3))
                        .frame(height: 3)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            
            Spacer(minLength: 8)
            
            // Step + Title
            Text("STEP \(viewModel.practiceSessionStep + 1) OF \(exerciseSteps.count)")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.tsPrimary)
                .tracking(1.5)
            
            // Icon + Title row
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.tsPrimary.opacity(0.1))
                        .frame(width: 48, height: 48)
                    Image(systemName: step.icon)
                        .font(.title3)
                        .foregroundStyle(LinearGradient.tsPrimaryGradient)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(step.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption2)
                        Text(step.duration)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.tsAccent)
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 10)
            
            // Instruction
            Text(step.instruction)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.85))
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 12)
            
            // Tip
            HStack(spacing: 6) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.tsGold)
                    .font(.caption2)
                Text(step.tip)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
                    .italic()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 6)
            
            Spacer(minLength: 12)
            
            // Recording animation OR start button
            if isTimerRunning {
                // Recording visualization
                VStack(spacing: 10) {
                    ZStack {
                        // Pulsing rings
                        Circle()
                            .stroke(Color.tsPrimary.opacity(0.12), lineWidth: 1.5)
                            .frame(width: 120, height: 120)
                            .scaleEffect(pulseScale)
                            .opacity(2.0 - pulseScale)
                        
                        Circle()
                            .fill(Color.tsPrimary.opacity(0.08))
                            .frame(width: 90, height: 90)
                        
                        // Waveform bars
                        HStack(spacing: 3) {
                            ForEach(0..<9, id: \.self) { i in
                                WaveformBar(index: i, isAnimating: isTimerRunning)
                            }
                        }
                        .frame(width: 65)
                    }
                    
                    // REC + Timer inline
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 6, height: 6)
                                .opacity(pulseScale > 1.3 ? 0.4 : 1.0)
                            Text("REC")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.red)
                        }
                        
                        Text(formattedTime)
                            .font(.system(size: 32, weight: .thin, design: .monospaced))
                            .foregroundColor(.tsPrimary)
                    }
                }
                .transition(.scale.combined(with: .opacity))
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                        pulseScale = 1.5
                    }
                }
            } else {
                // Start recording button
                Button(action: startTimer) {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color.tsPrimary.opacity(0.1))
                                .frame(width: 80, height: 80)
                            Circle()
                                .fill(Color.tsPrimary.opacity(0.15))
                                .frame(width: 60, height: 60)
                            Image(systemName: "mic.fill")
                                .font(.title2)
                                .foregroundColor(.tsPrimary)
                        }
                        Text("Tap to start")
                            .font(.caption)
                            .foregroundColor(.tsSubtle)
                    }
                }
            }
            
            Spacer(minLength: 12)
            
            // Next / Complete button
            Button(action: advanceStep) {
                HStack(spacing: 8) {
                    Text(viewModel.practiceSessionStep < exerciseSteps.count - 1 ? "Next Exercise" : "Complete Session")
                    Image(systemName: viewModel.practiceSessionStep < exerciseSteps.count - 1 ? "arrow.right" : "checkmark")
                }
                .font(.headline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(LinearGradient.tsPrimaryGradient)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: .tsPrimary.opacity(0.3), radius: 10, y: 5)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .animation(.easeInOut(duration: 0.35), value: viewModel.practiceSessionStep)
        .animation(.easeInOut(duration: 0.3), value: isTimerRunning)
    }
    
    // MARK: - Completion View
    
    private var completionView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("🗣️")
                .font(.system(size: 64))
                .scaleEffect(animateProgress ? 1.0 : 0.5)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: animateProgress)
            
            Text("Session Complete!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(encouragements.randomElement() ?? encouragements[0])
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .italic()
                .padding(.horizontal, 40)
            
            HStack(spacing: 28) {
                VStack(spacing: 4) {
                    Text(formattedTime)
                        .font(.headline).foregroundColor(.tsPrimary)
                    Text("Duration").font(.caption2).foregroundColor(.secondary)
                }
                VStack(spacing: 4) {
                    Text("\(exerciseSteps.count)")
                        .font(.headline).foregroundColor(.tsAccent)
                    Text("Exercises").font(.caption2).foregroundColor(.secondary)
                }
                VStack(spacing: 4) {
                    Text("25+")
                        .font(.headline).foregroundColor(.tsSuccess)
                    Text("Words").font(.caption2).foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: {
                viewModel.completePractice()
                dismiss()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Save & Continue")
                }
                .font(.headline).fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(LinearGradient.tsPrimaryGradient)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .tsPrimary.opacity(0.3), radius: 12, y: 6)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .onAppear {
            withAnimation { animateProgress = true }
        }
    }
    
    // MARK: - Timer
    
    private var formattedTime: String {
        let m = timerValue / 60, s = timerValue % 60
        return String(format: "%d:%02d", m, s)
    }
    
    private func startTimer() {
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            timerValue += 1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
    }
    
    private func advanceStep() {
        if viewModel.practiceSessionStep < exerciseSteps.count - 1 {
            viewModel.nextPracticeStep()
        } else {
            stopTimer()
            withAnimation(.spring()) { showCompletion = true }
        }
    }
}

// MARK: - Models & Components

struct ExerciseStep {
    let title: String
    let instruction: String
    let icon: String
    let duration: String
    let tip: String
}

struct WaveformBar: View {
    let index: Int
    let isAnimating: Bool
    @State private var barHeight: CGFloat = 6
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(LinearGradient(colors: [.tsPrimary, .tsPrimary.opacity(0.4)], startPoint: .top, endPoint: .bottom))
            .frame(width: 4, height: barHeight)
            .onAppear {
                guard isAnimating else { return }
                animate()
            }
            .onChange(of: isAnimating) { _, newValue in
                if newValue { animate() }
                else { withAnimation(.easeOut(duration: 0.3)) { barHeight = 6 } }
            }
    }
    
    private func animate() {
        withAnimation(
            .easeInOut(duration: Double.random(in: 0.3...0.6))
            .repeatForever(autoreverses: true)
            .delay(Double(index) * 0.07)
        ) {
            barHeight = CGFloat.random(in: 14...38)
        }
    }
}
