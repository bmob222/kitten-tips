import SwiftUI

struct CelebrationView: View {
    let milestone: Int
    let onDismiss: () -> Void

    @State private var confettiBurst = false
    @State private var showCard = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            ConfettiLayer(isActive: confettiBurst)
                .allowsHitTesting(false)

            VStack(spacing: 18) {
                Text("🎉")
                    .font(.system(size: 72))
                    .scaleEffect(showCard ? 1 : 0.3)
                    .rotationEffect(.degrees(showCard ? 0 : -30))

                Text("\(milestone)-Day Streak!")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)

                Text(headline)
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                if let unlocked = unlockedBreed {
                    VStack(spacing: 6) {
                        Text(unlocked.emoji)
                            .font(.system(size: 44))
                        Text("\(unlocked.name) unlocked!")
                            .font(.headline.bold())
                            .foregroundStyle(.white)
                        Text(unlocked.tagline)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .padding()
                    .background(.white.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                }

                Button {
                    dismiss()
                } label: {
                    Text("Keep going")
                        .font(.headline)
                        .foregroundStyle(.pink)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(.white)
                        .clipShape(Capsule())
                }
                .padding(.top, 8)
            }
            .padding(.vertical, 32)
            .scaleEffect(showCard ? 1 : 0.6)
            .opacity(showCard ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(duration: 0.55, bounce: 0.4)) {
                showCard = true
            }
            confettiBurst = true
        }
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.2)) {
            showCard = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onDismiss()
        }
    }

    private var headline: String {
        switch milestone {
        case 1: "You made it back! Whiskers is thrilled."
        case 3: "Three days strong. Great habit forming."
        case 7: "A full week! You're a real cat parent now."
        case 14: "Two weeks of kitten wisdom. Amazing."
        case 30: "A whole month! Whiskers adores you."
        case 60: "Two months — a legendary commitment."
        case 100: "100 days. You and Whiskers are soulmates."
        default: "Incredible milestone!"
        }
    }

    private var unlockedBreed: KittenBreed? {
        KittenBreed.all.first(where: { $0.unlockStreak == milestone })
    }
}

private struct ConfettiLayer: View {
    let isActive: Bool
    private let pieces: [ConfettiPiece] = (0..<60).map { _ in ConfettiPiece.random() }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(pieces) { piece in
                    Circle()
                        .fill(piece.color)
                        .frame(width: piece.size, height: piece.size)
                        .position(
                            x: proxy.size.width * piece.startX,
                            y: isActive ? proxy.size.height * 1.1 : -40
                        )
                        .rotationEffect(.degrees(isActive ? piece.rotation : 0))
                        .opacity(isActive ? 0 : 1)
                        .animation(
                            .easeIn(duration: piece.duration).delay(piece.delay),
                            value: isActive
                        )
                }
            }
        }
    }
}

private struct ConfettiPiece: Identifiable {
    let id = UUID()
    let startX: CGFloat
    let size: CGFloat
    let color: Color
    let rotation: Double
    let duration: Double
    let delay: Double

    static func random() -> ConfettiPiece {
        let palette: [Color] = [.pink, .orange, .yellow, .mint, .purple, .cyan]
        return ConfettiPiece(
            startX: .random(in: 0...1),
            size: .random(in: 6...12),
            color: palette.randomElement()!,
            rotation: .random(in: 180...720),
            duration: .random(in: 1.6...2.8),
            delay: .random(in: 0...0.4)
        )
    }
}
