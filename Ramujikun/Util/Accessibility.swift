import SwiftUI

struct AccessibilityHelper {
    
    // MARK: - Mood Level Accessibility
    static func moodLevelAccessibilityLabel(_ level: Mood.MoodLevel) -> String {
        switch level {
        case .awful: return "どんより - とても悪い気分"
        case .bad: return "しょぼん - 悪い気分"
        case .meh: return "ふつう - 普通の気分"
        case .good: return "ごきげん - 良い気分"
        case .great: return "るんるん - とても良い気分"
        }
    }
    
    static func moodLevelAccessibilityHint(_ level: Mood.MoodLevel) -> String {
        return "ダブルタップして気分を選択"
    }
    
    // MARK: - Date Accessibility
    static func dateAccessibilityLabel(_ date: Date, mood: Mood?) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        formatter.locale = Locale(identifier: "ja_JP")
        let dateString = formatter.string(from: date)
        
        if let mood = mood {
            return "\(dateString) - \(mood.level.rawValue)の気分を記録済み"
        } else {
            return "\(dateString) - 記録なし"
        }
    }
    
    static func dateAccessibilityHint(_ date: Date, mood: Mood?) -> String {
        if mood != nil {
            return "ダブルタップして気分を編集"
        } else {
            return "ダブルタップして気分を記録"
        }
    }
    
    // MARK: - Button Accessibility
    static func buttonAccessibilityLabel(_ title: String, icon: String) -> String {
        return "\(title) - \(icon)"
    }
    
    // MARK: - Chart Accessibility
    static func chartAccessibilityLabel(_ title: String, value: String) -> String {
        return "\(title): \(value)"
    }
}

// MARK: - View Extensions for Accessibility
extension View {
    func moodAccessibility(for level: Mood.MoodLevel) -> some View {
        self
            .accessibilityLabel(AccessibilityHelper.moodLevelAccessibilityLabel(level))
            .accessibilityHint(AccessibilityHelper.moodLevelAccessibilityHint(level))
            .accessibilityAddTraits(.isButton)
    }
    
    func dateAccessibility(for date: Date, mood: Mood?) -> some View {
        self
            .accessibilityLabel(AccessibilityHelper.dateAccessibilityLabel(date, mood: mood))
            .accessibilityHint(AccessibilityHelper.dateAccessibilityHint(date, mood: mood))
            .accessibilityAddTraits(.isButton)
    }
    
    func buttonAccessibility(title: String, icon: String) -> some View {
        self
            .accessibilityLabel(AccessibilityHelper.buttonAccessibilityLabel(title, icon: icon))
            .accessibilityAddTraits(.isButton)
    }
}

