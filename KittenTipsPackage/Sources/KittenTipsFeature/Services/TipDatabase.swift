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

    /// Tips matching a free-text search across title, body, and category name.
    func searchTips(_ query: String) -> [CatTip] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        return Self.allTips.filter { tip in
            tip.title.localizedCaseInsensitiveContains(trimmed)
                || tip.body.localizedCaseInsensitiveContains(trimmed)
                || tip.category.rawValue.localizedCaseInsensitiveContains(trimmed)
        }
    }

    /// A random tip, avoiding the given tip so "Surprise Me" always shows something new.
    func randomTip(excluding excludedId: Int? = nil) -> CatTip {
        let candidates = Self.allTips.filter { $0.id != excludedId }
        return candidates.randomElement() ?? Self.allTips[0]
    }

    // MARK: - All Tips

    static let allTips: [CatTip] = [
        // New Kitten
        CatTip(id: 1, title: "Kitten-Proof Your Home", body: "Remove small objects, secure cords, close toilet lids, and block gaps behind appliances. Kittens explore EVERYTHING with their mouths.", category: .newKitten),
        CatTip(id: 2, title: "First Night Home", body: "Set up a small, quiet room with food, water, litter box, and a cozy bed. Don't overwhelm them with the whole house on day one. Let them come to you.", category: .newKitten),
        CatTip(id: 3, title: "The 3-3-3 Rule", body: "3 days to decompress, 3 weeks to learn your routine, 3 months to feel at home. Be patient — your kitten is adjusting to a whole new world.", category: .newKitten),
        CatTip(id: 4, title: "Litter Box Basics", body: "One litter box per cat, plus one extra. Place them in quiet, accessible spots. Scoop daily. Kittens prefer unscented, fine-grain litter.", category: .newKitten),
        CatTip(id: 5, title: "First Vet Visit", body: "Schedule a vet appointment within the first week. They'll check for parasites, start vaccinations, and give you a health baseline.", category: .newKitten),
        CatTip(id: 6, title: "Introducing Other Pets", body: "Keep pets separated at first and swap bedding so they learn each other's scent. Do short, supervised meetings over 1-2 weeks. Rushing introductions is the #1 cause of pet conflict.", category: .newKitten),
        CatTip(id: 7, title: "Name Recognition", body: "Say your kitten's name right before every meal and treat. Within weeks they'll come running when called. Keep the name short — one or two syllables works best.", category: .newKitten),
        CatTip(id: 8, title: "Nighttime Crying is Normal", body: "The first few nights, your kitten may cry for their littermates. A warm blanket, a ticking clock, or a heartbeat toy mimics the comfort of the litter. It usually passes in under a week.", category: .newKitten),

        // Feeding
        CatTip(id: 10, title: "Wet Food is King", body: "Cats are desert animals — they don't drink enough water on their own. Wet food keeps them hydrated and is closer to their natural diet.", category: .feeding),
        CatTip(id: 11, title: "Never Give Milk", body: "Most adult cats are lactose intolerant. Cow's milk causes diarrhea and stomach pain. If you want to treat them, use cat-specific milk.", category: .feeding),
        CatTip(id: 12, title: "Feeding Schedule", body: "Kittens under 6 months: 3-4 small meals/day. Adults: 2 meals/day. Free-feeding dry food leads to obesity — portion control matters.", category: .feeding),
        CatTip(id: 13, title: "Toxic Foods", body: "NEVER feed: onions, garlic, chocolate, grapes, raisins, xylitol, alcohol, raw dough, or caffeine. These are all toxic to cats.", category: .feeding),
        CatTip(id: 14, title: "Water Fountain Hack", body: "Cats prefer running water. A $20 pet fountain can triple their water intake. Place it away from their food — cats instinctively avoid water near food.", category: .feeding),
        CatTip(id: 15, title: "Read the Label", body: "Look for 'complete and balanced' on cat food. The first ingredient should be a named protein (chicken, salmon), not 'meat by-products.'", category: .feeding),
        CatTip(id: 16, title: "Switch Foods Slowly", body: "Changing food? Mix 25% new with 75% old, then shift the ratio over 7-10 days. Sudden switches cause vomiting and diarrhea — cat stomachs hate surprises.", category: .feeding),
        CatTip(id: 17, title: "Treats: The 10% Rule", body: "Treats should be under 10% of daily calories. A single cat treat can be the calorie equivalent of a cookie for you. Use tiny pieces — cats care about frequency, not size.", category: .feeding),

        // Health
        CatTip(id: 20, title: "Purring Isn't Always Happy", body: "Cats also purr when they're stressed, sick, or in pain. It's a self-soothing mechanism. If your cat purrs while hiding or not eating, see a vet.", category: .health),
        CatTip(id: 21, title: "The Hiding Red Flag", body: "A cat that suddenly starts hiding is telling you something is wrong. Pain, illness, or extreme stress. If hiding lasts more than 24 hours, call the vet.", category: .health),
        CatTip(id: 22, title: "Dental Disease is #1", body: "By age 3, most cats have dental disease. Symptoms: bad breath, drooling, dropping food, pawing at mouth. Annual dental checks save money long-term.", category: .health),
        CatTip(id: 23, title: "Weight Check", body: "You should feel your cat's ribs easily but not see them. If you can't feel ribs, your cat is overweight. Obesity leads to diabetes, arthritis, and shorter life.", category: .health),
        CatTip(id: 24, title: "Vaccination Schedule", body: "Core vaccines: FVRCP (distemper combo) at 6-8 weeks, boosters at 12 and 16 weeks. Rabies at 12-16 weeks. Annual or 3-year boosters after.", category: .health),
        CatTip(id: 25, title: "Spay/Neuter Benefits", body: "Prevents certain cancers, reduces spraying, stops yowling, prevents unwanted litters. Best done at 4-6 months. Recovery takes 10-14 days.", category: .health),
        CatTip(id: 26, title: "Litter Box = Health Monitor", body: "Straining, going outside the box, or frequent trips with little output can signal a urinary blockage — an emergency in male cats. Scooping daily means you notice changes fast.", category: .health),
        CatTip(id: 27, title: "Know Their Normal", body: "A healthy cat's resting breathing rate is under 30 breaths per minute. Count chest rises while they sleep. Knowing your cat's baseline helps you spot problems early.", category: .health),

        // Behavior
        CatTip(id: 30, title: "Slow Blink = I Love You", body: "When your cat slow-blinks at you, they're saying 'I trust you.' Slow-blink back — it's how cats say I love you.", category: .behavior),
        CatTip(id: 31, title: "Zoomies Are Normal", body: "Random bursts of running at 3 AM? That's pent-up energy from their crepuscular nature (most active at dawn/dusk). More playtime before bed helps.", category: .behavior),
        CatTip(id: 32, title: "Kneading (Making Biscuits)", body: "When cats knead with their paws, it's a comforting behavior from nursing as kittens. It means they feel safe and content with you.", category: .behavior),
        CatTip(id: 33, title: "Belly Trap", body: "A cat showing their belly is showing trust — NOT asking for belly rubs. Most cats will grab and bite if you touch their belly. It's a trust display, not an invitation.", category: .behavior),
        CatTip(id: 34, title: "Tail Language", body: "Up = confident/happy. Puffed = scared/angry. Low = insecure. Twitching tip = focused/hunting. Wrapped around you = affection.", category: .behavior),
        CatTip(id: 35, title: "Scratching Isn't Bad", body: "Cats NEED to scratch — it removes dead nail sheaths and marks territory. Provide scratching posts near where they sleep. They stretch and scratch after naps.", category: .behavior),
        CatTip(id: 36, title: "Meowing is for You", body: "Adult cats rarely meow at each other — meowing is a language they developed for humans. Each cat builds a custom vocabulary with their person. Listen for patterns.", category: .behavior),
        CatTip(id: 37, title: "The Elevator Butt", body: "When your cat raises their rear as you pet near the tail base, that's a compliment — it's how kittens greet their mother. It means the petting is exactly right.", category: .behavior),

        // Grooming
        CatTip(id: 40, title: "Brushing Prevents Hairballs", body: "Brush your cat 2-3 times per week. Long-haired cats need daily brushing. It reduces hairballs, shedding, and mats. Most cats learn to love it.", category: .grooming),
        CatTip(id: 41, title: "Don't Over-Bathe", body: "Cats are self-cleaning. Only bathe if they get into something dirty/sticky, have a skin condition, or can't groom themselves. Too many baths dry out their skin.", category: .grooming),
        CatTip(id: 42, title: "Nail Trimming Tips", body: "Trim every 2-3 weeks. Only cut the clear tip — avoid the pink quick. Start young so they get used to it. One paw per session is fine if they're squirmy.", category: .grooming),
        CatTip(id: 43, title: "Ear Check Weekly", body: "Peek inside their ears weekly. Healthy = pink and clean. Dark discharge, redness, or odor means ear mites or infection. See your vet.", category: .grooming),
        CatTip(id: 44, title: "Mat Emergency Kit", body: "Never cut a mat out with scissors — cat skin is paper-thin and tents up into mats. Use a mat splitter or dematting comb, or let a groomer handle it. Work on mats when your cat is sleepy.", category: .grooming),
        CatTip(id: 45, title: "Shedding Seasons", body: "Cats blow their coats in spring and fall. Expect 2-3 weeks of heavy shedding — brush daily during these windows and you'll cut the floor fur (and hairballs) dramatically.", category: .grooming),

        // Training
        CatTip(id: 50, title: "Cats CAN Be Trained", body: "Use treats and clicker training. Cats learn sit, high-five, come, and even fetch. Keep sessions under 5 minutes — they have short attention spans.", category: .training),
        CatTip(id: 51, title: "Never Punish", body: "Cats don't understand punishment. Spraying water or yelling creates fear, not learning. Redirect unwanted behavior to an acceptable alternative instead.", category: .training),
        CatTip(id: 52, title: "Carrier Training", body: "Leave the carrier out with treats inside. Make it a cozy hangout spot. When vet day comes, your cat won't panic. This single tip saves so much stress.", category: .training),
        CatTip(id: 53, title: "Reward the Quiet", body: "If your cat yowls for food, wait for a moment of silence before putting the bowl down. Feed during the noise and you've trained the yowling. Cats learn what pays off — fast.", category: .training),
        CatTip(id: 54, title: "Teach 'Come' First", body: "'Come' can save your cat's life if they slip outside. Shake a treat bag, say the cue, reward when they arrive. Practice daily and it becomes automatic — even outdoors under stress.", category: .training),
        CatTip(id: 55, title: "Counter-Surfing Fix", body: "Cats jump on counters because it's rewarding — food crumbs and a great view. Remove the payoff, then give a better option: a tall cat tree by the kitchen with treats on top.", category: .training),

        // Safety
        CatTip(id: 60, title: "Toxic Plants", body: "Lilies are DEADLY to cats — even the pollen. Also toxic: poinsettias, tulips, azaleas, sago palms, and pothos. Check every plant before bringing it home.", category: .safety),
        CatTip(id: 61, title: "Window Safety", body: "Cats can push through screens. 'High-rise syndrome' is real — cats fall from windows every day. Use secure screens or keep windows closed above ground floor.", category: .safety),
        CatTip(id: 62, title: "String is Dangerous", body: "Hair ties, yarn, ribbon, tinsel, and string can cause fatal intestinal blockages if swallowed. Never leave string toys unattended.", category: .safety),
        CatTip(id: 63, title: "Essential Oils Kill", body: "Many essential oils are toxic to cats: tea tree, eucalyptus, lavender, peppermint, citrus. Diffusers can cause respiratory distress. Keep them away from cats.", category: .safety),
        CatTip(id: 64, title: "Check the Dryer", body: "Cats love warm, dark spaces — always check the washer and dryer before starting them. Make it a habit: knock on the machine, then look inside. Every time.", category: .safety),
        CatTip(id: 65, title: "Microchip + Collar", body: "Even indoor cats escape. A microchip is permanent ID that shelters scan first. Pair it with a breakaway collar and tag — and keep the chip registration info current when you move.", category: .safety),

        // Bonding
        CatTip(id: 70, title: "Let Them Come to You", body: "The fastest way to bond with a cat is to NOT chase them. Sit quietly, offer a finger to sniff, and let them approach on their terms.", category: .bonding),
        CatTip(id: 71, title: "Play = Love", body: "15 minutes of interactive play twice a day strengthens your bond more than anything. Wand toys mimic prey — cats need this hunting outlet.", category: .bonding),
        CatTip(id: 72, title: "The Head Bonk", body: "When your cat headbutts you, they're marking you with their scent glands. It means 'you're mine.' It's one of the highest compliments a cat gives.", category: .bonding),
        CatTip(id: 73, title: "Respect Their Space", body: "Cats need alone time. Provide hiding spots, cat trees, and high perches. A cat that can retreat when overwhelmed will trust you more.", category: .bonding),
        CatTip(id: 74, title: "Talk to Your Cat", body: "Cats recognize their person's voice and respond to soft, higher-pitched tones. Narrate your day, use their name often — cats bond more with people who talk to them.", category: .bonding),
        CatTip(id: 75, title: "The Sniff Greeting", body: "Offer a relaxed finger at nose height when greeting any cat — it mimics the nose-touch cats use with each other. Let them sniff first; petting comes after the invitation.", category: .bonding),

        // Senior
        CatTip(id: 80, title: "Senior Cat Diet", body: "After age 7, switch to senior formula with higher protein and joint support. Senior cats need more frequent, smaller meals and extra hydration.", category: .senior),
        CatTip(id: 81, title: "Arthritis Signs", body: "Hesitating before jumping, using stairs slowly, not grooming hard-to-reach spots, or sleeping more. Pet stairs and heated beds help a lot.", category: .senior),
        CatTip(id: 82, title: "Cognitive Changes", body: "Older cats may meow more at night, seem confused, or forget litter box habits. Night lights and extra litter boxes help. Talk to your vet about supplements.", category: .senior),
        CatTip(id: 83, title: "Low-Entry Litter Boxes", body: "Arthritic cats struggle to climb into high-sided boxes. Switch to a low-entry box (or cut a low doorway into one) and accidents often stop overnight.", category: .senior),
        CatTip(id: 84, title: "Weight Loss is a Red Flag", body: "Seniors losing weight while eating normally may have hyperthyroidism, kidney disease, or diabetes — all very manageable when caught early. Weigh monthly; mention any drop to your vet.", category: .senior),

        // Fun Facts
        CatTip(id: 90, title: "Cats Sleep 12-16 Hours", body: "That's 70% of their life spent sleeping. They're crepuscular — most active at dawn and dusk, just like their wild ancestors.", category: .fun),
        CatTip(id: 91, title: "Each Nose is Unique", body: "Like human fingerprints, every cat's nose print is unique. No two cats have the same nose pattern.", category: .fun),
        CatTip(id: 92, title: "Cats Can't Taste Sweet", body: "Cats lack the taste receptors for sweetness. They literally cannot taste sugar. Their taste buds are tuned for meat.", category: .fun),
        CatTip(id: 93, title: "Whisker Fatigue is Real", body: "Deep, narrow food bowls stress cats out because their whiskers touch the sides. Use wide, shallow dishes for food and water.", category: .fun),
        CatTip(id: 94, title: "Cats Have 230 Bones", body: "Humans have 206. The extra bones are mostly in their spine and tail, giving them incredible flexibility.", category: .fun),
        CatTip(id: 95, title: "Purring Heals Bones", body: "Cat purrs vibrate at 25-150 Hz — frequencies that promote bone healing and reduce inflammation. Your cat is literally a healing machine.", category: .fun),
        CatTip(id: 96, title: "Righting Reflex", body: "Kittens develop their famous mid-air twist by 6-7 weeks old. Cats use their flexible spine and tail to land feet-first — but falls still injure cats, so keep windows secure.", category: .fun),
        CatTip(id: 97, title: "Sandpaper Tongue", body: "A cat's tongue is covered in hundreds of tiny backward-facing hooks called papillae. They work like a built-in comb — and it's why licked fur looks instantly tidier.", category: .fun),
        CatTip(id: 98, title: "Cats Can Jump 6x Their Height", body: "An average cat can leap about six times their body length from a standstill. Powerful hind legs act like coiled springs — that's how they reach the top of the fridge in one hop.", category: .fun),
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
