import Foundation
import Combine
import SwiftUI

@MainActor
class RealUserService: ObservableObject {
    static let shared = RealUserService()
    
    @Published var currentUser: AppModels.User?
    @Published var userProfile: AppModels.User?
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private let coreDataManager = CoreDataManager.shared
    private let authService = RealAuthService.shared
    
    private init() {
        currentUser = authService.currentUser
    }
    
    // MARK: - User Profile Management
    
    func updateProfile(
        userId: String,
        firstName: String,
        lastName: String,
        bio: String?,
        companyName: String?,
        companyPosition: String?,
        companyEmail: String?
    ) async throws {
        isLoading = true
        defer { isLoading = false }
        
        // Validate input
        try validateProfileInput(
            firstName: firstName,
            lastName: lastName,
            companyEmail: companyEmail
        )
        
        // Update user in Core Data
        guard let coreDataUser = coreDataManager.fetchUser(by: userId) else {
            throw UserError.userNotFound
        }
        
        coreDataUser.firstName = firstName
        coreDataUser.lastName = lastName
        coreDataUser.bio = bio
        coreDataUser.companyName = companyName
        coreDataUser.companyPosition = companyPosition
        coreDataUser.companyEmail = companyEmail
        
        coreDataManager.updateUser(coreDataUser)
        
        // Update current user if it's the same user
        if currentUser?.id == userId {
            currentUser?.firstName = firstName
            currentUser?.lastName = lastName
            currentUser?.bio = bio
            currentUser?.companyName = companyName
            currentUser?.companyPosition = companyPosition
            currentUser?.companyEmail = companyEmail
        }
        
        // Update user profile
        userProfile = convertToAppUser(coreDataUser)
    }
    
    func updateWWCC(
        userId: String,
        wwcNumber: String,
        wwcExpiryDate: Date
    ) async throws {
        isLoading = true
        defer { isLoading = false }
        
        // Validate WWCC
        try validateWWCC(number: wwcNumber, expiryDate: wwcExpiryDate)
        
        // Update user in Core Data
        guard let coreDataUser = coreDataManager.fetchUser(by: userId) else {
            throw UserError.userNotFound
        }
        
        coreDataUser.wwcNumber = wwcNumber
        coreDataUser.wwcExpiry = wwcExpiryDate
        
        coreDataManager.updateUser(coreDataUser)
        
        // Update current user if it's the same user
        if currentUser?.id == userId {
            currentUser?.wwcNumber = wwcNumber
            currentUser?.wwcExpiry = wwcExpiryDate
        }
        
        // Update user profile
        userProfile = convertToAppUser(coreDataUser)
    }
    
    func updateFoodSafetyRegistration(
        userId: String,
        hasRegistration: Bool
    ) async throws {
        isLoading = true
        defer { isLoading = false }
        
        // Update user in Core Data
        guard let coreDataUser = coreDataManager.fetchUser(by: userId) else {
            throw UserError.userNotFound
        }
        
        coreDataUser.hasFoodSafetyRegistration = hasRegistration
        
        coreDataManager.updateUser(coreDataUser)
        
        // Update current user if it's the same user
        if currentUser?.id == userId {
            currentUser?.hasFoodSafetyRegistration = hasRegistration
        }
        
        // Update user profile
        userProfile = convertToAppUser(coreDataUser)
    }
    
    func updateProfileImage(
        userId: String,
        imageURL: String
    ) async throws {
        isLoading = true
        defer { isLoading = false }
        
        // Update user in Core Data
        guard let coreDataUser = coreDataManager.fetchUser(by: userId) else {
            throw UserError.userNotFound
        }
        
        coreDataUser.profileImageURL = imageURL
        
        coreDataManager.updateUser(coreDataUser)
        
        // Update current user if it's the same user
        if currentUser?.id == userId {
            currentUser?.profileImageURL = imageURL
        }
        
        // Update user profile
        userProfile = convertToAppUser(coreDataUser)
    }
    
    // MARK: - User Preferences
    
    func updatePreferences(
        userId: String,
        notificationsEnabled: Bool,
        darkMode: Bool,
        language: String
    ) async throws {
        isLoading = true
        defer { isLoading = false }
        
        // Update user preferences in Core Data
        guard let coreDataUser = coreDataManager.fetchUser(by: userId),
              let preferences = coreDataUser.preferences else {
            throw UserError.userNotFound
        }
        
        preferences.notificationsEnabled = notificationsEnabled
        preferences.darkMode = darkMode
        preferences.language = language
        
        coreDataManager.updateUser(coreDataUser)
        
        // Update current user if it's the same user
        if currentUser?.id == userId {
            currentUser?.preferences.notificationsEnabled = notificationsEnabled
            currentUser?.preferences.darkMode = darkMode
            currentUser?.preferences.language = language
        }
        
        // Update user profile
        userProfile = convertToAppUser(coreDataUser)
    }
    
    // MARK: - User Statistics
    
    func getUserStats(userId: String) -> AppModels.UserStats {
        let stats = coreDataManager.getUserStats(for: userId)
        
        return AppModels.UserStats(
            hoursVolunteered: Int(stats.hours),
            mealsPrepared: Int(stats.meals),
            eventsAttended: Int(stats.events)
        )
    }
    
    func getUserImpact(userId: String) -> (meals: Int32, people: Int32, hours: Double) {
        let userStats = coreDataManager.getUserStats(for: userId)
        let userMetrics = coreDataManager.fetchImpactMetrics(for: userId)
        
        let totalMeals = userMetrics.reduce(0) { $0 + $1.mealsPrepared }
        let totalPeople = userMetrics.reduce(0) { $0 + $1.peopleServed }
        let totalHours = userStats.hours
        
        return (meals: totalMeals, people: totalPeople, hours: totalHours)
    }
    
    func getUserActivities(userId: String) -> [Activity] {
        return coreDataManager.fetchActivities(for: userId)
    }
    
    func getUserEvents(userId: String) -> [Event] {
        return coreDataManager.fetchEvents().filter { event in
            guard let volunteers = event.volunteers?.allObjects as? [User] else { return false }
            return volunteers.contains { $0.id == userId }
        }
    }
    
    func getUserVolunteerSessions(userId: String) -> [VolunteerSession] {
        return coreDataManager.fetchVolunteerSessions(for: userId)
    }
    
    // MARK: - User Search and Discovery
    
    func searchUsers(query: String) -> [AppModels.User] {
        let allUsers = coreDataManager.fetchUsers()
        
        if query.isEmpty {
            return allUsers.map { convertToAppUser($0) }
        }
        
        return allUsers.filter { user in
            let fullName = "\(user.firstName ?? "") \(user.lastName ?? "")"
            return fullName.localizedCaseInsensitiveContains(query) ||
                   user.email?.localizedCaseInsensitiveContains(query) == true ||
                   user.companyName?.localizedCaseInsensitiveContains(query) == true
        }.map { convertToAppUser($0) }
    }
    
    func getUsersByRole(role: String) -> [AppModels.User] {
        let allUsers = coreDataManager.fetchUsers()
        
        return allUsers.filter { user in
            user.role == role
        }.map { convertToAppUser($0) }
    }
    
    func getTopVolunteers(limit: Int = 10) -> [AppModels.User] {
        let allUsers = coreDataManager.fetchUsers()
        var userScores: [(user: User, score: Double)] = []
        
        for user in allUsers {
            let stats = coreDataManager.getUserStats(for: user.id ?? "")
            let score = Double(stats.meals) * 2.0 + Double(stats.hours) * 1.5
            userScores.append((user: user, score: score))
        }
        
        return userScores.sorted { $0.score > $1.score }
            .prefix(limit)
            .map { convertToAppUser($0.user) }
    }
    
    // MARK: - User Validation
    
    func validateUserProfile(userId: String) -> [String] {
        var issues: [String] = []
        
        guard let user = coreDataManager.fetchUser(by: userId) else {
            issues.append("User not found")
            return issues
        }
        
        // Check required fields
        if user.firstName?.isEmpty == true {
            issues.append("First name is required")
        }
        
        if user.lastName?.isEmpty == true {
            issues.append("Last name is required")
        }
        
        if user.email?.isEmpty == true {
            issues.append("Email is required")
        }
        
        // Check WWCC if required for role
        if user.role == "wwcVolunteer" {
            if user.wwcNumber?.isEmpty == true {
                issues.append("WWCC number is required for WWC volunteers")
            }
            
            if let wwcExpiry = user.wwcExpiry, wwcExpiry <= Date() {
                issues.append("WWCC has expired")
            }
        }
        
        // Check food safety registration if required
        if user.role == "manager" && !user.hasFoodSafetyRegistration {
            issues.append("Food safety registration is required for managers")
        }
        
        return issues
    }
    
    func isProfileComplete(userId: String) -> Bool {
        return validateUserProfile(userId: userId).isEmpty
    }
    
    // MARK: - Helper Methods
    
    private func validateProfileInput(
        firstName: String,
        lastName: String,
        companyEmail: String?
    ) throws {
        guard !firstName.isEmpty else {
            throw UserError.invalidFirstName
        }
        
        guard !lastName.isEmpty else {
            throw UserError.invalidLastName
        }
        
        if let companyEmail = companyEmail, !companyEmail.isEmpty {
            guard validateEmail(companyEmail) else {
                throw UserError.invalidCompanyEmail
            }
        }
    }
    
    private func validateWWCC(number: String, expiryDate: Date) throws {
        guard number.count >= 8 else {
            throw UserError.invalidWWCCNumber
        }
        
        guard expiryDate > Date() else {
            throw UserError.wwccExpired
        }
    }
    
    private func validateEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func convertToAppUser(_ coreDataUser: User) -> AppModels.User {
        let role: AppModels.UserRole
        switch coreDataUser.role {
        case "admin": role = .admin
        case "manager": role = .manager
        case "corporateVolunteer": role = .corporateVolunteer
        case "wwcVolunteer": role = .wwcVolunteer
        default: role = .volunteer
        }
        
        let preferences = AppModels.UserPreferences(
            notificationsEnabled: coreDataUser.preferences?.notificationsEnabled ?? true,
            darkMode: coreDataUser.preferences?.darkMode ?? false,
            language: coreDataUser.preferences?.language ?? "en"
        )
        
        let stats = AppModels.UserStats(
            hoursVolunteered: Int(coreDataUser.stats?.hoursVolunteered ?? 0),
            mealsPrepared: Int(coreDataUser.stats?.mealsPrepared ?? 0),
            eventsAttended: Int(coreDataUser.stats?.eventsAttended ?? 0)
        )
        
        return AppModels.User(
            id: coreDataUser.id ?? "",
            firstName: coreDataUser.firstName ?? "",
            lastName: coreDataUser.lastName ?? "",
            email: coreDataUser.email ?? "",
            profileImageURL: coreDataUser.profileImageURL,
            bio: coreDataUser.bio,
            role: role,
            preferences: preferences,
            achievements: [],
            stats: stats,
            hasFoodSafetyRegistration: coreDataUser.hasFoodSafetyRegistration,
            authProvider: coreDataUser.authProvider,
            company: coreDataUser.company,
            dob: coreDataUser.dob,
            wwcNumber: coreDataUser.wwcNumber,
            wwcExpiry: coreDataUser.wwcExpiry,
            companyName: coreDataUser.companyName,
            companyPosition: coreDataUser.companyPosition,
            companyEmail: coreDataUser.companyEmail
        )
    }
}

// MARK: - User Errors

enum UserError: LocalizedError {
    case userNotFound
    case invalidFirstName
    case invalidLastName
    case invalidCompanyEmail
    case invalidWWCCNumber
    case wwccExpired
    
    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "User not found"
        case .invalidFirstName:
            return "First name is required"
        case .invalidLastName:
            return "Last name is required"
        case .invalidCompanyEmail:
            return "Invalid company email address"
        case .invalidWWCCNumber:
            return "Invalid WWCC number"
        case .wwccExpired:
            return "WWCC has expired"
        }
    }
}
