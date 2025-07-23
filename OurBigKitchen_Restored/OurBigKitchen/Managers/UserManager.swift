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
            throw error
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
    
    func fetchUserProfile() -> AnyPublisher<AppModels.User, Error> {
        isLoading = true
        
        return Future { [weak self] promise in
            Task { @MainActor in
                do {
                    if let user = self?.currentUser {
                        self?.isLoading = false
                        promise(.success(user))
                    } else {
                        self?.isLoading = false
                        promise(.failure(AuthError.userNotFound))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func updateUserProfile(_ updatedUser: AppModels.User) -> AnyPublisher<AppModels.User, Error> {
        isLoading = true
        
        return Future { [weak self] promise in
            Task { @MainActor in
                do {
                    try self?.saveUser(updatedUser)
                    self?.isLoading = false
                    promise(.success(updatedUser))
                } catch {
                    self?.isLoading = false
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
}

// MARK: - Data Extensions
private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}