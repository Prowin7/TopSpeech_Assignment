# 🗣️ Practice Streak Tracker

**A gamified speech therapy companion app for mastering the R sound — powered by real-time FFT pronunciation analysis.**

Built for the TopSpeech Health iOS Developer Assessment. Designed to motivate consistent daily practice through streak tracking, milestone celebrations, and on-device acoustic analysis using Apple's Accelerate framework.

---

## ✨ Key Features

### 🎯 Guided Practice Sessions
Five clinically-informed exercises from the TopSpeech 13-week R sound protocol:
- **The Growl** — activate dormant tongue muscles
- **Hidden Position** — learn the secret R tongue placement
- **Buttercup Breakdown** — isolate the "er" sound
- **Vocalic R Words** — practice all 5 R types (AR, OR, ER, IRE, AIR)
- **Sentence Flow** — build fluency with emotional context

### 🔬 R Sound Lab (FFT Pronunciation Analysis)
Real-time pronunciation scoring using Fourier Transform:
- **Live spectrogram** — 64-bar frequency visualization color-coded by formant zones (F1, F2, F3)
- **Formant extraction** — detects the third formant (F3) to evaluate R sound accuracy
- **Scoring engine** — compares user's F3 (~1800–2200 Hz for correct R) against reference ranges
- **SLP-style feedback** — actionable tips based on acoustic analysis

> **How it works:** Record a word → AVAudioEngine captures audio → vDSP FFT extracts frequency spectrum → Formant peaks identified → F3 compared to target range → Score + feedback displayed

### 🔥 Streak & Gamification
- **Daily streak tracking** with calendar heatmap
- **Streak freezes** — protect your streak on off days
- **12 unlockable badges** (First Steps, Week Warrior, Month Master, etc.)
- **Milestone celebrations** with confetti animations
- **Motivational quotes** from the TopSpeech blog

### 🧠 Personalized Onboarding
5-page questionnaire at first launch:
1. Name input for personalized greetings
2. Which R sounds are hardest (multi-select)
3. Challenging speaking situations (grid select)
4. Confidence level (1-5 scale with emojis)
5. Speech therapy experience level

### ⚙️ Additional Features
- Dark/Light mode toggle (persisted)
- Local push notification reminders
- Haptic feedback throughout
- Statistics dashboard with practice analytics
- Demo data loader for testing

---

## 📱 Screenshots

| Dashboard | Practice Session | R Sound Lab |
|-----------|-----------------|-------------|
| Streak hero card, stats, calendar heatmap | Guided exercises with recording animation | Live spectrogram with F3 scoring |

---

## 🛠️ Setup Instructions

### Prerequisites
- **Xcode 15.0+** (tested with Xcode 16)
- **iOS 16.0+** deployment target
- **iPhone 16 Pro Max** (or any iOS 16+ device/simulator)
- No external dependencies — uses only Apple frameworks

### Step 1: Clone the Repository
```bash
git clone https://github.com/YOUR_USERNAME/PracticeStreakTracker.git
cd PracticeStreakTracker
```

### Step 2: Open in Xcode
```bash
open streaks.xcodeproj
```
> If named differently, open whatever `.xcodeproj` file is in the directory.

### Step 3: Configure the Project
1. Select the project in the navigator → **Signing & Capabilities**
2. Set your **Team** (personal or organization Apple Developer account)
3. Change the **Bundle Identifier** to something unique (e.g., `com.yourname.practicestreak`)

### Step 4: Add Required Privacy Key
1. Select the **target** → **Info** tab
2. Add a new key: **`Privacy - Microphone Usage Description`**
3. Set value: `Analyze your R sound pronunciation`

> ⚠️ **The app will crash without this key** when opening R Sound Lab. iOS terminates apps that access the microphone without a declared usage description.

### Step 5: Select Device & Run
1. Choose **iPhone 16 Pro Max** from the device dropdown (or your connected device)
2. Press **⌘R** to build and run

### Quick Testing
After launch, tap **⋯ → Load Demo Data** to populate the calendar with sample practice history and test all features immediately.

---

## 🏛️ Architecture

**Pattern:** MVVM (Model-View-ViewModel)

```
PracticeStreakTracker/
├── App/
│   └── PracticeStreakTrackerApp.swift      # Entry point, onboarding gate
├── Models/
│   ├── StreakData.swift                    # Core data model (Codable)
│   ├── PracticeDay.swift                  # Daily practice record
│   ├── Badge.swift                        # Achievement definitions
│   └── Milestone.swift                    # Streak milestone definitions
├── ViewModels/
│   └── StreakViewModel.swift              # Business logic, state management
├── Views/
│   ├── OnboardingView.swift              # 5-page personality questionnaire
│   ├── DashboardView.swift               # Main screen with streak + stats
│   ├── PracticeSessionView.swift         # Guided exercise flow
│   ├── PronunciationAnalysisView.swift   # R Sound Lab with spectrogram
│   ├── CalendarHeatmapView.swift         # GitHub-style heatmap
│   ├── StatisticsView.swift              # Practice analytics
│   ├── BadgesView.swift                  # Achievement gallery
│   ├── SettingsView.swift                # Preferences & notifications
│   ├── StreakFreezeView.swift            # Freeze management
│   └── MilestoneCelebrationView.swift    # Confetti overlay
├── Services/
│   ├── AudioAnalysisService.swift        # AVAudioEngine + vDSP FFT
│   ├── NotificationService.swift         # Local push notifications
│   ├── PersistenceService.swift          # UserDefaults persistence
│   └── HapticService.swift              # UIImpactFeedbackGenerator
└── Helpers/
    ├── Color+Extensions.swift            # Brand colors (TopSpeech palette)
    └── Date+Extensions.swift             # Date formatting utilities
```

---

## 🔊 FFT & Acoustic Analysis — Technical Deep Dive

### The Science Behind R Sound Detection

The English R sound (rhotic approximant) has a distinctive acoustic signature in its **third formant (F3)**:

| Sound | F3 Frequency | Classification |
|-------|-------------|---------------|
| Correct R | 1800–2200 Hz | ✅ Target zone |
| W-substitution | 2500–3000 Hz | ❌ Common error |
| L-substitution | 2800–3200 Hz | ❌ Less common |

### Implementation Pipeline

```
Microphone Input (44.1 kHz)
    ↓
AVAudioEngine tap (4096-sample buffers)
    ↓
Hanning Window (reduce spectral leakage)
    ↓
vDSP FFT (4096-point, radix-2)
    ↓
Magnitude Spectrum (dB scale, normalized)
    ↓
Formant Peak Detection (F1: 200-1000 Hz, F2: 800-2500 Hz, F3: 1500-3500 Hz)
    ↓
F3 Scoring (distance from 2000 Hz ideal)
    ↓
Grade + Feedback
```

### Frameworks Used
- **Accelerate** (`vDSP`) — hardware-accelerated FFT, windowing, magnitude calculation
- **AVFoundation** (`AVAudioEngine`) — real-time microphone capture
- No third-party DSP libraries required

---

## 📦 Dependencies

**None.** This project uses only Apple-native frameworks:

| Framework | Purpose |
|-----------|---------|
| SwiftUI | UI layer |
| Foundation | Data models, persistence |
| Accelerate | FFT via vDSP |
| AVFoundation | Audio recording |
| UserNotifications | Local reminders |
| UIKit | Haptic feedback |

---

## 📝 Data Persistence

All data is stored locally via `UserDefaults` with `JSONEncoder`/`JSONDecoder`:
- Streak history and practice days
- User preferences (dark mode, notifications)
- Onboarding profile (name, difficulties, confidence)
- Badge unlock status
- No server, no accounts, no internet required

---

## 🎨 Design Language

- **Glassmorphic cards** with blur and opacity layers
- **Dark mode default** with user-configurable light mode
- **Brand palette** inspired by TopSpeech Health
- **Micro-animations** — pulse effects, spring transitions, waveform bars
- **Haptic feedback** on key interactions

---

## 📋 TopSpeech Assessment Checklist

- [x] Practice streak tracking with calendar visualization
- [x] Gamification (badges, milestones, freezes)
- [x] Real speech therapy exercises from the blog
- [x] Motivational content from TopSpeech founder
- [x] Push notification reminders
- [x] Dark/Light mode
- [x] Onboarding questionnaire
- [x] **Bonus:** On-device FFT pronunciation analysis
- [x] **Bonus:** Live spectrogram visualization
- [x] **Bonus:** Personalized dashboard with user's name

---

## 👤 Author

**Praveen** — Built for the TopSpeech Health iOS Developer Assessment

---

## 📄 License

This project is built as an assessment submission for TopSpeech Health.
