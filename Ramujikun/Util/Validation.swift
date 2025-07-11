import Foundation

struct Validation {
    
    // MARK: - Email Validation
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    static func emailValidationMessage(_ email: String) -> String? {
        if email.isEmpty { return nil }
        if !isValidEmail(email) { return "有効なメールアドレスを入力してください" }
        return nil
    }
    
    // MARK: - Password Validation
    static func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6
    }
    
    static func passwordValidationMessage(_ password: String) -> String? {
        if password.isEmpty { return nil }
        if password.count < 6 { return "パスワードは6文字以上で入力してください" }
        return nil
    }
    
    // MARK: - Comment Validation
    static func isValidComment(_ comment: String) -> Bool {
        return comment.count <= 500
    }
    
    static func commentValidationMessage(_ comment: String) -> String? {
        if comment.count > 500 { return "コメントは500文字以内で入力してください" }
        return nil
    }
    
    // MARK: - Date Validation
    static func isValidMoodDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today) ?? today
        
        return calendar.isDate(date, inSameDayAs: today) ||
               calendar.isDate(date, inSameDayAs: yesterday)
    }
    
    static func dateValidationMessage(_ date: Date) -> String? {
        if !isValidMoodDate(date) { return "今日または昨日の日付のみ記録できます" }
        return nil
    }
}

