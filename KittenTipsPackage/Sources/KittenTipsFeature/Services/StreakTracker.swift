import Foundation

@MainActor
@Observable
final class StreakTracker {
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    private(set) var lastOpenDate: Date?
    private(set) var celebratedMilestones: Set<Int> = []
    var pendingCelebration: Int?

    static let milestones: [Int] = [1, 3, 7, 14, 30, 60, 100]

    private struct PersistedState: Codable {
        var currentStreak: Int
        var longestStreak: Int
        var lastOpenDate: Date?
        var celebratedMilestones: [Int]?
    }

    private static let persistenceKey = "kittentips_streak_state"
    private let calendar: Calendar = .current

    init() {
        if
            let data = UserDefaults.standard.data(forKey: Self.persistenceKey),
            let state = try? JSONDecoder().decode(PersistedState.self, from: data)
        {
            currentStreak = state.currentStreak
            longestStreak = state.longestStreak
            lastOpenDate = state.lastOpenDate
            celebratedMilestones = Set(state.celebratedMilestones ?? [])
        }
    }

    /// Call once per app launch. Bumps streak on a new calendar day,
    /// keeps it on same-day reopens, resets on gaps > 1 day.
    /// Sets `pendingCelebration` when a new milestone is reached.
    func registerOpen(now: Date = Date()) {
        defer { save() }

        guard let last = lastOpenDate else {
            currentStreak = 1
            longestStreak = max(longestStreak, 1)
            lastOpenDate = now
            checkMilestone()
            return
        }

        if calendar.isDate(last, inSameDayAs: now) {
            return
        }

        let startOfLast = calendar.startOfDay(for: last)
        let startOfNow = calendar.startOfDay(for: now)
        let dayDelta = calendar.dateComponents([.day], from: startOfLast, to: startOfNow).day ?? 0

        if dayDelta == 1 {
            currentStreak += 1
        } else {
            currentStreak = 1
        }
        longestStreak = max(longestStreak, currentStreak)
        lastOpenDate = now
        checkMilestone()
    }

    func acknowledgeCelebration() {
        if let milestone = pendingCelebration {
            celebratedMilestones.insert(milestone)
            pendingCelebration = nil
            save()
        }
    }

    private func checkMilestone() {
        guard
            Self.milestones.contains(currentStreak),
            !celebratedMilestones.contains(currentStreak)
        else { return }
        pendingCelebration = currentStreak
    }

    private func save() {
        let state = PersistedState(
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            lastOpenDate: lastOpenDate,
            celebratedMilestones: Array(celebratedMilestones)
        )
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: Self.persistenceKey)
        }
    }
}
