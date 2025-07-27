import Foundation
import Combine

// MARK: - AnalyticsEvent
struct OBKAnalyticsEvent {
    let name: String
    let properties: [String: Any]
    let timestamp: Date
    
    init(name: String, properties: [String: Any] = [:], timestamp: Date = Date()) {
        self.name = name
        self.properties = properties
        self.timestamp = timestamp
    }
}

// MARK: - LogLevel
enum LogLevel: String {
    case debug
    case info
    case warning
    case error
    case critical
}

// MARK: - AnalyticsManager
class AnalyticsManager: ObservableObject {
    static let shared = AnalyticsManager()
    
    @Published private(set) var events: [OBKAnalyticsEvent] = []
    @Published private(set) var logs: [(level: LogLevel, message: String, timestamp: Date)] = []
    
    private let networkManager: NetworkManager
    private var cancellables = Set<AnyCancellable>()
    
    private init(networkManager: NetworkManager? = nil) {
        self.networkManager = networkManager ?? NetworkManager.shared
    }
    
    // MARK: - Event Tracking
    
    func trackEvent(_ event: OBKAnalyticsEvent) {
        events.append(event)
        sendEvent(event)
    }
    
    func trackScreen(_ screenName: String, properties: [String: Any] = [:]) {
        let event = OBKAnalyticsEvent(
            name: "screen_view",
            properties: ["screen_name": screenName] + properties
        )
        trackEvent(event)
    }
    
    // MARK: - Logging
    
    func log(_ level: LogLevel, _ message: String) {
        let logEntry = (level: level, message: message, timestamp: Date())
        logs.append(logEntry)
        
        if level == .error || level == .critical {
            sendLog(level: level, message: message)
        }
    }
    
    // MARK: - Network Operations
    
    private func sendEvent(_ event: OBKAnalyticsEvent) {
        // In a real implementation, this would call analytics services
        #if DEBUG
        print("📊 Analytics event: \(event.name) - \(event.properties)")
        #else
        // Send to analytics service
        #endif
    }
    
    private func sendLog(level: LogLevel, message: String) {
        // In a real implementation, this would call logging services
        #if DEBUG
        print("📝 \(level.rawValue.uppercased()): \(message)")
        #else
        // Send to logging service
        #endif
    }
}

// MARK: - Dictionary Extension
private extension Dictionary where Key == String, Value == Any {
    static func + (lhs: [String: Any], rhs: [String: Any]) -> [String: Any] {
        var result = lhs
        for (key, value) in rhs {
            result[key] = value
        }
        return result
    }
} 