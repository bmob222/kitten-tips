// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "KittenTipsPackage",
    platforms: [.iOS(.v18)],
    products: [
        .library(name: "KittenTipsFeature", targets: ["KittenTipsFeature"]),
    ],
    dependencies: [
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", from: "12.0.0"),
    ],
    targets: [
        .target(
            name: "KittenTipsFeature",
            dependencies: [
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads"),
            ]
        ),
        .testTarget(name: "KittenTipsFeatureTests", dependencies: ["KittenTipsFeature"]),
    ]
)
