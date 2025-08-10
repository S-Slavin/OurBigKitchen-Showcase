import Foundation
import Combine
import SwiftUI
import UserNotifications

@MainActor
final class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isAuthenticated = false
    @Published var currentUser: AppModels.User?
    @Published var error: Error?
    @Published var isLoading = false
    
    private let authService: AuthService
    private let userManager: UserManager
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        self.authService = AuthService.shared
        self.userManager = UserManager.shared
    }
    
    // MARK: - User Management
    
    func saveUser(user: AppModels.User) throws {
        try userManager.saveUser(user)
        self.currentUser = user
        self.isAuthenticated = true
        NotificationCenter.default.post(name: .didUpdateAuth, object: nil)
        
        // Schedule WWCC reminders if applicable (for any volunteer with WWCC details)
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
    
    func loginWithApplePublisher() -> AnyPublisher<AppModels.User, Error> {
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
                        promise(.failure(AuthError.appleSignInFailed))
                    }
                } catch {
                    self?.error = error
                    self?.isLoading = false
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func loginWithGmailPublisher() -> AnyPublisher<AppModels.User, Error> {
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
                        promise(.failure(AuthError.googleSignInFailed))
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
        Task { @MainActor in
            do {
                try await authService.signOut()
                self.currentUser = nil
                self.isAuthenticated = false
                NotificationCenter.default.post(name: .didLogout, object: nil)
            } catch {
                self.error = error
            }
        }
    }
    
    func scheduleWWCCReminders(for user: AppModels.User) {
        guard let wwcExpiry = user.wwcExpiry else { return }
        
        let center = UNUserNotificationCenter.current()
        
        // Remove any existing WWCC reminders
        center.removePendingNotificationRequests(withIdentifiers: ["wwcc_3months", "wwcc_2months", "wwcc_1month", "wwcc_2weeks", "wwcc_1week", "wwcc_1day"])
        
        // Calculate reminder dates
        let calendar = Calendar.current
        let reminders = [
            (days: -90, id: "wwcc_3months", title: "WWCC Expiry - 3 Months", body: "Your Working with Children Check will expire in 3 months. Please start the renewal process."),
            (days: -60, id: "wwcc_2months", title: "WWCC Expiry - 2 Months", body: "Your Working with Children Check will expire in 2 months. Don't forget to renew it."),
            (days: -30, id: "wwcc_1month", title: "WWCC Expiry - 1 Month", body: "Your Working with Children Check will expire in 1 month. Please renew it soon."),
            (days: -14, id: "wwcc_2weeks", title: "WWCC Expiry - 2 Weeks", body: "Your Working with Children Check will expire in 2 weeks. Urgent: Please renew it."),
            (days: -7, id: "wwcc_1week", title: "WWCC Expiry - 1 Week", body: "Your Working with Children Check will expire in 1 week. Very urgent: Please renew it now."),
            (days: -1, id: "wwcc_1day", title: "WWCC Expiry - Tomorrow", body: "Your Working with Children Check will expire tomorrow. Critical: Please renew immediately.")
        ]
        
        for reminder in reminders {
            guard let date = calendar.date(byAdding: .day, value: reminder.days, to: wwcExpiry) else { continue }
            
            let content = UNMutableNotificationContent()
            content.title = reminder.title
            content.body = reminder.body
            content.sound = .default
            
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            let request = UNNotificationRequest(identifier: reminder.id, content: content, trigger: trigger)
            center.add(request)
        }
    }
} 