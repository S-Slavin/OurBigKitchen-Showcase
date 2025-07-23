//
//  FoodSafetyViewModel.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class FoodSafetyViewModel: ObservableObject {
    @Published var participantName: String = ""
    @Published var participantEmail: String = ""
    @Published var isLoading = false
    @Published var error: Error?
    @Published var showSuccessMessage = false
    @Published var validationError: String?
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    private let foodSafetyService: FoodSafetyService
    private let userManager: UserManager
    private let authManager: AuthManager
    private let termsManager: TermsManager
    
    init(foodSafetyService: FoodSafetyService = FoodSafetyService.shared, 
         userManager: UserManager = UserManager.shared,
         authManager: AuthManager = AuthManager.shared,
         termsManager: TermsManager = TermsManager.shared) {
        self.foodSafetyService = foodSafetyService
        self.userManager = userManager
        self.authManager = authManager
        self.termsManager = termsManager
        prefillUserData()
    }
    
    // MARK: - Data Loading
    
    private func prefillUserData() {
        userManager.fetchUserProfile()
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] user in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self?.participantName = user.fullName
                        self?.participantEmail = user.email
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Form Actions
    
    func resetForm() {
        // Don't reset name and email if they're prefilled from user data
        withAnimation(.easeInOut(duration: 0.3)) {
            validationError = nil
        }
    }
    
    // New method to maintain compatibility with the updated UI
    func submitForm() {
        submitRegistration()
    }
    
    func submitRegistration() {
        // Validate form
        if !validateForm() {
            // Apply animation to show error with a slight bounce effect
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                // The validation error is already set in validateForm()
            }
            return
        }
        
        isLoading = true
        
        // Create registration object
        let registration = FoodSafetyRegistration(
            participantName: participantName,
            participantEmail: participantEmail,
            agreementAccepted: termsManager.hasAcceptedTerms
        )
        
        // Submit registration
        foodSafetyService.submitRegistration(registration)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                
                if case .failure(let error) = completion {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self?.error = error
                    }
                }
            } receiveValue: { [weak self] _ in
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    self?.showSuccessMessage = true
                    self?.resetForm()
                }
                
                // Hide success message after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        self?.showSuccessMessage = false
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Validation
    
    // Computed property to show if form can be submitted
    var canSubmit: Bool {
        return !participantName.isEmpty && 
               !participantEmail.isEmpty && 
               termsManager.hasAcceptedTerms &&
               !isLoading
    }
    
    func validateForm() -> Bool {
        // Reset validation errors
        validationError = nil
        
        // Check name and email
        if !foodSafetyService.validateRegistration(name: participantName, email: participantEmail) {
            if participantName.isEmpty {
                validationError = "Please enter your name"
            } else if participantEmail.isEmpty {
                validationError = "Please enter your email"
            } else {
                validationError = "Please enter a valid email address"
            }
            return false
        }
        
        // Check agreement using TermsManager
        if !termsManager.hasAcceptedTerms {
            validationError = "Please accept the terms and conditions"
            return false
        }
        
        return true
    }
} 