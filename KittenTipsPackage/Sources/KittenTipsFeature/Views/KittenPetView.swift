import SwiftUI

/// Animated kitten pet overlay that lives on the app.
/// Uses spritesheet frames for idle, walk, sleep, eat animations.
/// Falls back to emoji-based animation if sprites aren't loaded yet.
struct KittenPetView: View {
    @Environment(KittenPet.self) private var pet
    @Environment(BreedLibrary.self) private var breedLibrary
    @State private var currentFrame: Int = 0
    @State private var animationTimer: Timer?
    @State private var bounceAmount: CGFloat = 0
    @State private var showActions = false

    var body: some View {
        ZStack {
            // Speech bubble
            if pet.showBubble {
                speechBubble
                    .transition(.scale.combined(with: .opacity))
            }

            // The kitten
            kittenSprite
                .onTapGesture {
                    withAnimation(.spring(duration: 0.3)) {
                        showActions.toggle()
                    }
                    pet.pet()
                }

            // Action buttons
            if showActions {
                actionButtons
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .position(pet.position)
        .onAppear {
            pet.startLife()
            startFrameAnimation()
        }
        .onDisappear {
            pet.stopLife()
            animationTimer?.invalidate()
        }
    }

    // MARK: - Kitten Sprite

    private var kittenSprite: some View {
        ZStack {
            // Try to load spritesheet frame, fallback to emoji
            if let image = loadSpriteFrame(action: pet.currentAction, frame: currentFrame) {
                Image(uiImage: image)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .scaleEffect(x: pet.isFlipped ? -1 : 1, y: 1)
            } else {
                // Fallback: emoji-based kitten
                fallbackKitten
            }
        }
        .offset(y: bounceAmount)
        .onChange(of: pet.currentAction) {
            currentFrame = 0
            if pet.currentAction == .walking {
                withAnimation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true)) {
                    bounceAmount = -5
                }
            } else {
                withAnimation(.easeOut(duration: 0.2)) {
                    bounceAmount = 0
                }
            }
        }
    }

    private var fallbackKitten: some View {
        VStack(spacing: 2) {
            Text(kittenEmoji)
                .font(.system(size: 50))
                .scaleEffect(x: pet.isFlipped ? -1 : 1, y: 1)

            // Status indicator
            HStack(spacing: 2) {
                Circle()
                    .fill(pet.happiness > 0.5 ? .green : pet.happiness > 0.2 ? .yellow : .red)
                    .frame(width: 6, height: 6)
                Text(pet.currentAction.label)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var kittenEmoji: String {
        switch pet.currentAction {
        case .walking: breedLibrary.selected.emoji
        case .sleeping: "😴"
        case .eating: "😋"
        case .idle: pet.mood.emoji
        }
    }

    // MARK: - Speech Bubble

    private var speechBubble: some View {
        Text(pet.bubbleText)
            .font(.caption.bold())
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
            .offset(y: -55)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 12) {
            actionButton(icon: "fork.knife", label: "Feed", color: .orange) {
                pet.feed()
                showActions = false
            }
            actionButton(icon: "hand.raised.fill", label: "Pet", color: .pink) {
                pet.pet()
                showActions = false
            }
            actionButton(icon: "moon.fill", label: "Nap", color: .indigo) {
                pet.nap()
                showActions = false
            }
        }
        .offset(y: 55)
    }

    private func actionButton(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.caption)
                Text(label)
                    .font(.system(size: 8, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(width: 44, height: 44)
            .background(color)
            .clipShape(Circle())
            .shadow(color: color.opacity(0.4), radius: 4, y: 2)
        }
    }

    // MARK: - Sprite Loading

    private func loadSpriteFrame(action: KittenAction, frame: Int) -> UIImage? {
        let prefix = breedLibrary.selected.spritePrefix
        if !prefix.isEmpty {
            let prefixed = "\(prefix)_\(action.rawValue)_\(frame)"
            if let image = UIImage(named: prefixed) { return image }
        }
        // Fall back to legacy naming (used by Whiskers, and by any breed
        // whose sheets haven't been sliced yet).
        return UIImage(named: "\(action.rawValue)_\(frame)")
    }

    private func startFrameAnimation() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { _ in
            Task { @MainActor in
                currentFrame = (currentFrame + 1) % pet.currentAction.frameCount
            }
        }
    }
}

// MARK: - Pet Overlay Modifier

struct KittenPetOverlay: ViewModifier {
    @Environment(KittenPet.self) private var pet

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                KittenPetView()
                    .padding(.bottom, 60) // Above tab bar
            }
    }
}

extension View {
    func withKittenPet() -> some View {
        modifier(KittenPetOverlay())
    }
}
