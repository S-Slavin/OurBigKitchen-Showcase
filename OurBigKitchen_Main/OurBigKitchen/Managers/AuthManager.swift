import Foundation
import Combine
import SwiftUI
import UserNotifications

@MainActor
final class AuthManager: ObservableObject {
    
    // MARK: - Singleton
    static let shared = AuthManager()
    
    // MARK: - Published Properties
    @Published var isAuthenticated = false
    @Published var currentUser: AppModels.User?
    @Published var error: Error?
    @Published var isLoading = false
    
    // MARK: - Private Properties
    private let authService: RealAuthService
    private let userManager: UserManager
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    private init() {
        self.authService = RealAuthService.shared
        self.userManager = UserManager.shared
    }
    
    // MARK: - User Management
    
    func saveUser(user: AppModels.User) throws {
        try userManager.saveUser(user)
        self.currentUser = user
        self.isAuthenticated = true
        NotificationCenter.default.post(name: .didUpdateAuth, object: nil)
        
        if user.wwcNumber != nil && user.wwcExpiry != nil {
            scheduleWWCCReminders(for: user)
        }
    }
    
    func saveAppleUser(user: AppModels.User) throws {
        var appleUser = user
        appleUser.authProvider = "apple"
        try saveUser(user: appleUser)
    }
    
    func saveGmailUser(user: AppModels.User) throws {
        var gmailUser = user
        gmailUser.authProvider = "gmail"
        try saveUser(user: gmailUser)
    }
    
    // MARK: - Authentication Methods
    
    func signIn(email: String, password: String) async throws {
        do {
            let user = try await authService.signIn(email: email, password: password)
            self.currentUser = user
            self.isAuthenticated = true
        } catch {
            self.error = error
            throw error
        }
    }
    
    func login(email: String, password: String) -> AnyPublisher<AppModels.User, Error> {
        isLoading = true
        
        return Future { [weak self] promise in
            Task { @MainActor in
                do {
                    let user = try await self?.authService.signIn(email: email, password: password)
                    self?.currentUser = user
                    self?.isAuthenticated = true
                    self?.isLoading = false
                    if let user = user {
                        promise(.success(user))
                    } else {
                        promise(.failure(AuthError.invalidCredentials))
                    }
                } catch {
                    self?.error = error
                    self?.isLoading = false
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func loginWithGroupCode(email: String, groupCode: String) -> AnyPublisher<AppModels.User, Error> {
        isLoading = true
        
        return Future { [weak self] promise in
            Task { @MainActor in
                do {
                    let user = try await self?.authService.signInWithGroupCode(code: groupCode)
                    self?.currentUser = user
                    self?.isAuthenticated = true
                    self?.isLoading = false
                    if let user = user {
                        promise(.success(user))
                    } else {
                        promise(.failure(AuthError.invalidGroupCode))
                    }
                } catch {
                    self?.error = error
                    self?.isLoading = false
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func loginWithApple() -> AnyPublisher<AppModels.User, Error> {
        isLoading = true
        
        return Future { [weak self] promise in
            Task { @MainActor in
                do {
                    let user = try await self?.authService.signInWithApple()
                    self?.currentUser = user
                    self?.isAuthenticated = true
                    self?.isLoading = false
                    if let user = user {
                        promise(.success(user))
                    } else {
                        promise(.failure(AuthError.authenticationFailed))
                    }
                } catch {
                    self?.error = error
                    self?.isLoading = false
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func loginWithGmail() -> AnyPublisher<AppModels.User, Error> {
        isLoading = true
        
        return Future { [weak self] promise in
            Task { @MainActor in
                do {
                    let user = try await self?.authService.signInWithGoogle()
                    self?.currentUser = user
                    self?.isAuthenticated = true
                    self?.isLoading = false
                    if let user = user {
                        promise(.success(user))
                    } else {
                        promise(.failure(AuthError.authenticationFailed))
                    }
                } catch {
                    self?.error = error
                    self?.isLoading = false
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func logout() {
        currentUser = nil
        isAuthenticated = false
        error = nil
        
        // Clear UserDefaults
        UserDefaults.standard.removeObject(forKey: "isAuthenticated")
        UserDefaults.standard.removeObject(forKey: "hasSignedIn")
        
        // Cancel WWCC reminders
        cancelWWCCReminders()
        
        // Post notification
        NotificationCenter.default.post(name: .didUpdateAuth, object: nil)
    }
    
    // MARK: - WWCC Reminder Management
    
    private func scheduleWWCCReminders(for user: AppModels.User) {
        guard let expiryDate = user.wwcExpiry else { return }
        
        let reminderDates: [TimeInterval] = [
            90 * 24 * 60 * 60,  // 3 months
            60 * 24 * 60 * 60,  // 2 months
            30 * 24 * 60 * 60,  // 1 month
            14 * 24 * 60 * 60,  // 2 weeks
            7 * 24 * 60 * 60,   // 1 week
            24 * 60 * 60        // 1 day
        ]
        
        for (index, interval) in reminderDates.enumerated() {
            let reminderDate = expiryDate.addingTimeInterval(-interval)
            
            if reminderDate > Date() {
                scheduleNotification(
                    title: "WWCC Renewal Reminder",
                    body: "Your Working with Children Check expires in \(index == 0 ? "3 months" : index == 1 ? "2 months" : index == 2 ? "1 month" : index == 3 ? "2 weeks" : index == 4 ? "1 week" : "1 day"). Please renew it to continue volunteering.",
                    date: reminderDate,
                    identifier: "wwcc_reminder_\(user.id)_\(index)"
                )
            }
        }
    }
    
    private func scheduleNotification(title: String, body: String, date: Date, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date),
            repeats: false
        )
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule WWCC reminder: \(error.localizedDescription)")
            }
        }
    }
    
    private func cancelWWCCReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

// MARK: - Auth Errors

enum AuthError: LocalizedError {
    case invalidCredentials
    case invalidGroupCode
    case authenticationFailed
    case networkError
    case userNotFound
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .invalidGroupCode:
            return "Invalid group code"
        case .authenticationFailed:
            return "Authentication failed"
        case .networkError:
            return "Network connection error"
        case .userNotFound:
            return "User not found"
        }
    }
} 