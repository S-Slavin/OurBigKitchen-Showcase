//
//  UserManager.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//


import Foundation
import Combine
import SwiftUI

// MARK: - User Manager

@MainActor
final class UserManager: ObservableObject {
    static let shared = UserManager()
    
    @Published private(set) var currentUser: AppModels.User?
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    private let defaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        loadUser()
    }
    
    // MARK: - User Management
    
    func loadUser() {
        if let userData = defaults.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(AppModels.User.self, from: userData) {
            self.currentUser = user
        }
    }
    
    func saveUser(_ user: AppModels.User) throws {
        let encoder = JSONEncoder()
        do {
            let userData = try encoder.encode(user)
            defaults.set(userData, forKey: "currentUser")
            self.currentUser = user
        } catch {
            throw UserManagerError.saveFailed(error)
        }
    }
    
    func updateUser(_ user: AppModels.User) throws {
        try saveUser(user)
        NotificationCenter.default.post(name: .didUpdateUser, object: nil)
    }
    
    func deleteUser() {
        defaults.removeObject(forKey: "currentUser")
        self.currentUser = nil
        NotificationCenter.default.post(name: .didDeleteUser, object: nil)
    }
    
    func getCurrentUser() -> AnyPublisher<AppModels.User, Error> {
        isLoading = true
        
        return Future { [weak self] promise in
            Task { @MainActor in
                guard let self = self else {
                    promise(.failure(UserManagerError.managerNotAvailable))
                    return
                }
                
                guard let currentUser = self.currentUser else {
                    promise(.failure(UserManagerError.userNotFound))
                    return
                }
                
                self.isLoading = false
                promise(.success(currentUser))
            }
        }.eraseToAnyPublisher()
    }
    
    func updateUserProfile(_ updatedUser: AppModels.User) -> AnyPublisher<AppModels.User, Error> {
        isLoading = true
        
        return Future { [weak self] promise in
            Task { @MainActor in
                guard let self = self else {
                    promise(.failure(UserManagerError.managerNotAvailable))
                    return
                }
                
                do {
                    try self.saveUser(updatedUser)
                    self.isLoading = false
                    promise(.success(updatedUser))
                } catch {
                    self.isLoading = false
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func updateUserPreferences(_ preferences: [String: Any]) {
        guard var user = currentUser else { return }
        user.preferences.update(with: preferences)
        try? saveUser(user)
        NotificationCenter.default.post(name: .didUpdatePreferences, object: nil)
    }
    
    func clearUserData() {
        defaults.removeObject(forKey: "currentUser")
        defaults.removeObject(forKey: "userPreferences")
        self.currentUser = nil
        NotificationCenter.default.post(name: .didClearUserData, object: nil)
    }
    
    // MARK: - Ranking Methods
    
    func getUserRankings(category: UserRankingCategory) -> AnyPublisher<[UserRanking], Error> {
        // TODO: Implement real Salesforce integration when ready
        // This will fetch actual rankings from Salesforce instead of mock data
        return Future { [weak self] promise in
            Task { @MainActor in
                guard let self = self else {
                    promise(.failure(UserManagerError.managerNotAvailable))
                    return
                }
                
                guard let currentUser = self.currentUser else {
                    promise(.failure(UserManagerError.userNotFound))
                    return
                }
                
                // For now, return empty array until Salesforce integration is ready
                // In production, this will make a real API call to Salesforce
                let rankings: [UserRanking] = []
                promise(.success(rankings))
            }
        }.eraseToAnyPublisher()
    }
    
    // MARK: - Salesforce Integration Preparation
    
    func syncUserWithSalesforce() -> AnyPublisher<AppModels.User, Error> {
        // TODO: Implement when Salesforce integration is ready
        return Future { [weak self] promise in
            Task { @MainActor in
                guard let self = self else {
                    promise(.failure(UserManagerError.managerNotAvailable))
                    return
                }
                
                guard let currentUser = self.currentUser else {
                    promise(.failure(UserManagerError.userNotFound))
                    return
                }
                
                // For now, just return the current user
                // In production, this will sync with Salesforce
                promise(.success(currentUser))
            }
        }.eraseToAnyPublisher()
    }
    
    // MARK: - Computed Properties
    
    var currentUserId: String? {
        return currentUser?.id
    }
    
    var isUserLoggedIn: Bool {
        return currentUser != nil
    }
}

// MARK: - User Manager Errors

enum UserManagerError: LocalizedError {
    case saveFailed(Error)
    case loadFailed(Error)
    case userNotFound
    case managerNotAvailable
    case invalidUserData
    
    var errorDescription: String? {
        switch self {
        case .saveFailed(let error):
            return "Failed to save user: \(error.localizedDescription)"
        case .loadFailed(let error):
            return "Failed to load user: \(error.localizedDescription)"
        case .userNotFound:
            return "User not found"
        case .managerNotAvailable:
            return "User manager not available"
        case .invalidUserData:
            return "Invalid user data"
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let didUpdateUser = Notification.Name("didUpdateUser")
    static let didDeleteUser = Notification.Name("didDeleteUser")
    static let didUpdatePreferences = Notification.Name("didUpdatePreferences")
    static let didClearUserData = Notification.Name("didClearUserData")
}