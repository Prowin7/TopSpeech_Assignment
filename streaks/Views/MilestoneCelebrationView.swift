import SwiftUI

/// Full-screen milestone celebration overlay with confetti animation
struct MilestoneCelebrationView: View {
    let milestone: Milestone
    let onDismiss: () -> Void
    
    @State private var showContent = false
    @State private var confettiParticles: [ConfettiParticle] = []
    @State private var animateConfetti = false
    
    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture(perform: onDismiss)
            
            // Confetti
            ForEach(confettiParticles) { particle in
                Text(particle.emoji)
                    .font(.system(size: particle.size))
                    .position(
                        x: particle.x,
                        y: animateConfetti ? particle.endY : particle.startY
                    )
                    .opacity(animateConfetti ? 0 : 1)
                    .rotationEffect(.degrees(animateConfetti ? particle.rotation : 0))
            }
            
            // Celebration card
            VStack(spacing: 24) {
                // Milestone emoji
                Text(milestone.emoji)
                    .font(.system(size: 80))
                    .scaleEffect(showContent ? 1.0 : 0.3)
                
                // Title
                Text(milestone.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .scaleEffect(showContent ? 1.0 : 0.8)
                
                // Day count
                Text("\(milestone.days) Days!")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.tsGold, .tsAccent],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                // Description
                Text(milestone.description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                // Dismiss button
                Button(action: onDismiss) {
                    Text("Keep Going! 💪")
                        .font(.headline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(LinearGradient.tsPrimaryGradient)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 40)
                .padding(.top, 8)
            }
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 50)
        }
        .onAppear {
            generateConfetti()
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showContent = true
            }
            
            withAnimation(.easeOut(duration: 3.0)) {
                animateConfetti = true
            }
            
            HapticService.shared.success()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Milestone achieved: \(milestone.title). \(milestone.description)")
        .accessibilityAddTraits(.isModal)
    }
    
    // MARK: - Confetti Generation
    
    private func generateConfetti() {
        let emojis = ["🎉", "🎊", "✨", "⭐", "🌟", "🔥", "💪", "🏆", "🥇", "💫"]
        let screenWidth = UIScreen.main.bounds.width
        
        confettiParticles = (0..<30).map { _ in
            ConfettiParticle(
                emoji: emojis.randomElement()!,
                x: CGFloat.random(in: 0...screenWidth),
                startY: CGFloat.random(in: -100...(-20)),
                endY: UIScreen.main.bounds.height + 100,
                size: CGFloat.random(in: 16...32),
                rotation: Double.random(in: 180...720)
            )
        }
    }
}

// MARK: - Confetti Particle

struct ConfettiParticle: Identifiable {
    let id = UUID()
    let emoji: String
    let x: CGFloat
    let startY: CGFloat
    let endY: CGFloat
    let size: CGFloat
    let rotation: Double
}

#Preview {
    MilestoneCelebrationView(
        milestone: Milestone.all[1],
        onDismiss: {}
    )
}
