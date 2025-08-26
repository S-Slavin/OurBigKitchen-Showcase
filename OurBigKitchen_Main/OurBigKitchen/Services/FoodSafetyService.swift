//
//  FoodSafetyService.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//

import Foundation
import Combine

@MainActor
class FoodSafetyService: ObservableObject {
    static let shared = FoodSafetyService()
    
    @Published var companies: [Company] = []
    @Published var registrations: [FoodSafetyRegistration] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let networkManager: NetworkManager
    private let userManager: UserManager
    private var cancellables = Set<AnyCancellable>()
    private let registrationsKey = "food_safety_registrations"
    
    init(networkManager: NetworkManager? = nil, userManager: UserManager? = nil) {
        self.networkManager = networkManager ?? NetworkManager.shared
        self.userManager = userManager ?? UserManager.shared
        loadCompanies()
        loadRegistrations()
    }
    
    // MARK: - Data Loading
    
    func loadCompanies() {
        isLoading = true
        
        // In a real app, this would fetch from Salesforce
        // For now, we'll use mock data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            self.companies = [
                Company(id: "1", name: "TechCorp", salesforceId: "SF001"),
                Company(id: "2", name: "Global Finance", salesforceId: "SF002"),
                Company(id: "3", name: "Healthcare Partners", salesforceId: "SF003"),
                Company(id: "4", name: "Green Energy", salesforceId: "SF004"),
                Company(id: "5", name: "Local School District", salesforceId: "SF005"),
                Company(id: "6", name: "Community Bank", salesforceId: "SF006"),
                Company(id: "7", name: "Other", salesforceId: nil)
            ]
            
            self.isLoading = false
        }
    }
    
    func loadRegistrations() {
        guard let data = UserDefaults.standard.data(forKey: registrationsKey) else {
            return
        }
        
        do {
            registrations = try JSONDecoder().decode([FoodSafetyRegistration].self, from: data)
        } catch {
            self.error = error
        }
    }
    
    // MARK: - Registration
    
    func submitRegistration(_ registration: FoodSafetyRegistration) -> AnyPublisher<FoodSafetyRegistration, Error> {
        // In a real app, this would send to an API and Salesforce
        return networkManager.post(endpoint: Endpoint.foodSafety.path, body: registration)
            .handleEvents(receiveOutput: { [weak self] savedRegistration in
                guard let self = self else { return }
                
                // Add to local registrations
                self.registrations.append(savedRegistration)
                self.saveRegistrations()
                
                // Update user's food safety status
                self.updateUserFoodSafetyStatus(email: savedRegistration.participantEmail)
            })
            .catch { [weak self] error -> AnyPublisher<FoodSafetyRegistration, Error> in
                // For demo purposes, simulate successful registration even if network fails
                self?.registrations.append(registration)
                self?.saveRegistrations()
                
                // Update user's food safety status
                self?.updateUserFoodSafetyStatus(email: registration.participantEmail)
                
                return Just(registration)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - User Status Update
    
    private func updateUserFoodSafetyStatus(email: String) {
        // Get current user
        userManager.getCurrentUser()
            .map { user -> AppModels.User? in
                // Only update if this is the current user's email
                guard user.email.lowercased() == email.lowercased() else {
                    return nil
                }
                
                // Create updated user with food safety flag set to true
                if !user.hasFoodSafetyRegistration {
                    let updatedUser = AppModels.User(
                        id: user.id,
                        firstName: user.firstName,
                        lastName: user.lastName,
                        email: user.email,
                        profileImageURL: user.profileImageURL,
                        bio: user.bio,
                        role: user.role,
                        preferences: user.preferences,
                        achievements: user.achievements,
                        stats: user.stats,
                        hasFoodSafetyRegistration: true
                    )
                    
                    // Update the user
                    return updatedUser
                }
                
                return nil
            }
            .flatMap { [weak self] updatedUser -> AnyPublisher<AppModels.User, Error> in
                guard let self = self, let user = updatedUser else {
                    return Fail(error:  NSError(domain: "FoodSafetyService", code: 400, userInfo: [NSLocalizedDescriptionKey: "No user to update"]))
                        .eraseToAnyPublisher()
                }
                
                return self.userManager.updateUserProfile(user)
            }
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Persistence
    
    private func saveRegistrations() {
        do {
            let data = try JSONEncoder().encode(registrations)
            UserDefaults.standard.set(data, forKey: registrationsKey)
        } catch {
            self.error = error
        }
    }
    
    // MARK: - Validation
    
    func validateRegistration(name: String, email: String) -> Bool {
        // Basic validation
        guard !name.isEmpty, !email.isEmpty else {
            return false
        }
        
        // Name validation (at least two words)
        let nameParts = name.split(separator: " ")
        guard nameParts.count >= 2 else {
            return false
        }
        
        // Email validation
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func checkUserHasCompletedRegistration(email: String) -> Bool {
        // Check if user already has a registration
        return registrations.contains { $0.participantEmail.lowercased() == email.lowercased() }
    }
} 
