import Foundation

@MainActor
@Observable
final class TipDatabase {
    var favorites: Set<Int> = []
    private let favoritesKey = "kittentips_favorites"

    init() {
        if let saved = UserDefaults.standard.array(forKey: favoritesKey) as? [Int] {
            favorites = Set(saved)
        }
    }

    func toggleFavorite(_ tipId: Int) {
        if favorites.contains(tipId) {
            favorites.remove(tipId)
        } else {
            favorites.insert(tipId)
        }
        UserDefaults.standard.set(Array(favorites), forKey: favoritesKey)
    }

    func isFavorite(_ tipId: Int) -> Bool {
        favorites.contains(tipId)
    }

    var tipOfTheDay: CatTip {
        tip(for: Date())
    }

    func tip(for date: Date) -> CatTip {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        let index = (dayOfYear - 1) % Self.allTips.count
        return Self.allTips[index]
    }

    func tips(for category: TipCategory) -> [CatTip] {
        Self.allTips.filter { $0.category == category }
    }

    var favoriteTips: [CatTip] {
        Self.allTips.filter { favorites.contains($0.id) }
    }

    // MARK: - All Tips

    static let allTips: [CatTip] = [
        // New Kitten
        CatTip(id: 1, title: "Kitten-Proof Your Home", body: "Remove small objects, secure cords, close toilet lids, and block gaps behind appliances. Kittens explore EVERYTHING with their mouths.", category: .newKitten),
        CatTip(id: 2, title: "First Night Home", body: "Set up a small, quiet room with food, water, litter box, and a cozy bed. Don't overwhelm them with the whole house on day one. Let them come to you.", category: .newKitten),
        CatTip(id: 3, title: "The 3-3-3 Rule", body: "3 days to decompress, 3 weeks to learn your routine, 3 months to feel at home. Be patient — your kitten is adjusting to a whole new world.", category: .newKitten),
        CatTip(id: 4, title: "Litter Box Basics", body: "One litter box per cat, plus one extra. Place them in quiet, accessible spots. Scoop daily. Kittens prefer unscented, fine-grain litter.", category: .newKitten),
        CatTip(id: 5, title: "First Vet Visit", body: "Schedule a vet appointment within the first week. They'll check for parasites, start vaccinations, and give you a health baseline.", category: .newKitten),

        // Feeding
        CatTip(id: 10, title: "Wet Food is King", body: "Cats are desert animals — they don't drink enough water on their own. Wet food keeps them hydrated and is closer to their natural diet.", category: .feeding),
        CatTip(id: 11, title: "Never Give Milk", body: "Most adult cats are lactose intolerant. Cow's milk causes diarrhea and stomach pain. If you want to treat them, use cat-specific milk.", category: .feeding),
        CatTip(id: 12, title: "Feeding Schedule", body: "Kittens under 6 months: 3-4 small meals/day. Adults: 2 meals/day. Free-feeding dry food leads to obesity — portion control matters.", category: .feeding),
        CatTip(id: 13, title: "Toxic Foods", body: "NEVER feed: onions, garlic, chocolate, grapes, raisins, xylitol, alcohol, raw dough, or caffeine. These are all toxic to cats.", category: .feeding),
        CatTip(id: 14, title: "Water Fountain Hack", body: "Cats prefer running water. A $20 pet fountain can triple their water intake. Place it away from their food — cats instinctively avoid water near food.", category: .feeding),
        CatTip(id: 15, title: "Read the Label", body: "Look for 'complete and balanced' on cat food. The first ingredient should be a named protein (chicken, salmon), not 'meat by-products.'", category: .feeding),

        // Health
        CatTip(id: 20, title: "Purring Isn't Always Happy", body: "Cats also purr when they're stressed, sick, or in pain. It's a self-soothing mechanism. If your cat purrs while hiding or not eating, see a vet.", category: .health),
        CatTip(id: 21, title: "The Hiding Red Flag", body: "A cat that suddenly starts hiding is telling you something is wrong. Pain, illness, or extreme stress. If hiding lasts more than 24 hours, call the vet.", category: .health),
        CatTip(id: 22, title: "Dental Disease is #1", body: "By age 3, most cats have dental disease. Symptoms: bad breath, drooling, dropping food, pawing at mouth. Annual dental checks save money long-term.", category: .health),
        CatTip(id: 23, title: "Weight Check", body: "You should feel your cat's ribs easily but not see them. If you can't feel ribs, your cat is overweight. Obesity leads to diabetes, arthritis, and shorter life.", category: .health),
        CatTip(id: 24, title: "Vaccination Schedule", body: "Core vaccines: FVRCP (distemper combo) at 6-8 weeks, boosters at 12 and 16 weeks. Rabies at 12-16 weeks. Annual or 3-year boosters after.", category: .health),
        CatTip(id: 25, title: "Spay/Neuter Benefits", body: "Prevents certain cancers, reduces spraying, stops yowling, prevents unwanted litters. Best done at 4-6 months. Recovery takes 10-14 days.", category: .health),

        // Behavior
        CatTip(id: 30, title: "Slow Blink = I Love You", body: "When your cat slow-blinks at you, they're saying 'I trust you.' Slow-blink back — it's how cats say I love you.", category: .behavior),
        CatTip(id: 31, title: "Zoomies Are Normal", body: "Random bursts of running at 3 AM? That's pent-up energy from their crepuscular nature (most active at dawn/dusk). More playtime before bed helps.", category: .behavior),
        CatTip(id: 32, title: "Kneading (Making Biscuits)", body: "When cats knead with their paws, it's a comforting behavior from nursing as kittens. It means they feel safe and content with you.", category: .behavior),
        CatTip(id: 33, title: "Belly Trap", body: "A cat showing their belly is showing trust — NOT asking for belly rubs. Most cats will grab and bite if you touch their belly. It's a trust display, not an invitation.", category: .behavior),
        CatTip(id: 34, title: "Tail Language", body: "Up = confident/happy. Puffed = scared/angry. Low = insecure. Twitching tip = focused/hunting. Wrapped around you = affection.", category: .behavior),
        CatTip(id: 35, title: "Scratching Isn't Bad", body: "Cats NEED to scratch — it removes dead nail sheaths and marks territory. Provide scratching posts near where they sleep. They stretch and scratch after naps.", category: .behavior),

        // Grooming
        CatTip(id: 40, title: "Brushing Prevents Hairballs", body: "Brush your cat 2-3 times per week. Long-haired cats need daily brushing. It reduces hairballs, shedding, and mats. Most cats learn to love it.", category: .grooming),
        CatTip(id: 41, title: "Don't Over-Bathe", body: "Cats are self-cleaning. Only bathe if they get into something dirty/sticky, have a skin condition, or can't groom themselves. Too many baths dry out their skin.", category: .grooming),
        CatTip(id: 42, title: "Nail Trimming Tips", body: "Trim every 2-3 weeks. Only cut the clear tip — avoid the pink quick. Start young so they get used to it. One paw per session is fine if they're squirmy.", category: .grooming),
        CatTip(id: 43, title: "Ear Check Weekly", body: "Peek inside their ears weekly. Healthy = pink and clean. Dark discharge, redness, or odor means ear mites or infection. See your vet.", category: .grooming),

        // Training
        CatTip(id: 50, title: "Cats CAN Be Trained", body: "Use treats and clicker training. Cats learn sit, high-five, come, and even fetch. Keep sessions under 5 minutes — they have short attention spans.", category: .training),
        CatTip(id: 51, title: "Never Punish", body: "Cats don't understand punishment. Spraying water or yelling creates fear, not learning. Redirect unwanted behavior to an acceptable alternative instead.", category: .training),
        CatTip(id: 52, title: "Carrier Training", body: "Leave the carrier out with treats inside. Make it a cozy hangout spot. When vet day comes, your cat won't panic. This single tip saves so much stress.", category: .training),

        // Safety
        CatTip(id: 60, title: "Toxic Plants", body: "Lilies are DEADLY to cats — even the pollen. Also toxic: poinsettias, tulips, azaleas, sago palms, and pothos. Check every plant before bringing it home.", category: .safety),
        CatTip(id: 61, title: "Window Safety", body: "Cats can push through screens. 'High-rise syndrome' is real — cats fall from windows every day. Use secure screens or keep windows closed above ground floor.", category: .safety),
        CatTip(id: 62, title: "String is Dangerous", body: "Hair ties, yarn, ribbon, tinsel, and string can cause fatal intestinal blockages if swallowed. Never leave string toys unattended.", category: .safety),
        CatTip(id: 63, title: "Essential Oils Kill", body: "Many essential oils are toxic to cats: tea tree, eucalyptus, lavender, peppermint, citrus. Diffusers can cause respiratory distress. Keep them away from cats.", category: .safety),

        // Bonding
        CatTip(id: 70, title: "Let Them Come to You", body: "The fastest way to bond with a cat is to NOT chase them. Sit quietly, offer a finger to sniff, and let them approach on their terms.", category: .bonding),
        CatTip(id: 71, title: "Play = Love", body: "15 minutes of interactive play twice a day strengthens your bond more than anything. Wand toys mimic prey — cats need this hunting outlet.", category: .bonding),
        CatTip(id: 72, title: "The Head Bonk", body: "When your cat headbutts you, they're marking you with their scent glands. It means 'you're mine.' It's one of the highest compliments a cat gives.", category: .bonding),
        CatTip(id: 73, title: "Respect Their Space", body: "Cats need alone time. Provide hiding spots, cat trees, and high perches. A cat that can retreat when overwhelmed will trust you more.", category: .bonding),

        // Senior
        CatTip(id: 80, title: "Senior Cat Diet", body: "After age 7, switch to senior formula with higher protein and joint support. Senior cats need more frequent, smaller meals and extra hydration.", category: .senior),
        CatTip(id: 81, title: "Arthritis Signs", body: "Hesitating before jumping, using stairs slowly, not grooming hard-to-reach spots, or sleeping more. Pet stairs and heated beds help a lot.", category: .senior),
        CatTip(id: 82, title: "Cognitive Changes", body: "Older cats may meow more at night, seem confused, or forget litter box habits. Night lights and extra litter boxes help. Talk to your vet about supplements.", category: .senior),

        // Fun Facts
        CatTip(id: 90, title: "Cats Sleep 12-16 Hours", body: "That's 70% of their life spent sleeping. They're crepuscular — most active at dawn and dusk, just like their wild ancestors.", category: .fun),
        CatTip(id: 91, title: "Each Nose is Unique", body: "Like human fingerprints, every cat's nose print is unique. No two cats have the same nose pattern.", category: .fun),
        CatTip(id: 92, title: "Cats Can't Taste Sweet", body: "Cats lack the taste receptors for sweetness. They literally cannot taste sugar. Their taste buds are tuned for meat.", category: .fun),
        CatTip(id: 93, title: "Whisker Fatigue is Real", body: "Deep, narrow food bowls stress cats out because their whiskers touch the sides. Use wide, shallow dishes for food and water.", category: .fun),
        CatTip(id: 94, title: "Cats Have 230 Bones", body: "Humans have 206. The extra bones are mostly in their spine and tail, giving them incredible flexibility.", category: .fun),
        CatTip(id: 95, title: "Purring Heals Bones", body: "Cat purrs vibrate at 25-150 Hz — frequencies that promote bone healing and reduce inflammation. Your cat is literally a healing machine.", category: .fun),
    ]

    // MARK: - Behavior Decoder

    static let behaviorSigns: [BehaviorSign] = [
        BehaviorSign(behavior: "Slow blinking", meaning: "I love and trust you", icon: "eye", mood: "happy"),
        BehaviorSign(behavior: "Ears flat back", meaning: "Scared or angry — give space", icon: "exclamationmark.triangle", mood: "angry"),
        BehaviorSign(behavior: "Tail straight up", meaning: "Happy and confident greeting", icon: "arrow.up", mood: "happy"),
        BehaviorSign(behavior: "Tail puffed up", meaning: "Frightened or feeling threatened", icon: "bolt.fill", mood: "anxious"),
        BehaviorSign(behavior: "Kneading (biscuits)", meaning: "Content and comforted — nursing memory", icon: "hand.raised", mood: "relaxed"),
        BehaviorSign(behavior: "Chattering at birds", meaning: "Frustrated hunting instinct — excitement", icon: "bird", mood: "playful"),
        BehaviorSign(behavior: "Bringing you 'gifts'", meaning: "Sharing their hunt — they think you can't hunt", icon: "gift", mood: "happy"),
        BehaviorSign(behavior: "Rubbing against you", meaning: "Marking you as theirs with scent glands", icon: "person.fill", mood: "happy"),
        BehaviorSign(behavior: "Exposing belly", meaning: "Trust display — NOT asking for rubs", icon: "shield.fill", mood: "relaxed"),
        BehaviorSign(behavior: "Hissing", meaning: "Warning — scared and defensive, not aggressive", icon: "exclamationmark.circle", mood: "anxious"),
        BehaviorSign(behavior: "Hiding suddenly", meaning: "Pain, illness, or extreme stress — check on them", icon: "eye.slash", mood: "sick"),
        BehaviorSign(behavior: "Head bunting", meaning: "Marking you as family — highest affection", icon: "heart.fill", mood: "happy"),
        BehaviorSign(behavior: "Knocking things off tables", meaning: "Testing gravity / wanting attention", icon: "arrow.down", mood: "playful"),
        BehaviorSign(behavior: "Sitting in boxes", meaning: "Enclosed spaces feel safe — reduces stress", icon: "shippingbox", mood: "relaxed"),
        BehaviorSign(behavior: "Excessive grooming", meaning: "Stress, allergies, or pain — see vet if persistent", icon: "bandage", mood: "anxious"),
        BehaviorSign(behavior: "Chirping/trilling", meaning: "Happy greeting or calling you to follow", icon: "music.note", mood: "happy"),
    ]
}
