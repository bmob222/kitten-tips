import SwiftUI
import GoogleMobileAds
import UIKit

enum AdConfig {
    static let appID = "ca-app-pub-3521886190536845~5300544311"
    static let bannerAdUnitID = "ca-app-pub-3521886190536845/2796737698"
    static let interstitialAdUnitID = "ca-app-pub-3521886190536845/2194102469"
}

// MARK: - Banner Ad View

struct BannerAdView: UIViewRepresentable {
    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = AdConfig.bannerAdUnitID
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            banner.rootViewController = rootVC
        }
        banner.load(Request())
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}
}

// MARK: - Interstitial Ad Manager

@MainActor
@Observable
final class InterstitialAdManager: NSObject {
    private var interstitialAd: InterstitialAd?
    private var tapCount = 0
    private let showEvery = 4 // Show interstitial every 4 category taps

    func loadAd() {
        InterstitialAd.load(
            with: AdConfig.interstitialAdUnitID,
            request: Request()
        ) { [weak self] ad, error in
            if let error {
                print("Interstitial load failed: \(error.localizedDescription)")
                return
            }
            self?.interstitialAd = ad
        }
    }

    func trackTap() {
        tapCount += 1
        if tapCount >= showEvery {
            showAd()
            tapCount = 0
        }
    }

    private func showAd() {
        guard let ad = interstitialAd else {
            loadAd() // Reload for next time
            return
        }
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            ad.present(from: rootVC)
        }
        // Reload next ad
        loadAd()
    }
}
