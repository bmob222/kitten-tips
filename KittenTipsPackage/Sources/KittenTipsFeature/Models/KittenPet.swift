import SwiftUI
import UIKit
import Foundation

enum KittenAction: String, CaseIterable, Sendable {
    case idle = "idle"
    case walking = "walking"
    case sleeping = "sleeping"
    case eating = "eating"

    var frameCount: Int { 16 }

    var label: String {
        switch self {
        case .idle: "Chillin'"
        case .walking: "Exploring"
        case .sleeping: "Zzz..."
        case .eating: "Nom nom"
        }
    }

    var emoji: String {
        switch self {
        case .idle: "😺"
        case .walking: "🐾"
        case .sleeping: "😴"
        case .eating: "🍽️"
        }
    }
}

enum KittenMood: String, Sendable {
    case happy
    case content
    case hungry
    case sleepy
    case sad

    var emoji: String {
        switch self {
        case .happy: "😸"
        case .content: "😺"
        case .hungry: "🙀"
        case .sleepy: "😾"
        case .sad: "😿"
        }
    }

    var label: String {
        switch self {
        case .happy: "Happy"
        case .content: "Content"
        case .hungry: "Hungry"
        case .sleepy: "Sleepy"
        case .sad: "Lonely"
        }
    }

    var tintColor: String {
        switch self {
        case .happy: "pink"
        case .content: "mint"
        case .hungry: "orange"
        case .sleepy: "indigo"
        case .sad: "gray"
        }
    }
}

@MainActor
@Observable
final class KittenPet {
    var name: String = "Whiskers"
    var currentAction: KittenAction = .idle
    var position: CGPoint = CGPoint(x: 200, y: 400)
    var isFlipped: Bool = false
    var happiness: Double = 0.8
    var hunger: Double = 0.5
    var energy: Double = 0.7
    var showBubble: Bool = false
    var bubbleText: String = ""

    private var actionTimer: Timer?
    private var statTimer: Timer?
    private var saveTimer: Timer?
    private var moveTarget: CGPoint?

    var mood: KittenMood {
        if hunger < 0.25 { return .hungry }
        if energy < 0.25 { return .sleepy }
        if happiness < 0.3 { return .sad }
        if happiness > 0.75 && hunger > 0.5 && energy > 0.5 { return .happy }
        return .content
    }

    private struct PersistedState: Codable {
        var name: String
        var happiness: Double
        var hunger: Double
        var energy: Double
        var lastUpdated: Date
    }

    private static let persistenceKey = "kittentips_pet_state"

    init() {
        restore()
    }

    private func restore() {
        guard
            let data = UserDefaults.standard.data(forKey: Self.persistenceKey),
            let state = try? JSONDecoder().decode(PersistedState.self, from: data)
        else { return }

        name = state.name

        // Decay stats proportional to seconds since last save, matching
        // the live decay rate (~every 30s: hunger -0.05, energy -0.03, happiness -0.02).
        let elapsed = max(0, Date().timeIntervalSince(state.lastUpdated))
        let ticks = elapsed / 30.0
        hunger = max(0, state.hunger - 0.05 * ticks)
        energy = max(0, state.energy - 0.03 * ticks)
        happiness = max(0, state.happiness - 0.02 * ticks)
    }

    func save() {
        let state = PersistedState(
            name: name,
            happiness: happiness,
            hunger: hunger,
            energy: energy,
            lastUpdated: Date()
        )
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: Self.persistenceKey)
        }
    }

    func startLife() {
        // Change actions periodically
        actionTimer = Timer.scheduledTimer(withTimeInterval: 8, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.pickNextAction()
            }
        }
        // Decay stats slowly
        statTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.decayStats()
            }
        }
        // Persist periodically so quits/crashes don't lose progress
        saveTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.save()
            }
        }
    }

    func stopLife() {
        actionTimer?.invalidate()
        statTimer?.invalidate()
        saveTimer?.invalidate()
        save()
    }

    func feed() {
        hunger = min(1.0, hunger + 0.3)
        happiness = min(1.0, happiness + 0.1)
        currentAction = .eating
        showBubbleMessage("Yum! 😋")
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
            self?.currentAction = .idle
        }
    }

    func pet() {
        happiness = min(1.0, happiness + 0.2)
        showBubbleMessage("Purrrr 💕")
    }

    func nap() {
        currentAction = .sleeping
        energy = min(1.0, energy + 0.4)
        showBubbleMessage("Zzz...")
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) { [weak self] in
            self?.currentAction = .idle
            self?.showBubbleMessage("That was nice! 😸")
        }
    }

    private func pickNextAction() {
        let roll = Double.random(in: 0...1)

        switch mood {
        case .sleepy:
            currentAction = .sleeping
            showBubbleMessage("So tired... 😴")
            return
        case .hungry:
            showBubbleMessage("I'm hungry! 🍽️")
            return
        case .sad:
            showBubbleMessage("Miss you... 😿")
            return
        case .happy, .content:
            break
        }

        if roll < 0.4 {
            // Walk to a random position
            currentAction = .walking
            let screenWidth = UIScreen.main.bounds.width
            let newX = CGFloat.random(in: 40...(screenWidth - 40))
            isFlipped = newX < position.x
            moveTarget = CGPoint(x: newX, y: position.y)
            withAnimation(.easeInOut(duration: 3)) {
                position = moveTarget!
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                self?.currentAction = .idle
            }
        } else if roll < 0.6 {
            currentAction = .sleeping
            showBubbleMessage("Nap time 😴")
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
                self?.currentAction = .idle
            }
        } else {
            currentAction = .idle
            let phrases = ["*purrs*", "Meow!", "*stretches*", "*yawns*", "😺", "*tail swish*"]
            showBubbleMessage(phrases.randomElement()!)
        }
    }

    private func decayStats() {
        hunger = max(0, hunger - 0.05)
        energy = max(0, energy - 0.03)
        happiness = max(0, happiness - 0.02)
    }

    private func showBubbleMessage(_ text: String) {
        bubbleText = text
        showBubble = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.showBubble = false
        }
    }
}
