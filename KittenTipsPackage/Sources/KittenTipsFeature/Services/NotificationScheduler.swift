import Foundation
import UserNotifications

@MainActor
@Observable
final class NotificationScheduler {
    var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private static let dailyTipIdentifier = "kittentips.daily-tip"

    func refreshAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    @discardableResult
    func requestAuthorizationIfNeeded() async -> Bool {
        await refreshAuthorizationStatus()
        switch authorizationStatus {
        case .notDetermined:
            let granted = (try? await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])) ?? false
            await refreshAuthorizationStatus()
            return granted
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        @unknown default:
            return false
        }
    }

    /// Schedule a repeating daily notification at the given hour/minute.
    /// Body previews the upcoming tip so users have a reason to open the app.
    func scheduleDailyTip(title: String, body: String, hour: Int = 9, minute: Int = 0) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [Self.dailyTipIdentifier])

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: Self.dailyTipIdentifier,
            content: content,
            trigger: trigger
        )
        center.add(request) { _ in }
    }

    func cancelDailyTip() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [Self.dailyTipIdentifier])
    }
}
