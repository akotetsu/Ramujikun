import Foundation
import os.log

enum LogCategory: String {
    case auth = "Authentication"
    case mood = "Mood"
    case network = "Network"
    case ui = "UI"
    case error = "Error"
}

struct Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.ramujikun.app"
    
    static func log(_ message: String, category: LogCategory, type: OSLogType = .default) {
        let logger = OSLog(subsystem: subsystem, category: category.rawValue)
        os_log("%{public}@", log: logger, type: type, message)
        
        #if DEBUG
        print("[\(category.rawValue)] \(message)")
        #endif
    }
    
    static func error(_ message: String, category: LogCategory, error: Error? = nil) {
        var logMessage = message
        if let error = error {
            logMessage += " - Error: \(error.localizedDescription)"
        }
        log(logMessage, category: category, type: .error)
    }
    
    static func debug(_ message: String, category: LogCategory) {
        #if DEBUG
        log(message, category: category, type: .debug)
        #endif
    }
} 