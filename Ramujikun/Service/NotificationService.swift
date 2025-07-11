import Foundation
import UserNotifications
import SwiftUI

protocol NotificationServiceProtocol {
    func requestPermission() async -> Bool
    func scheduleDailyReminder() async throws
    func cancelAllReminders()
    func isReminderEnabled() async -> Bool
}

final class NotificationService: NotificationServiceProtocol {
    static let shared = NotificationService()
    
    private let userDefaults = UserDefaults.standard
    private let reminderEnabledKey = "ReminderEnabled"
    
    private init() {}
    
    func requestPermission() async -> Bool {
        #if targetEnvironment(simulator)
        // シミュレーターでは常にtrueを返す（テスト用）
        return true
        #else
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        
        switch settings.authorizationStatus {
        case .authorized, .provisional:
            return true
        case .denied, .notDetermined:
            let granted = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted ?? false
        case .ephemeral:
            return true
        @unknown default:
            return false
        }
        #endif
    }
    
    func scheduleDailyReminder() async throws {
        #if targetEnvironment(simulator)
        // シミュレーターでは設定のみ保存
        userDefaults.set(true, forKey: reminderEnabledKey)
        return
        #else
        let center = UNUserNotificationCenter.current()
        
        // 既存の通知を削除
        center.removeAllPendingNotificationRequests()
        
        // 新しい通知をスケジュール
        let content = UNMutableNotificationContent()
        content.title = "気分記録の時間です"
        content.body = "今日の気分を記録して、自分の感情パターンを把握しましょう"
        content.sound = .default
        content.badge = 1
        
        // 21:00に設定
        var timeComponents = DateComponents()
        timeComponents.hour = 21
        timeComponents.minute = 0
        
        // 毎日繰り返すトリガーを作成
        let trigger = UNCalendarNotificationTrigger(dateMatching: timeComponents, repeats: true)
        
        // 通知リクエストを作成
        let request = UNNotificationRequest(
            identifier: "DailyMoodReminder",
            content: content,
            trigger: trigger
        )
        
        // 通知をスケジュール
        try await center.add(request)
        
        // 設定を保存
        userDefaults.set(true, forKey: reminderEnabledKey)
        #endif
    }
    
    func cancelAllReminders() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        // 設定を無効化
        userDefaults.set(false, forKey: reminderEnabledKey)
    }
    
    func isReminderEnabled() async -> Bool {
        // シミュレーターでは常にfalseを返す（通知が制限されるため）
        #if targetEnvironment(simulator)
        return false
        #else
        return userDefaults.bool(forKey: reminderEnabledKey)
        #endif
    }
}

