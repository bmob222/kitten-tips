import SwiftUI

/// Launch argument driven screenshot mode for App Store screenshots.
/// Pass --screenshots to cycle through all tabs automatically.
@MainActor
struct ScreenshotHelper {
    static var isScreenshotMode: Bool {
        ProcessInfo.processInfo.arguments.contains("--screenshots")
    }
}
