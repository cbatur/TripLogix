import Foundation

enum LogLevel: String {
    case debug = "🐛 DEBUG"
    case info = "ℹ️ INFO"
    case warning = "⚠️ WARNING"
    case error = "🚨 ERROR"
    case network = "📡 NETWORK"
}

struct Logger {
    
    /// Logs a message with a specified log level.
    /// - Parameters:
    ///   - level: The log level (e.g., `.debug`, `.error`).
    ///   - message: The message to log.
    ///   - file: The file where the log originated.
    ///   - function: The function where the log originated.
    ///   - line: The line number where the log originated.
    static func log(
        level: LogLevel,
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        #if DEBUG  // ✅ Only logs in debug mode
        let fileName = (file as NSString).lastPathComponent
        let timestamp = ISO8601DateFormatter().string(from: Date())
        
        print("\(level.rawValue) [\(timestamp)] \(fileName):\(line) - \(function) → \(message)")
        #endif
    }
    
    /// Specialized function to log network requests
    static func networkRequest(url: URL?, method: String, responseCode: Int?, error: Error?) {
        let status = responseCode != nil ? "HTTP \(responseCode!)" : "❌ ERROR"
        let errorMessage = error?.localizedDescription ?? "No error"
        log(level: .network, "[\(method)] \(url?.absoluteString ?? "Unknown URL") → \(status), Error: \(errorMessage)")
    }
}
