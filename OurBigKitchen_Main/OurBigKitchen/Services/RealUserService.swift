import Foundation
import Combine
import SwiftUI

@MainActor
class RealUserService: ObservableObject {
    static let shared = RealUserService()
    
    @Published var currentUser: AppModels.User?
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private let coreDataManager = CoreDataManager.shared
    
    private init() {}
    
    // MARK: - User Management
    
    func updateUserProfile(
        firstName: String,
        lastName: String,
        bio: String?,
        companyName: String?,
        companyPosition: String?,
        companyEmail: String?
    ) {
        guard let user = currentUser else {
            errorMessage = "No user logged in"
            return
        }
        
        // Update the current user object
        var updatedUser = user
        updatedUser.firstName = firstName
        updatedUser.lastName = lastName
        updatedUser.bio = bio
        updatedUser.companyName = companyName
        updatedUser.companyPosition = companyPosition
        updatedUser.companyEmail = companyEmail
        
        // Update in Core Data
        coreDataManager.updateUserProfile(updatedUser)
        
        // Update current user
        currentUser = updatedUser
    }
    
    func updateWWCC(
        wwcNumber: String,
        wwcExpiryDate: Date
    ) {
        guard let user = currentUser else {
            errorMessage = "No user logged in"
            return
        }
        
        // Update the current user object
        var updatedUser = user
        updatedUser.wwcNumber = wwcNumber
        updatedUser.wwcExpiry = wwcExpiryDate
        
        // Update in Core Data
        coreDataManager.updateWWCC(
            userId: user.id,
            wwccNumber: wwcNumber,
            wwccExpiry: wwcExpiryDate
        )
        
        // Update current user
        currentUser = updatedUser
    }
    
    func updateFoodSafetyRegistration(hasRegistration: Bool) {
        guard let user = currentUser else {
            errorMessage = "No user logged in"
            return
        }
        
        // Update the current user object
        var updatedUser = user
        updatedUser.hasFoodSafetyRegistration = hasRegistration
        
        // Update in Core Data
        coreDataManager.updateFoodSafetyRegistration(
            userId: user.id,
            hasRegistration: hasRegistration
        )
        
        // Update current user
        currentUser = updatedUser
    }
    
    func updateProfileImage(imageURL: String) {
        guard let user = currentUser else {
            errorMessage = "No user logged in"
            return
        }
        
        // Update the current user object
        var updatedUser = user
        updatedUser.profileImageURL = imageURL
        
        // Update in Core Data
        coreDataManager.updateProfileImage(
            userId: user.id,
            imageURL: imageURL
        )
        
        // Update current user
        currentUser = updatedUser
    }
    
    func updateUserPreferences(
        notificationsEnabled: Bool,
        darkMode: Bool,
        language: String
    ) {
        guard let user = currentUser else {
            errorMessage = "No user logged in"
            return
        }
        
        // Update the current user object
        var updatedUser = user
        updatedUser.preferences.notificationsEnabled = notificationsEnabled
        updatedUser.preferences.darkMode = darkMode
        updatedUser.preferences.language = language
        
        // Update in Core Data
        let preferences: [String: Any] = [
            "notificationsEnabled": notificationsEnabled,
            "darkMode": darkMode,
            "language": language
        ]
        coreDataManager.updateUserPreferences(
            userId: user.id,
            preferences: preferences
        )
        
        // Update current user
        currentUser = updatedUser
    }
    
    func getUserImpact() -> (meals: Int, people: Int, hours: Double) {
        guard let user = currentUser else { return (0, 0, 0.0) }
        
        let stats = coreDataManager.getUserStats(for: user.id)
        return (
            meals: Int(stats.mealsPrepared),
            people: Int(stats.eventsAttended),
            hours: Double(stats.hoursVolunteered)
        )
    }
    
    func getTotalImpact() -> (meals: Int, people: Int) {
        let userMetrics = coreDataManager.getAllUserMetrics()
        // For now, return default values since getAllUserMetrics returns [String: Any]
        // This will be properly implemented when Core Data is fully set up
        return (0, 0)
    }
    
    func getUserVolunteerHours() -> Double {
        guard let user = currentUser else { return 0.0 }
        let stats = coreDataManager.getUserStats(for: user.id)
        return Double(stats.hoursVolunteered)
    }
    
    func isUserRegisteredForEvent(_ event: Event) -> Bool {
        guard currentUser != nil else { return false }
        
        // Check if user is registered for this event
        // This would need to be implemented based on your event registration system
        return false
    }
    
    func searchUsers(query: String) -> [AppModels.User] {
        let allUsers = coreDataManager.getAllUsers()
        
        return allUsers.filter { user in
            user.firstName.localizedCaseInsensitiveContains(query) ||
            user.lastName.localizedCaseInsensitiveContains(query) ||
            user.email.localizedCaseInsensitiveContains(query) ||
            (user.companyName?.localizedCaseInsensitiveContains(query) == true)
        }
    }
    
    func getUsersByRole(_ role: AppModels.UserRole) -> [AppModels.User] {
        let allUsers = coreDataManager.getAllUsers()
        
        return allUsers.filter { user in
            user.role == role
        }
    }
    
    func getUserRanking() -> [AppModels.User] {
        let allUsers = coreDataManager.getAllUsers()
        
        return allUsers.sorted { user1, user2 in
            let stats1 = coreDataManager.getUserStats(for: user1.id)
            let stats2 = coreDataManager.getUserStats(for: user2.id)
            
            let score1 = Double(stats1.mealsPrepared) * 2.0 + Double(stats1.hoursVolunteered) * 1.5
            let score2 = Double(stats2.mealsPrepared) * 2.0 + Double(stats2.hoursVolunteered) * 1.5
            
            return score1 > score2
        }
    }
    
    func validateUserProfile(_ user: AppModels.User) -> [String] {
        var errors: [String] = []
        
        if user.firstName.isEmpty {
            errors.append("First name is required")
        }
        
        if user.lastName.isEmpty {
            errors.append("Last name is required")
        }
        
        if user.email.isEmpty {
            errors.append("Email is required")
        }
        
        if user.role == .wwcVolunteer && user.wwcNumber == nil {
            errors.append("WWCC number is required for WWCC volunteers")
        }
        
        if user.role == .manager && !user.hasFoodSafetyRegistration {
            errors.append("Food safety registration is required for managers")
        }
        
        return errors
    }
}
