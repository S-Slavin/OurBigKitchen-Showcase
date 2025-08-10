import Foundation
import Combine
import SwiftUI

class AuthenticationService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    
    static let shared = AuthenticationService()
    
    private init() {}
    
    func signIn(email: String, password: String) -> AnyPublisher<User, Error> {
        // For demo purposes, just return a mock user
        let user = User(
            id: "user1",
            firstName: "Demo",
            lastName: "User",
            email: email,
            profileImageURL: nil,
            bio: nil,
            role: .volunteer,
            preferences: UserPreferences(),
            achievements: [],
            stats: UserStats(),
            hasFoodSafetyRegistration: false,
            authProvider: "email"
        )
        
        return Just(user)
            .setFailureType(to: Error.self)
            .delay(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] user in
                self?.currentUser = user
                self?.isAuthenticated = true
            })
            .eraseToAnyPublisher()
    }
    
    func createUser(
        firstName: String,
        lastName: String,
        email: String,
        password: String,
        volunteerType: VolunteerType,
        dateOfBirth: Date,
        wwccNumber: String?,
        wwccExpiryDate: Date?
    ) -> AnyPublisher<User, Error> {
        // Create a new user with unique ID
        let user = User(
            id: UUID().uuidString,
            firstName: firstName,
            lastName: lastName,
            email: email,
            profileImageURL: nil,
            bio: nil,
            role: .volunteer,
            preferences: UserPreferences(),
            achievements: [],
            stats: UserStats(),
            hasFoodSafetyRegistration: false,
            authProvider: "email"
        )
        
        // Store additional user data for WWCC and volunteer type
        // In a real app, this would be saved to a database
        let userData: [String: Any] = [
            "volunteerType": volunteerType == .individual ? "individual" : "corporate",
            "dateOfBirth": dateOfBirth,
            "wwccNumber": wwccNumber ?? "",
            "wwccExpiryDate": wwccExpiryDate ?? Date(),
            "isAdult": Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0 >= 18
        ]
        
        // Save to UserDefaults for now (in real app, use database)
        UserDefaults.standard.set(userData, forKey: "user_\(user.id)_details")
        
        // Schedule WWCC renewal reminders if applicable
        if let wwccExpiry = wwccExpiryDate, !wwccNumber.isEmpty {
            scheduleWWCCReminders(for: wwccExpiry, userId: user.id)
        }
        
        return Just(user)
            .setFailureType(to: Error.self)
            .delay(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] user in
                self?.currentUser = user
                self?.isAuthenticated = true
            })
            .eraseToAnyPublisher()
    }
    
    private func scheduleWWCCReminders(for expiryDate: Date, userId: String) {
        let reminderDates: [(TimeInterval, String)] = [
            (3 * 30 * 24 * 60 * 60, "3 months"), // 3 months
            (2 * 30 * 24 * 60 * 60, "2 months"), // 2 months
            (30 * 24 * 60 * 60, "1 month"),      // 1 month
            (14 * 24 * 60 * 60, "2 weeks"),      // 2 weeks
            (7 * 24 * 60 * 60, "1 week"),        // 1 week
            (24 * 60 * 60, "1 day")               // 1 day
        ]
        
        for (timeInterval, description) in reminderDates {
            let reminderDate = expiryDate.addingTimeInterval(-timeInterval)
            
            // Only schedule if reminder date is in the future
            if reminderDate > Date() {
                let reminder = [
                    "userId": userId,
                    "type": "wwcc_renewal",
                    "message": "Your WWCC expires in \(description). Please renew it to continue volunteering.",
                    "date": reminderDate
                ] as [String: Any]
                
                // Store reminder (in real app, use local notifications or push notifications)
                var reminders = UserDefaults.standard.array(forKey: "wwcc_reminders") as? [[String: Any]] ?? []
                reminders.append(reminder)
                UserDefaults.standard.set(reminders, forKey: "wwcc_reminders")
            }
        }
    }
    
    func signOut() {
        currentUser = nil
        isAuthenticated = false
    }
    
    func resetPassword(email: String) -> AnyPublisher<Void, Error> {
        return Just(())
            .setFailureType(to: Error.self)
            .delay(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
} 