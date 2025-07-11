import Foundation

enum AppError: LocalizedError {
    case networkError
    case authenticationError(String)
    case dataError(String)
    case validationError(String)
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "ネットワークエラーが発生しました。インターネット接続を確認してください。"
        case .authenticationError(let message):
            return "認証エラー: \(message)"
        case .dataError(let message):
            return "データエラー: \(message)"
        case .validationError(let message):
            return "入力エラー: \(message)"
        case .unknownError:
            return "予期しないエラーが発生しました。"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .networkError:
            return "しばらく時間をおいてから再度お試しください。"
        case .authenticationError:
            return "ログイン情報を確認してください。"
        case .dataError:
            return "アプリを再起動してください。"
        case .validationError:
            return "入力内容を確認してください。"
        case .unknownError:
            return "アプリを再起動するか、しばらく時間をおいてから再度お試しください。"
        }
    }
}

