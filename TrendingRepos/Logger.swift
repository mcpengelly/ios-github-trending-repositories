import Foundation

// Log Level specificity:
// Debug: debug, info, warning, error
// Prod: info, warning, error

enum LogLevel: Int {
    case debug = 1
    case info = 2
    case warning = 3
    case error = 4
}

class Logger {
    static let shared = Logger()
    
    var logLevel: LogLevel = .info

    private init() {}

    func log(level: LogLevel, message: String) {
        #if !DEBUG
            guard level.rawValue >= logLevel.rawValue else { return }
        #endif
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timestamp = dateFormatter.string(from: Date())
        print("\(timestamp) [\(level)]: \(message)")
    }

    func debug(_ message: String) {
        log(level: .debug, message: message)
    }

    func info(_ message: String) {
        log(level: .info, message: message)
    }

    func warning(_ message: String) {
        log(level: .warning, message: message)
    }

    func error(_ message: String) {
        log(level: .error, message: message)
    }
}
