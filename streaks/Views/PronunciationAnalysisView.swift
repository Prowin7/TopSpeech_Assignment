import SwiftUI

/// Pronunciation analysis view with live spectrogram and R sound scoring
struct PronunciationAnalysisView: View {
    @StateObject private var audioService = AudioAnalysisService()
    @Environment(\.dismiss) var dismiss
    @State private var selectedWord = "car"
    @State private var showPermissionAlert = false
    @State private var pulseScale: CGFloat = 1.0
    
    private let practiceWords = [
        ("car", "AR"), ("door", "OR"), ("her", "ER"),
        ("fire", "IRE"), ("chair", "AIR"), ("red", "R")
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.tsDarkBg.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if let result = audioService.analysisResult {
                        resultContent(result)
                    } else if audioService.isAnalyzing {
                        analyzingView
                    } else {
                        recordingView
                    }
                }
            }
            .navigationTitle("R Sound Lab")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.tsSubtle)
                }
            }
        }
        .preferredColorScheme(.dark)
        .alert("Microphone Access Needed", isPresented: $showPermissionAlert) {
            Button("OK") {}
        } message: {
            Text("Please enable microphone access in Settings to use pronunciation analysis.")
        }
    }
    
    // MARK: - Recording View
    
    private var recordingView: some View {
        VStack(spacing: 0) {
            // Word selector
            VStack(spacing: 8) {
                Text("SAY THIS WORD")
                    .font(.caption2).fontWeight(.bold)
                    .foregroundColor(.tsSubtle).tracking(1.5)
                
                Text("\"\(selectedWord)\"")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(LinearGradient.tsPrimaryGradient)
                
                // Word pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(practiceWords, id: \.0) { word, type in
                            Button(action: { selectedWord = word }) {
                                VStack(spacing: 2) {
                                    Text(word)
                                        .font(.caption).fontWeight(.semibold)
                                    Text(type)
                                        .font(.system(size: 9)).foregroundColor(.tsSubtle)
                                }
                                .padding(.horizontal, 14).padding(.vertical, 8)
                                .background(selectedWord == word ? Color.tsPrimary.opacity(0.2) : Color.white.opacity(0.05))
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(selectedWord == word ? Color.tsPrimary.opacity(0.4) : Color.clear, lineWidth: 1))
                            }
                            .foregroundColor(selectedWord == word ? .tsPrimary : .white.opacity(0.7))
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.top, 16)
            
            Spacer()
            
            // Live spectrogram
            spectrogramView
            
            Spacer()
            
            // Record button
            VStack(spacing: 12) {
                Button(action: toggleRecording) {
                    ZStack {
                        if audioService.isRecording {
                            Circle()
                                .stroke(Color.red.opacity(0.15), lineWidth: 2)
                                .frame(width: 100, height: 100)
                                .scaleEffect(pulseScale)
                                .opacity(2.0 - pulseScale)
                        }
                        
                        Circle()
                            .fill(audioService.isRecording
                                  ? Color.red.opacity(0.15)
                                  : Color.tsPrimary.opacity(0.1))
                            .frame(width: 80, height: 80)
                        
                        if audioService.isRecording {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.red)
                                .frame(width: 28, height: 28)
                        } else {
                            Circle()
                                .fill(Color.tsPrimary)
                                .frame(width: 32, height: 32)
                        }
                    }
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                        pulseScale = 1.5
                    }
                }
                
                Text(audioService.isRecording ? "Tap to stop & analyze" : "Tap to record")
                    .font(.caption).foregroundColor(.tsSubtle)
            }
            
            Spacer(minLength: 20)
            
            // Info bar
            HStack(spacing: 20) {
                infoItem(icon: "waveform", label: "FFT", value: "4096pt")
                infoItem(icon: "scope", label: "Target F3", value: "1.8-2.2 kHz")
                infoItem(icon: "mic", label: "Rate", value: "44.1 kHz")
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
    
    // MARK: - Live Spectrogram
    
    private var spectrogramView: some View {
        VStack(spacing: 6) {
            HStack(alignment: .bottom, spacing: 1.5) {
                ForEach(0..<64, id: \.self) { i in
                    let magnitude = audioService.frequencyMagnitudes[i]
                    
                    RoundedRectangle(cornerRadius: 1)
                        .fill(barColorForBin(i))
                        .frame(height: max(2, CGFloat(magnitude) * 120))
                        .animation(.easeOut(duration: 0.08), value: magnitude)
                }
            }
            .frame(height: 120)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            
            HStack {
                Text("0 Hz")
                Spacer()
                Text("F1").foregroundColor(.blue.opacity(0.6))
                Spacer()
                Text("F2").foregroundColor(.purple.opacity(0.6))
                Spacer()
                Text("F3 (R zone)").foregroundColor(.tsPrimary)
                Spacer()
                Text("22 kHz")
            }
            .font(.system(size: 9))
            .foregroundColor(.tsSubtle)
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.02))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
    }
    
    // MARK: - Analyzing View
    
    private var analyzingView: some View {
        VStack(spacing: 20) {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
                .tint(.tsPrimary)
            Text("Analyzing frequencies...")
                .font(.headline).foregroundColor(.white)
            Text("Extracting formant peaks via FFT")
                .font(.caption).foregroundColor(.tsSubtle)
            Spacer()
        }
    }
    
    // MARK: - Result View
    
    @ViewBuilder
    private func resultContent(_ result: AnalysisResult) -> some View {
        VStack(spacing: 16) {
            Spacer(minLength: 8)
            
            Text(result.grade.emoji)
                .font(.system(size: 52))
            
            Text(result.grade.label)
                .font(.title2).fontWeight(.bold)
                .foregroundColor(.white)
            
            // Score ring
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.08), lineWidth: 8)
                    .frame(width: 110, height: 110)
                
                Circle()
                    .trim(from: 0, to: CGFloat(result.score / 100))
                    .stroke(
                        scoreColor(result.score),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 110, height: 110)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 2) {
                    Text("\(Int(result.score))%")
                        .font(.title).fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("match")
                        .font(.caption2).foregroundColor(.tsSubtle)
                }
            }
            
            // F3 comparison
            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("Your F3")
                        .font(.caption2).foregroundColor(.tsSubtle)
                    Text(String(format: "%.0f Hz", result.f3Frequency))
                        .font(.subheadline).fontWeight(.bold)
                        .foregroundColor(.tsPrimary)
                }
                
                Rectangle()
                    .fill(Color.tsSubtle.opacity(0.3))
                    .frame(width: 1, height: 30)
                
                VStack(spacing: 4) {
                    Text("Target F3")
                        .font(.caption2).foregroundColor(.tsSubtle)
                    Text("1800-2200 Hz")
                        .font(.subheadline).fontWeight(.bold)
                        .foregroundColor(.tsSuccess)
                }
            }
            .padding(14)
            .background(Color.white.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 24)
            
            // Feedback
            Text(result.feedback)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.horizontal, 30)
            
            Spacer()
            
            // Buttons
            VStack(spacing: 10) {
                Button(action: { audioService.reset() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "mic.fill")
                        Text("Try Again")
                    }
                    .font(.headline).fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(LinearGradient.tsPrimaryGradient)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                
                Button(action: { dismiss() }) {
                    Text("Back to Dashboard")
                        .font(.subheadline).foregroundColor(.tsSubtle)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
    }
    
    // MARK: - Helpers
    
    private func toggleRecording() {
        if audioService.isRecording {
            audioService.stopRecording()
        } else {
            audioService.requestMicrophonePermission { granted in
                if granted {
                    audioService.startRecording()
                } else {
                    showPermissionAlert = true
                }
            }
        }
    }
    
    private func barColorForBin(_ bin: Int) -> Color {
        let n = Double(bin) / 64.0
        if n > 0.38 && n < 0.52 { return .tsPrimary }
        if n > 0.18 && n < 0.38 { return .purple.opacity(0.6) }
        if n < 0.18 { return .blue.opacity(0.5) }
        return .tsSubtle.opacity(0.3)
    }
    
    private func scoreColor(_ score: Double) -> Color {
        if score >= 80 { return .tsSuccess }
        if score >= 60 { return .tsPrimary }
        if score >= 40 { return .tsAccent }
        return .red
    }
    
    private func infoItem(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption2).foregroundColor(.tsSubtle)
            VStack(alignment: .leading, spacing: 1) {
                Text(label).font(.system(size: 9)).foregroundColor(.tsSubtle)
                Text(value).font(.caption2).fontWeight(.medium).foregroundColor(.white.opacity(0.6))
            }
        }
    }
}

// MARK: - Analysis Entry

struct AnalysisEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let word: String
    let score: Double
    let f3Frequency: Double
    
    init(word: String, score: Double, f3Frequency: Double) {
        self.id = UUID()
        self.date = Date()
        self.word = word
        self.score = score
        self.f3Frequency = f3Frequency
    }
}
