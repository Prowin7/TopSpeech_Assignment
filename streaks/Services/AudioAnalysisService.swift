import Foundation
import AVFoundation
import Accelerate

/// Service that records audio and performs FFT analysis for R sound pronunciation
class AudioAnalysisService: ObservableObject {
    static let shared = AudioAnalysisService()
    
    // MARK: - Published State
    
    @Published var isRecording = false
    @Published var frequencyMagnitudes: [Float] = Array(repeating: 0, count: 64)
    @Published var pronunciationScore: Double = 0
    @Published var f3Frequency: Double = 0
    @Published var isAnalyzing = false
    @Published var analysisResult: AnalysisResult?
    @Published var audioLevel: Float = 0
    
    // MARK: - Audio Engine
    
    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    private let bufferSize: AVAudioFrameCount = 4096
    
    // FFT setup
    private var fftSetup: vDSP.FFT<DSPSplitComplex>?
    private let fftSize = 4096
    private let log2n: vDSP_Length = 12 // log2(4096)
    
    // Reference values for R sound analysis
    // Normal R: F3 ~1800-2200 Hz (third formant drops)
    // Incorrect R (w-substitution): F3 ~2500-3000 Hz
    private let targetF3Range: ClosedRange<Double> = 1800...2200
    private let sampleRate: Double = 44100
    
    // Recording buffer for analysis
    private var recordedBuffers: [AVAudioPCMBuffer] = []
    
    init() {
        fftSetup = vDSP.FFT(log2n: log2n, radix: .radix2, ofType: DSPSplitComplex.self)
    }
    
    // MARK: - Microphone Permission
    
    func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        AVAudioApplication.requestRecordPermission { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    // MARK: - Start Recording + Live Analysis
    
    func startRecording() {
        guard !isRecording else { return }
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .measurement, options: [.defaultToSpeaker])
            try session.setActive(true)
        } catch {
            print("Audio session error: \(error)")
            return
        }
        
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else { return }
        
        inputNode = audioEngine.inputNode
        guard let inputNode = inputNode else { return }
        
        let format = inputNode.outputFormat(forBus: 0)
        recordedBuffers = []
        
        inputNode.installTap(onBus: 0, bufferSize: bufferSize, format: format) { [weak self] buffer, _ in
            self?.processAudioBuffer(buffer)
        }
        
        do {
            try audioEngine.start()
            DispatchQueue.main.async {
                self.isRecording = true
                self.analysisResult = nil
            }
        } catch {
            print("Engine start error: \(error)")
        }
    }
    
    // MARK: - Stop Recording + Final Analysis
    
    func stopRecording() {
        guard isRecording else { return }
        
        inputNode?.removeTap(onBus: 0)
        audioEngine?.stop()
        
        DispatchQueue.main.async {
            self.isRecording = false
            self.isAnalyzing = true
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.performFinalAnalysis()
        }
    }
    
    // MARK: - Process Audio Buffer (Live)
    
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameCount = Int(buffer.frameLength)
        
        if let copy = buffer.copy() as? AVAudioPCMBuffer {
            recordedBuffers.append(copy)
        }
        
        var rms: Float = 0
        vDSP_rmsqv(channelData, 1, &rms, vDSP_Length(frameCount))
        
        let magnitudes = performFFT(on: channelData, frameCount: min(frameCount, fftSize))
        
        DispatchQueue.main.async { [weak self] in
            self?.audioLevel = rms
            
            if magnitudes.count >= 64 {
                var downsampled = [Float](repeating: 0, count: 64)
                let binSize = magnitudes.count / 64
                for i in 0..<64 {
                    let start = i * binSize
                    let end = min(start + binSize, magnitudes.count)
                    let slice = Array(magnitudes[start..<end])
                    downsampled[i] = slice.reduce(0, +) / Float(slice.count)
                }
                self?.frequencyMagnitudes = downsampled
            }
        }
    }
    
    // MARK: - FFT Implementation
    
    private func performFFT(on data: UnsafePointer<Float>, frameCount: Int) -> [Float] {
        let n = min(frameCount, fftSize)
        
        var windowedData = [Float](repeating: 0, count: fftSize)
        var window = [Float](repeating: 0, count: n)
        vDSP_hann_window(&window, vDSP_Length(n), Int32(vDSP_HANN_NORM))
        vDSP_vmul(data, 1, window, 1, &windowedData, 1, vDSP_Length(n))
        
        let halfN = fftSize / 2
        var realPart = [Float](repeating: 0, count: halfN)
        var imagPart = [Float](repeating: 0, count: halfN)
        
        var splitComplex = DSPSplitComplex(realp: &realPart, imagp: &imagPart)
        
        windowedData.withUnsafeBytes { rawBuffer in
            let typedBuffer = rawBuffer.bindMemory(to: DSPComplex.self)
            vDSP_ctoz(typedBuffer.baseAddress!, 2, &splitComplex, 1, vDSP_Length(halfN))
        }
        
        fftSetup?.forward(input: splitComplex, output: &splitComplex)
        
        var magnitudes = [Float](repeating: 0, count: halfN)
        vDSP_zvmags(&splitComplex, 1, &magnitudes, 1, vDSP_Length(halfN))
        
        var dbMagnitudes = [Float](repeating: 0, count: halfN)
        var one: Float = 1.0
        vDSP_vdbcon(magnitudes, 1, &one, &dbMagnitudes, 1, vDSP_Length(halfN), 0)
        
        var minVal: Float = 0
        var maxVal: Float = 0
        vDSP_minv(dbMagnitudes, 1, &minVal, vDSP_Length(halfN))
        vDSP_maxv(dbMagnitudes, 1, &maxVal, vDSP_Length(halfN))
        
        let range = maxVal - minVal
        if range > 0 {
            var normalized = [Float](repeating: 0, count: halfN)
            var negMin = -minVal
            vDSP_vsadd(dbMagnitudes, 1, &negMin, &normalized, 1, vDSP_Length(halfN))
            var invRange = 1.0 / range
            vDSP_vsmul(normalized, 1, &invRange, &normalized, 1, vDSP_Length(halfN))
            return normalized
        }
        
        return dbMagnitudes
    }
    
    // MARK: - Final Analysis
    
    private func performFinalAnalysis() {
        guard !recordedBuffers.isEmpty else {
            DispatchQueue.main.async {
                self.isAnalyzing = false
                self.analysisResult = AnalysisResult(
                    score: 0, f3Frequency: 0,
                    feedback: "No audio detected. Try speaking louder.",
                    grade: .noInput
                )
            }
            return
        }
        
        var allSamples: [Float] = []
        for buffer in recordedBuffers {
            if let data = buffer.floatChannelData?[0] {
                let count = Int(buffer.frameLength)
                allSamples.append(contentsOf: UnsafeBufferPointer(start: data, count: count))
            }
        }
        
        let segmentSize = fftSize
        var bestSegment: [Float] = []
        var bestRMS: Float = 0
        
        let stride = segmentSize / 2
        var i = 0
        while i + segmentSize <= allSamples.count {
            let segment = Array(allSamples[i..<(i + segmentSize)])
            var rms: Float = 0
            vDSP_rmsqv(segment, 1, &rms, vDSP_Length(segmentSize))
            if rms > bestRMS {
                bestRMS = rms
                bestSegment = segment
            }
            i += stride
        }
        
        guard !bestSegment.isEmpty, bestRMS > 0.01 else {
            DispatchQueue.main.async {
                self.isAnalyzing = false
                self.analysisResult = AnalysisResult(
                    score: 0, f3Frequency: 0,
                    feedback: "Audio too quiet. Try speaking closer to the mic.",
                    grade: .noInput
                )
            }
            return
        }
        
        let magnitudes = bestSegment.withUnsafeBufferPointer { ptr in
            performFFT(on: ptr.baseAddress!, frameCount: bestSegment.count)
        }
        
        let formants = findFormants(magnitudes: magnitudes)
        let f3 = formants.count >= 3 ? formants[2] : 0
        let score = calculateRScore(f3: f3)
        let feedback = generateFeedback(score: score, f3: f3)
        let grade = gradeFromScore(score)
        
        DispatchQueue.main.async {
            self.f3Frequency = f3
            self.pronunciationScore = score
            self.isAnalyzing = false
            self.analysisResult = AnalysisResult(
                score: score, f3Frequency: f3,
                feedback: feedback, grade: grade
            )
        }
    }
    
    // MARK: - Formant Detection
    
    private func findFormants(magnitudes: [Float]) -> [Double] {
        let freqResolution = sampleRate / Double(fftSize)
        var formants: [Double] = []
        
        let formantRanges: [(Double, Double)] = [
            (200, 1000),   // F1
            (800, 2500),   // F2
            (1500, 3500)   // F3
        ]
        
        for range in formantRanges {
            let startBin = Int(range.0 / freqResolution)
            let endBin = min(Int(range.1 / freqResolution), magnitudes.count - 1)
            
            guard startBin < endBin, endBin < magnitudes.count else {
                formants.append(0)
                continue
            }
            
            var peakBin = startBin
            var peakVal: Float = 0
            
            for bin in startBin...endBin {
                if magnitudes[bin] > peakVal {
                    peakVal = magnitudes[bin]
                    peakBin = bin
                }
            }
            
            formants.append(Double(peakBin) * freqResolution)
        }
        
        return formants
    }
    
    // MARK: - R Sound Scoring
    
    private func calculateRScore(f3: Double) -> Double {
        guard f3 > 0 else { return 0 }
        
        let idealF3 = 2000.0
        let distance = abs(f3 - idealF3)
        
        if targetF3Range.contains(f3) {
            let normalizedDist = distance / 200.0
            return 100.0 - (normalizedDist * 20.0)
        } else if f3 >= 1500 && f3 <= 2500 {
            let distFromRange = f3 < 1800 ? 1800 - f3 : f3 - 2200
            let normalizedDist = distFromRange / 300.0
            return 80.0 - (normalizedDist * 30.0)
        } else {
            let distFromRange = f3 < 1500 ? 1500 - f3 : f3 - 2500
            let normalizedDist = min(distFromRange / 1000.0, 1.0)
            return 50.0 - (normalizedDist * 50.0)
        }
    }
    
    private func generateFeedback(score: Double, f3: Double) -> String {
        if score >= 85 {
            return "Excellent R sound! Your tongue position is spot on. The third formant is right in the target zone."
        } else if score >= 70 {
            return "Good progress! Your R is getting closer. Try raising the back of your tongue a bit more toward the soft palate."
        } else if score >= 50 {
            return "Getting there! The R sound needs more tongue retraction. Pull the tongue back and raise it higher."
        } else if f3 > 2500 {
            return "Your sound is closer to a 'W'. Focus on curling your tongue back — the tip behind lower teeth, back raised high."
        } else {
            return "Keep practicing! Try the 'growl' exercise first to activate the right muscles, then attempt the R sound."
        }
    }
    
    private func gradeFromScore(_ score: Double) -> AnalysisGrade {
        if score >= 85 { return .excellent }
        if score >= 70 { return .good }
        if score >= 50 { return .improving }
        if score >= 25 { return .needsWork }
        return .noInput
    }
    
    // MARK: - Reset
    
    func reset() {
        frequencyMagnitudes = Array(repeating: 0, count: 64)
        pronunciationScore = 0
        f3Frequency = 0
        analysisResult = nil
        audioLevel = 0
    }
}

// MARK: - Models

struct AnalysisResult {
    let score: Double
    let f3Frequency: Double
    let feedback: String
    let grade: AnalysisGrade
}

enum AnalysisGrade {
    case excellent, good, improving, needsWork, noInput
    
    var emoji: String {
        switch self {
        case .excellent: return "🌟"
        case .good: return "👍"
        case .improving: return "📈"
        case .needsWork: return "💪"
        case .noInput: return "🎤"
        }
    }
    
    var label: String {
        switch self {
        case .excellent: return "Excellent"
        case .good: return "Good"
        case .improving: return "Improving"
        case .needsWork: return "Keep Trying"
        case .noInput: return "No Sound"
        }
    }
}
