import Foundation

struct CatTip: Identifiable, Sendable {
    let id: Int
    let title: String
    let body: String
    let category: TipCategory
    let icon: String
    let isFavorite: Bool

    init(id: Int, title: String, body: String, category: TipCategory, icon: String = "", isFavorite: Bool = false) {
        self.id = id
        self.title = title
        self.body = body
        self.category = category
        self.icon = icon.isEmpty ? category.icon : icon
        self.isFavorite = isFavorite
    }
}

enum TipCategory: String, CaseIterable, Identifiable, Sendable {
    case newKitten = "New Kitten"
    case feeding = "Feeding"
    case health = "Health"
    case behavior = "Behavior"
    case grooming = "Grooming"
    case training = "Training"
    case safety = "Safety"
    case bonding = "Bonding"
    case senior = "Senior Cats"
    case fun = "Fun Facts"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .newKitten: "pawprint.fill"
        case .feeding: "fork.knife"
        case .health: "heart.fill"
        case .behavior: "brain.head.profile.fill"
        case .grooming: "comb.fill"
        case .training: "graduationcap.fill"
        case .safety: "shield.fill"
        case .bonding: "hand.raised.fill"
        case .senior: "clock.fill"
        case .fun: "sparkles"
        }
    }

    var color: String {
        switch self {
        case .newKitten: "pink"
        case .feeding: "orange"
        case .health: "red"
        case .behavior: "purple"
        case .grooming: "blue"
        case .training: "green"
        case .safety: "yellow"
        case .bonding: "mint"
        case .senior: "gray"
        case .fun: "indigo"
        }
    }
}

enum KittenAge: String, CaseIterable, Identifiable, Sendable {
    case newborn = "0-2 Weeks"
    case infant = "2-4 Weeks"
    case baby = "4-8 Weeks"
    case kitten = "2-4 Months"
    case junior = "4-6 Months"
    case adolescent = "6-12 Months"
    case adult = "1-7 Years"
    case senior = "7+ Years"

    var id: String { rawValue }

    var milestones: [String] {
        switch self {
        case .newborn: [
            "Eyes and ears closed",
            "Cannot regulate body temperature",
            "Needs feeding every 2 hours",
            "Sleeps 90% of the time",
            "Weighs 3-5 oz at birth",
        ]
        case .infant: [
            "Eyes begin to open (blue at first)",
            "Ears start to unfold",
            "Begins to crawl and stand",
            "Can start to hear sounds",
            "Feed every 3-4 hours",
        ]
        case .baby: [
            "Running and playing begins",
            "Start weaning onto wet food",
            "Litter box training starts",
            "First vaccinations at 6 weeks",
            "Socialization window is critical",
        ]
        case .kitten: [
            "Full set of baby teeth",
            "High energy — play constantly",
            "Continue vaccination schedule",
            "Can be spayed/neutered (ask your vet)",
            "Establish feeding routine (3x/day)",
        ]
        case .junior: [
            "Adult teeth coming in",
            "Reaching sexual maturity",
            "Spay/neuter recommended",
            "Switch to 2x daily feeding",
            "Personality becoming established",
        ]
        case .adolescent: [
            "Nearly full-grown size",
            "May test boundaries",
            "Complete vaccination series",
            "Indoor cats: establish territory",
            "Regular vet checkups",
        ]
        case .adult: [
            "Fully grown",
            "Annual vet visits",
            "Maintain healthy weight",
            "Dental care important",
            "Watch for behavior changes",
        ]
        case .senior: [
            "Bi-annual vet visits recommended",
            "May need senior diet",
            "Watch for arthritis signs",
            "Keep environment comfortable",
            "Extra warmth and soft bedding",
        ]
        }
    }
}

struct BehaviorSign: Identifiable, Sendable {
    let id = UUID()
    let behavior: String
    let meaning: String
    let icon: String
    let mood: String // happy, anxious, angry, sick, playful, relaxed
}
