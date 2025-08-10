import Foundation
import Combine
import SwiftUI

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published private(set) var isAuthenticated: Bool = false
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: Error?
    @Published private(set) var currentUser: AppModels.User?
    
    private let persistenceManager = PersistenceManager.shared
    private let userManager = UserManager.shared
    
    private let tokenKey = "authToken"
    private let userKey = "currentUser"
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        print("DEBUG: AuthManager initializing")
        checkAuthentication()
        
        // Set a flag to prevent multiple initialization checks
        if !UserDefaults.standard.bool(forKey: "authManagerInitialized") {
            UserDefaults.standard.set(true, forKey: "authManagerInitialized")
            UserDefaults.standard.synchronize()
        }
    }
    
    private func checkAuthentication() {
        do {
            if (try? persistenceManager.getString(forKey: tokenKey)) != nil,
               let user: AppModels.User = try? persistenceManager.getObject(forKey: userKey, as: AppModels.User.self) {
                self.currentUser = user
                self.isAuthenticated = true
                
                // Ensure UserDefaults is also updated
                UserDefaults.standard.set(true, forKey: "isAuthenticated")
                UserDefaults.standard.set(true, forKey: "hasSignedIn")
                UserDefaults.standard.synchronize()
                
                print("DEBUG: AuthManager restored authentication state for user: \(user.email)")
            } else if UserDefaults.standard.bool(forKey: "isAuthenticated") {
                // If UserDefaults says authenticated but we don't have the token,
                // create a simple user model to maintain authentication
                self.isAuthenticated = true
                print("DEBUG: AuthManager restored authentication state from UserDefaults")
            }
        }
    }
    
    func loginPublisher(email: String, password: String) -> AnyPublisher<AppModels.User, Error> {
        Future<AppModels.User, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(AuthError.unknown))
                return
            }
            
            guard !email.isEmpty, !password.isEmpty else {
                promise(.failure(AuthError.invalidCredentials))
                return
            }
            
            self.isLoading = true
            
            // Create mock user (replace with actual API call in production)
            let user = AppModels.User(
                id: UUID().uuidString,
                firstName: "Test",
                lastName: "User",
                email: email,
                role: .volunteer
            )
            
            do {
                try self.persistenceManager.saveString(UUID().uuidString, forKey: self.tokenKey)
                try self.persistenceManager.save(user, forKey: self.userKey)
                try self.userManager.cacheUser(user)
                
                self.currentUser = user
                self.isAuthenticated = true
                self.error = nil
                self.isLoading = false
                
                NotificationCenter.default.post(name: Notification.Name.didLogin, object: nil)
                NotificationCenter.default.post(name: Notification.Name.didUpdateAuth, object: nil)
                
                promise(.success(user))
            } catch {
                self.error = error
                self.isLoading = false
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // Renamed to avoid duplicate method
    func login(email: String, password: String) -> AnyPublisher<AppModels.User, Error> {
        Future<AppModels.User, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(AuthError.unknown))
                return
            }
            
            guard !email.isEmpty, !password.isEmpty else {
                promise(.failure(AuthError.invalidCredentials))
                return
            }
            
            self.isLoading = true
            
            // Create mock user (replace with actual API call in production)
            let user = AppModels.User(
                id: UUID().uuidString,
                firstName: "Test",
                lastName: "User",
                email: email,
                role: .volunteer
            )
            
            do {
                try self.persistenceManager.saveString(UUID().uuidString, forKey: self.tokenKey)
                try self.persistenceManager.save(user, forKey: self.userKey)
                try self.userManager.cacheUser(user)
                
                self.currentUser = user
                self.isAuthenticated = true
                self.error = nil
                self.isLoading = false
                
                NotificationCenter.default.post(name: Notification.Name.didLogin, object: nil)
                NotificationCenter.default.post(name: Notification.Name.didUpdateAuth, object: nil)
                
                promise(.success(user))
            } catch {
                self.error = error
                self.isLoading = false
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func logout() {
        do {
            try persistenceManager.remove(forKey: tokenKey)
            try persistenceManager.remove(forKey: userKey)
            
            currentUser = nil
            isAuthenticated = false
            error = nil
            
            NotificationCenter.default.post(name: Notification.Name.didLogout, object: nil)
            NotificationCenter.default.post(name: Notification.Name.didUpdateAuth, object: nil)
        } catch {
            self.error = error
        }
    }
    
    func loginWithGroupCode(email: String, groupCode: String) -> AnyPublisher<AppModels.User, Error> {
        Future<AppModels.User, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(AuthError.unknown))
                return
            }
            
            guard !email.isEmpty, !groupCode.isEmpty else {
                promise(.failure(AuthError.invalidCredentials))
                return
            }
            
            self.isLoading = true
            
            // Create mock user with group code (replace with actual API call in production)
            let user = AppModels.User(
                id: UUID().uuidString,
                firstName: "Group",
                lastName: "User",
                email: email,
                role: .volunteer
            )
            
            do {
                try self.persistenceManager.saveString(UUID().uuidString, forKey: self.tokenKey)
                try self.persistenceManager.save(user, forKey: self.userKey)
                try self.userManager.cacheUser(user)
                
                self.currentUser = user
                self.isAuthenticated = true
                self.error = nil
                self.isLoading = false
                
                NotificationCenter.default.post(name: Notification.Name.didLogin, object: nil)
                NotificationCenter.default.post(name: Notification.Name.didUpdateAuth, object: nil)
                
                promise(.success(user))
            } catch {
                self.error = error
                self.isLoading = false
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func loginWithApplePublisher() -> AnyPublisher<AppModels.User, Error> {
        Future<AppModels.User, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(AuthError.unknown))
                return
            }
            
            self.isLoading = true
            
            // Simulate Apple authentication (replace with actual Sign in with Apple in production)
            let user = AppModels.User(
                id: UUID().uuidString,
                firstName: "Apple",
                lastName: "User",
                email: "apple_user@example.com",
                role: .volunteer
            )
            
            do {
                try self.persistenceManager.saveString(UUID().uuidString, forKey: self.tokenKey)
                try self.persistenceManager.save(user, forKey: self.userKey)
                try self.userManager.cacheUser(user)
                
                self.currentUser = user
                self.isAuthenticated = true
                self.error = nil
                self.isLoading = false
                
                NotificationCenter.default.post(name: Notification.Name.didLogin, object: nil)
                NotificationCenter.default.post(name: Notification.Name.didUpdateAuth, object: nil)
                
                promise(.success(user))
            } catch {
                self.error = error
                self.isLoading = false
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func loginWithGmailPublisher() -> AnyPublisher<AppModels.User, Error> {
        Future<AppModels.User, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(AuthError.unknown))
                return
            }
            
            self.isLoading = true
            
            // Simulate Google authentication (replace with actual Google Sign-In in production)
            let user = AppModels.User(
                id: UUID().uuidString,
                firstName: "Google",
                lastName: "User",
                email: "google_user@gmail.com",
                role: .volunteer
            )
            
            do {
                try self.persistenceManager.saveString(UUID().uuidString, forKey: self.tokenKey)
                try self.persistenceManager.save(user, forKey: self.userKey)
                try self.userManager.cacheUser(user)
                
                self.currentUser = user
                self.isAuthenticated = true
                self.error = nil
                self.isLoading = false
                
                NotificationCenter.default.post(name: Notification.Name.didLogin, object: nil)
                NotificationCenter.default.post(name: Notification.Name.didUpdateAuth, object: nil)
                
                promise(.success(user))
            } catch {
                self.error = error
                self.isLoading = false
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Async Auth Methods
    
    func loginAsync(email: String, password: String) async throws -> AppModels.User {
        do {
            return try await self.loginPublisher(email: email, password: password).async()
        } catch {
            throw error
        }
    }
    
    func loginWithApple() async throws -> AppModels.User {
        do {
            return try await self.loginWithApplePublisher().async()
        } catch {
            throw error
        }
    }
    
    func loginWithGmail() async throws -> AppModels.User {
        do {
            return try await self.loginWithGmailPublisher().async()
        } catch {
            throw error
        }
    }
    
    // MARK: - Direct User Save Methods
    
    func saveUser(user: AppModels.User) throws {
        do {
            // Generate a token for this user
            let token = UUID().uuidString
            try persistenceManager.saveString(token, forKey: tokenKey)
            try persistenceManager.save(user, forKey: userKey)
            try userManager.cacheUser(user)
            
            // Update state
            self.currentUser = user
            self.isAuthenticated = true
            
            // Notify system
            NotificationCenter.default.post(name: Notification.Name.didLogin, object: nil)
            NotificationCenter.default.post(name: Notification.Name.didUpdateAuth, object: nil)
        } catch {
            self.error = error
            throw error
        }
    }
    
    func saveAppleUser(user: AppModels.User) throws {
        var updatedUser = user
        updatedUser.id = UUID().uuidString
        updatedUser.authProvider = "apple"
        
        do {
            try saveUser(user: updatedUser)
        } catch {
            throw error
        }
    }
    
    func saveGmailUser(user: AppModels.User) throws {
        var updatedUser = user
        updatedUser.id = UUID().uuidString
        updatedUser.authProvider = "gmail"
        
        do {
            try saveUser(user: updatedUser)
        } catch {
            throw error
        }
    }
} 