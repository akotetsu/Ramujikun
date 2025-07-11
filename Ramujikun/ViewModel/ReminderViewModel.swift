import Foundation
import SwiftUI

@MainActor
final class ReminderViewModel: ObservableObject {
    static let shared = ReminderViewModel()
    
    @Published var isReminderEnabled = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let notificationService: NotificationServiceProtocol
    
    init(notificationService: NotificationServiceProtocol = NotificationService.shared) {
        self.notificationService = notificationService
        // 初期化時に同期的に設定を読み込む
        loadReminderSettingsSync()
    }
    
    func requestNotificationPermission() async {
        isLoading = true
        errorMessage = nil
        
        let granted = await notificationService.requestPermission()
        
        if !granted {
            errorMessage = "通知の許可が必要です。設定アプリで通知を有効にしてください。"
        }
        
        isLoading = false
    }
    
    func toggleReminder() async {
        isLoading = true
        errorMessage = nil
        
        if isReminderEnabled {
            // リマインダーを無効化
            notificationService.cancelAllReminders()
            isReminderEnabled = false
        } else {
            // リマインダーを有効化
            let granted = await notificationService.requestPermission()
            if !granted {
                errorMessage = "通知の許可が必要です。設定アプリで通知を有効にしてください。"
                isLoading = false
                return
            }
            
            do {
                try await notificationService.scheduleDailyReminder()
                isReminderEnabled = true
            } catch {
                #if targetEnvironment(simulator)
                // シミュレーターではエラーを無視して有効化
                isReminderEnabled = true
                #else
                errorMessage = "リマインダーの設定に失敗しました: \(error.localizedDescription)"
                #endif
            }
        }
        
        isLoading = false
    }
    
    // 同期的に設定を読み込む
    private func loadReminderSettingsSync() {
        // UserDefaultsから直接読み込み
        let userDefaults = UserDefaults.standard
        let reminderEnabledKey = "ReminderEnabled"
        isReminderEnabled = userDefaults.bool(forKey: reminderEnabledKey)
    }
    
    // 非同期で設定を再読み込み（必要に応じて使用）
    func refreshSettings() async {
        isReminderEnabled = await notificationService.isReminderEnabled()
    }
}
