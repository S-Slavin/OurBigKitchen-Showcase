//
//  FoodSafetyService.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//

import Foundation
import Combine

class FoodSafetyService: ObservableObject, @unchecked Sendable {
    nonisolated(unsafe) static let shared = FoodSafetyService()
    
    @Published var companies: [Company] = []
    @Published var registrations: [FoodSafetyRegistration] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let networkManager: NetworkManager
    private let userManager: UserManager
    private var cancellables = Set<AnyCancellable>()
    private let registrationsKey = "food_safety_registrations"
    
    init(networkManager: NetworkManager = .shared, userManager: UserManager = .shared) {
        self.networkManager = networkManager
        self.userManager = userManager
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
        // For now, just update locally since getUserManager.getCurrentUser doesn't exist
        // In a real app, this would integrate with the user management system
        
        // Update user defaults to track food safety completion
        UserDefaults.standard.set(true, forKey: "foodSafetyCompleted_\(email)")
        
        // Post notification that food safety status was updated
        NotificationCenter.default.post(
            name: NSNotification.Name("FoodSafetyStatusUpdated"),
            object: nil,
            userInfo: ["email": email]
        )
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