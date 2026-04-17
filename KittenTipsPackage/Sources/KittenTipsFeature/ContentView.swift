import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency

public struct ContentView: View {
    @State private var selectedTab: AppTab = .daily
    @State private var tipDB = TipDatabase()
    @State private var kittenPet = KittenPet()
    @State private var adManager = InterstitialAdManager()
    @State private var streakTracker = StreakTracker()
    @State private var notifications = NotificationScheduler()
    @State private var breedLibrary = BreedLibrary()
    @State private var isRunningScreenshotTour = false

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedTab) {
                Tab("Daily Tip", systemImage: "sparkles", value: .daily) {
                    DailyTipView()
                        .withKittenPet()
                }
                Tab("Tips", systemImage: "list.bullet", value: .tips) {
                    TipCategoriesView()
                }
                Tab("Ages", systemImage: "pawprint.fill", value: .ages) {
                    KittenAgeGuideView()
                }
                Tab("Decoder", systemImage: "brain.head.profile.fill", value: .decoder) {
                    BehaviorDecoderView()
                }
                Tab("Saved", systemImage: "heart.fill", value: .saved) {
                    SavedTipsView()
                }
            }
            .tint(.pink)

            if !ScreenshotHelper.isScreenshotMode {
                // Keep the promo capture clean.
                BannerAdView()
                    .frame(height: 50)
            }
        }
        .environment(tipDB)
        .environment(kittenPet)
        .environment(adManager)
        .environment(streakTracker)
        .environment(notifications)
        .environment(breedLibrary)
        .overlay {
            if let milestone = streakTracker.pendingCelebration,
               !ScreenshotHelper.isScreenshotMode {
                CelebrationView(milestone: milestone) {
                    streakTracker.acknowledgeCelebration()
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: streakTracker.pendingCelebration)
        .task {
            if !ScreenshotHelper.isScreenshotMode {
                try? await Task.sleep(for: .seconds(0.5))
                _ = await ATTrackingManager.requestTrackingAuthorization()
            }
            MobileAds.shared.start { _ in }
            if !ScreenshotHelper.isScreenshotMode {
                adManager.loadAd()
            }
        }
        .task {
            guard !ScreenshotHelper.isScreenshotMode else { return }
            streakTracker.registerOpen()

            // Ask for notifications after ATT so we don't stack system prompts.
            try? await Task.sleep(for: .seconds(1.5))
            let granted = await notifications.requestAuthorizationIfNeeded()
            guard granted else { return }

            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
            let tip = tipDB.tip(for: tomorrow)
            notifications.scheduleDailyTip(
                title: "Whiskers has a tip for you 🐾",
                body: "\(tip.title) — tap to read today's tip."
            )
        }
        .task {
            guard ScreenshotHelper.isScreenshotMode, !isRunningScreenshotTour else { return }
            isRunningScreenshotTour = true
            await runScreenshotTour()
        }
    }

    enum AppTab: Hashable {
        case daily, tips, ages, decoder, saved
    }

    private func runScreenshotTour() async {
        let orderedTabs: [AppTab] = [.daily, .tips, .ages, .decoder, .saved]

        // Give launch animations a moment to settle before recording the tour.
        try? await Task.sleep(for: .seconds(1.2))

        while !Task.isCancelled {
            for tab in orderedTabs {
                withAnimation(.easeInOut(duration: 0.45)) {
                    selectedTab = tab
                }

                let dwellTime: Double = switch tab {
                case .daily: 3.0
                case .tips: 2.4
                case .ages: 2.4
                case .decoder: 2.6
                case .saved: 2.0
                }

                try? await Task.sleep(for: .seconds(dwellTime))
            }
        }
    }
}
