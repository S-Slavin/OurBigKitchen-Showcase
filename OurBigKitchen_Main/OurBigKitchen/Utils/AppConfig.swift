import Foundation

enum AppConfig {
    
    // MARK: - Environment
    
    enum Environment {
        case development
        case staging
        case production
        
        var baseURL: String {
            switch self {
            case .development: return "https://dev.api.ourbigkitchen.com"
            case .staging: return "https://staging.api.ourbigkitchen.com"
            case .production: return "https://api.ourbigkitchen.com"
            }
        }
        
        var analyticsEnabled: Bool {
            switch self {
            case .development: return false
            case .staging, .production: return true
            }
        }
    }
    
    // MARK: - Current Configuration
    
    static let currentEnvironment: Environment = {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }()
    
    // MARK: - API Configuration
    
    static let apiVersion = "v1"
    static let apiTimeout: TimeInterval = 30
    static let maxRetryAttempts = 3
    
    // MARK: - Cache Configuration
    
    static let cacheExpiration: TimeInterval = 3600 // 1 hour
    static let maxCacheSize: Int = 50 * 1024 * 1024 // 50 MB
    
    // MARK: - Feature Flags
    
    static var features: [String: Bool] = [
        "socialSharing": true,
        "analytics": true,
        "offlineMode": true,
        "pushNotifications": true
    ]
    
    // MARK: - Constants
    
    enum Constants {
        static let appName = "Our Big Kitchen"
        static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        
        // UI Constants
        static let defaultCornerRadius: CGFloat = 8
        static let defaultPadding: CGFloat = 16
        static let defaultSpacing: CGFloat = 8
        static let maxImageSize: CGFloat = 1024
        
        // Validation Constants
        static let minPasswordLength = 8
        static let maxUsernameLength = 30
        static let maxBioLength = 500
        
        // Time Constants
        static let refreshInterval: TimeInterval = 300 // 5 minutes
        static let sessionTimeout: TimeInterval = 1800 // 30 minutes
        
        // Impact Constants
        static let mealsPerVolunteerHour: Double = 10
        static let wasteReductionPerMeal: Double = 0.4 // kg
        static let carbonFootprintPerMeal: Double = 1.5 // kg CO2
    }
    
    // MARK: - Helper Methods
    
    static func isFeatureEnabled(_ feature: String) -> Bool {
        return features[feature] ?? false
    }
    
    static func setFeature(_ feature: String, enabled: Bool) {
        features[feature] = enabled
    }
    
    static var apiBaseURL: String {
        return "\(currentEnvironment.baseURL)/\(apiVersion)"
    }
}