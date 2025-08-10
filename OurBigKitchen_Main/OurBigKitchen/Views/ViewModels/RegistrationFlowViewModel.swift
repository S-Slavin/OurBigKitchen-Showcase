import Foundation
import Combine
import SwiftUI

class RegistrationFlowViewModel: ObservableObject {
    @Published var currentStep: Int = 0
    let totalSteps = 5
    
    enum UserType: String, CaseIterable, Identifiable {
        case individual = "Individual Volunteer"
        case corporate = "Corporate/Group"
        var id: String { self.rawValue }
    }
    @Published var selectedUserType: UserType? = nil
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var mobile: String = ""
    @Published var dob: Date = Date()
    @Published var address: String = ""
    @Published var city: String = ""
    @Published var state: String = ""
    @Published var postalCode: String = ""
    @Published var emergencyName: String = ""
    @Published var emergencyPhone: String = ""
    @Published var companyName: String = ""
    @Published var wwcNumber: String = ""
    @Published var wwcExpiry: Date = Date()
    @Published var dietaryRestrictions: String = ""
    @Published var medicalConditions: String = ""
    @Published var volunteerExperience: String = ""
    @Published var skills: String = ""
    @Published var availability: String = ""
    @Published var motivation: String = ""
    @Published var isDukeOfEd: Bool = false
    @Published var referralSource: String = ""
    @Published var hasAcceptedFoodSafety: Bool = false
    @Published var hasAcceptedTerms: Bool = false
    @Published var isSubmitting: Bool = false
    @Published var showSuccessMessage: Bool = false
    @Published var errorMessage: String? = nil
    
    private let authService = RealAuthService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // No need for dependency injection since we're using the shared instance
    }
    
    var isOver18: Bool {
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: dob, to: now)
        return (ageComponents.year ?? 0) >= 18
    }
    var isPersonalDetailsValid: Bool {
        !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty && !mobile.isEmpty && password == confirmPassword
    }
    var isWWCCValid: Bool {
        if isOver18 {
            return !wwcNumber.isEmpty && wwcExpiry > Date()
        }
        return true
    }
    var isAdditionalInfoValid: Bool {
        true // Make this always valid for demo purposes
    }
    var isFoodSafetyValid: Bool {
        true // Make this always valid for demo purposes
    }
    var isTermsValid: Bool {
        true // Make this always valid for demo purposes
    }
    var isReviewValid: Bool {
        isPersonalDetailsValid && isWWCCValid && isAdditionalInfoValid && isFoodSafetyValid && isTermsValid
    }
    
    func submitRegistration() {
        isSubmitting = true
        errorMessage = nil
        
        // Convert UserType to VolunteerType for the auth service
        let volunteerType: VolunteerType = selectedUserType == .corporate ? .corporate : .individual
        
        // Determine WWCC details based on age
        let wwcNumberToUse: String? = isOver18 ? wwcNumber : nil
        let wwcExpiryToUse: Date? = isOver18 ? wwcExpiry : nil
        
        Task {
            do {
                let user = try await authService.signUp(
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    password: password,
                    volunteerType: volunteerType,
                    dob: dob,
                    wwcNumber: wwcNumberToUse,
                    wwcExpiryDate: wwcExpiryToUse
                )
                
                await MainActor.run {
                    self.isSubmitting = false
                    self.showSuccessMessage = true
                    self.errorMessage = nil
                }
                
                // TODO: Store additional user information (address, emergency contacts, etc.)
                // This could be done through a separate user profile update service
                
            } catch {
                await MainActor.run {
                    self.isSubmitting = false
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
} 