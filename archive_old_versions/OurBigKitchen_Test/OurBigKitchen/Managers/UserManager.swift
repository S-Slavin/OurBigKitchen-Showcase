//
//  UserManager.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//


import Foundation
import Combine
import SwiftUI

// MARK: - Models

// Use AppModels.UserPreferences instead
struct LocalUserPreferences: Codable {
    var notificationsEnabled: Bool
    var emailUpdates: Bool
    var privacySettings: PrivacySettings
}

struct PrivacySettings: Codable {
    var showProfile: Bool
    var showActivities: Bool
    var showAchievements: Bool
}

struct Achievement: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let dateEarned: Date
    let type: AchievementType
    
    enum AchievementType: String, Codable {
        case volunteer
        case donor
        case organizer
        case leader
    }
}

// Using AppModels.User instead
struct UserRanking: Codable {
    let user: AppModels.User
    let score: Int
    let rank: Int
}

enum UserRankingCategory: String, Codable {
    case volunteer
    case donor
    case impact
}

// MARK: - UserManager
class UserManager {
    static let shared = UserManager()
    
    private let networkManager: NetworkManager
    private let persistenceManager: PersistenceManager
    private let currentUserKey = "currentUser"
    
    // Add computed property for current user ID
    var currentUserId: String? {
        do {
            let user = try persistenceManager.getObject(forKey: currentUserKey, as: AppModels.User.self)
            return user.id
        } catch {
            print("Error getting current user: \(error)")
            return nil
        }
    }
    
    private init(networkManager: NetworkManager = .shared,
                persistenceManager: PersistenceManager = .shared) {
        self.networkManager = networkManager
        self.persistenceManager = persistenceManager
    }
    
    // MARK: - User Operations
    
    func getCurrentUser() -> AnyPublisher<AppModels.User, Error> {
        // First try to get from persistence
        if let cachedUser = try? persistenceManager.getObject(forKey: currentUserKey, as: AppModels.User.self) {
            return Just(cachedUser)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        // If not in persistence, fetch from network
        return networkManager.get(endpoint: "/users/current")
            .handleEvents(receiveOutput: { [weak self] user in
                try? self?.persistenceManager.save(user, forKey: self?.currentUserKey ?? "")
                // Post notification when user is updated
                NotificationCenter.default.post(name: .didUpdateUser, object: nil)
            })
            .eraseToAnyPublisher()
    }
    
    // Add synchronous version of getCurrentUser for app startup
    func getCurrentUser() throws -> AppModels.User {
        // Try to get from persistence
        if let cachedUser = try? persistenceManager.getObject(forKey: currentUserKey, as: AppModels.User.self) {
            return cachedUser
        }
        
        // If no user is cached, create a default one to prevent blank screens
        let defaultUser = AppModels.User(
            id: UUID().uuidString,
            firstName: "Default",
            lastName: "User",
            email: "default@example.com",
            role: .volunteer
        )
        
        // Cache this default user
        try cacheUser(defaultUser)
        
        // Print for debugging
        print("Created default user to prevent blank screen")
        
        return defaultUser
    }
    
    // Add a method to directly cache a user object
    func cacheUser(_ user: AppModels.User) throws {
        try persistenceManager.save(user, forKey: currentUserKey)
        NotificationCenter.default.post(name: .didUpdateUser, object: nil)
    }
    
    func updateUser(_ user: AppModels.User) -> AnyPublisher<AppModels.User, Error> {
        return networkManager.put(endpoint: "/users/\(user.id)", body: user)
            .handleEvents(receiveOutput: { [weak self] updatedUser in
                try? self?.persistenceManager.save(updatedUser, forKey: self?.currentUserKey ?? "")
                // Post notification when user is updated
                NotificationCenter.default.post(name: .didUpdateUser, object: nil)
            })
            .eraseToAnyPublisher()
    }
    
    // MARK: - Rankings Operations
    
    func getUserRankings(category: UserRankingCategory) -> AnyPublisher<[UserRanking], Error> {
        return networkManager.get(endpoint: "/rankings/\(category.rawValue)")
    }
    
    // MARK: - Achievement Operations
    
    func getUserAchievements() -> AnyPublisher<[Achievement], Error> {
        return networkManager.get(endpoint: "/users/achievements")
    }
    
    func addAchievement(_ achievement: Achievement) -> AnyPublisher<Achievement, Error> {
        return networkManager.post(endpoint: "/users/achievements", body: achievement)
    }
    
    // MARK: - Preferences Operations
    
    func updateUserPreferences(_ preferences: AppModels.UserPreferences) -> AnyPublisher<AppModels.UserPreferences, Error> {
        return networkManager.put(endpoint: "/users/preferences", body: preferences)
    }
    
    // MARK: - Profile Image Operations
    
    struct ImageUploadResponse: Codable {
        let url: String
    }
    
    func uploadProfileImage(_ imageData: Data) -> AnyPublisher<String, Error> {
        // Create multipart form data
        var formData = Data()
        let boundary = "Boundary-\(UUID().uuidString)"
        
        formData.append("--\(boundary)\r\n")
        formData.append("Content-Disposition: form-data; name=\"image\"; filename=\"profile.jpg\"\r\n")
        formData.append("Content-Type: image/jpeg\r\n\r\n")
        formData.append(imageData)
        formData.append("\r\n--\(boundary)--\r\n")
        
        return networkManager.post(endpoint: "/users/profile-image", body: formData)
            .map { (response: ImageUploadResponse) in response.url }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Helper Methods
    
    func clearUserData() {
        try? persistenceManager.remove(forKey: currentUserKey)
        // Post notification when user is cleared
        NotificationCenter.default.post(name: .didUpdateUser, object: nil)
    }
    
    // New method to clear user cache with error handling for our updated AuthManager
    func clearUserCache() throws {
        try persistenceManager.remove(forKey: currentUserKey)
        // Post notification when user is cleared
        NotificationCenter.default.post(name: .didUpdateUser, object: nil)
    }
}

// MARK: - Data Extensions
private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}