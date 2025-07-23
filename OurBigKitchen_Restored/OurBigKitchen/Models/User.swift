import Foundation
import SwiftUI

// Type aliases for User model and related types
typealias User = AppModels.User
typealias UserRole = AppModels.UserRole
typealias UserPreferences = AppModels.UserPreferences
typealias UserStats = AppModels.UserStats
typealias UserAchievement = AppModels.UserAchievement

extension User {
    var isOver18: Bool {
        guard let dob = dob else { return false }
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: dob, to: now)
        return (ageComponents.year ?? 0) >= 18
    }
    
    var wwccStatus: WWCCStatus {
        guard isOver18 else { return .notRequired }
        guard let expiry = wwcExpiry else { return .missing }
        if expiry <= Date() {
            return .expired
        }
        return .valid
    }
    
    enum WWCCStatus {
        case valid
        case expired
        case missing
        case notRequired
        
        var description: String {
            switch self {
            case .valid:
                return "Valid"
            case .expired:
                return "Expired"
            case .missing:
                return "Required"
            case .notRequired:
                return "Not Required"
            }
        }
        
        var color: Color {
            switch self {
            case .valid:
                return .green
            case .expired:
                return .red
            case .missing:
                return .orange
            case .notRequired:
                return .gray
            }
        }
    }
}