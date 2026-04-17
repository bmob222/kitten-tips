import Foundation

struct KittenBreed: Identifiable, Hashable, Sendable, Codable {
    let id: String
    let name: String
    let tagline: String
    let emoji: String
    let spritePrefix: String
    let unlockStreak: Int

    var isDefault: Bool { unlockStreak == 0 }

    /// Whiskers uses the legacy sprite naming (no prefix): idle_0...idle_15.
    /// New breeds use a breed-prefixed naming: midnight_idle_0...midnight_idle_15.
    static let whiskers = KittenBreed(
        id: "whiskers",
        name: "Whiskers",
        tagline: "The classic ginger tabby you know and love",
        emoji: "🐱",
        spritePrefix: "",
        unlockStreak: 0
    )

    static let all: [KittenBreed] = [
        .whiskers,
        KittenBreed(
            id: "midnight",
            name: "Midnight",
            tagline: "A sleek black kitten with a mischievous streak",
            emoji: "🐈‍⬛",
            spritePrefix: "midnight",
            unlockStreak: 7
        ),
        KittenBreed(
            id: "luna",
            name: "Luna",
            tagline: "A silver tabby with moonlit eyes",
            emoji: "🌙",
            spritePrefix: "luna",
            unlockStreak: 14
        ),
        KittenBreed(
            id: "snowball",
            name: "Snowball",
            tagline: "A fluffy white Persian dreamer",
            emoji: "🐈",
            spritePrefix: "snowball",
            unlockStreak: 30
        ),
        KittenBreed(
            id: "mittens",
            name: "Mittens",
            tagline: "A calico diplomat with attitude",
            emoji: "🐾",
            spritePrefix: "mittens",
            unlockStreak: 60
        ),
        KittenBreed(
            id: "pharaoh",
            name: "Pharaoh",
            tagline: "Ancient wisdom in feline form",
            emoji: "🏆",
            spritePrefix: "pharaoh",
            unlockStreak: 100
        ),
    ]

    static func byId(_ id: String) -> KittenBreed {
        all.first(where: { $0.id == id }) ?? .whiskers
    }
}

@MainActor
@Observable
final class BreedLibrary {
    private(set) var selected: KittenBreed = .whiskers

    private static let selectedKey = "kittentips_selected_breed"

    init() {
        if let saved = UserDefaults.standard.string(forKey: Self.selectedKey) {
            selected = KittenBreed.byId(saved)
        }
    }

    func isUnlocked(_ breed: KittenBreed, longestStreak: Int) -> Bool {
        longestStreak >= breed.unlockStreak
    }

    func select(_ breed: KittenBreed, longestStreak: Int) -> Bool {
        guard isUnlocked(breed, longestStreak: longestStreak) else { return false }
        selected = breed
        UserDefaults.standard.set(breed.id, forKey: Self.selectedKey)
        return true
    }
}
