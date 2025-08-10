import Foundation
import Combine
import SwiftUI

class RegistrationFlowViewModel: ObservableObject {
    @Published var currentStep: Int = 0
    let totalSteps = 7
    
    enum UserType: String, CaseIterable, Identifiable {
        case individual = "Individual Volunteer"
        case corporate = "Corporate/Group"
        var id: String { self.rawValue }
    }
    @Published var selectedUserType: UserType? = nil
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var mobile: String = ""
    @Published var dob: Date = Date()
    @Published var address: String = ""
    @Published var emergencyName: String = ""
    @Published var emergencyPhone: String = ""
    @Published var companyName: String = ""
    @Published var wwcNumber: String = ""
    @Published var wwcExpiry: Date = Date()
    @Published var isDukeOfEd: Bool = false
    @Published var referralSource: String = ""
    @Published var hasAcceptedFoodSafety: Bool = false
    @Published var hasAcceptedTerms: Bool = false
    @Published var isSubmitting: Bool = false
    @Published var showSuccessMessage: Bool = false
    @Published var errorMessage: String? = nil
    
    private let registrationService: RegistrationService
    private var cancellables = Set<AnyCancellable>()
    
    init(registrationService: RegistrationService = RegistrationService()) {
        self.registrationService = registrationService
    }
    
    var isOver18: Bool {
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: dob, to: now)
        return (ageComponents.year ?? 0) >= 18
    }
    var isPersonalDetailsValid: Bool {
        !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty && !mobile.isEmpty && !address.isEmpty && !emergencyName.isEmpty && !emergencyPhone.isEmpty && (selectedUserType != .corporate || !companyName.isEmpty)
    }
    var isWWCCValid: Bool {
        if isOver18 {
            return !wwcNumber.isEmpty && wwcExpiry > Date()
        }
        return true
    }
    var isAdditionalInfoValid: Bool {
        !referralSource.isEmpty
    }
    var isFoodSafetyValid: Bool {
        hasAcceptedFoodSafety
    }
    var isTermsValid: Bool {
        hasAcceptedTerms
    }
    var isReviewValid: Bool {
        isPersonalDetailsValid && isWWCCValid && isAdditionalInfoValid && isFoodSafetyValid && isTermsValid
    }
    
    func submitRegistration() {
        isSubmitting = true
        errorMessage = nil
        let registrationData = RegistrationData(
            userType: selectedUserType?.rawValue ?? "",
            firstName: firstName,
            lastName: lastName,
            email: email,
            mobile: mobile,
            dateOfBirth: dob,
            address: address,
            emergencyContactName: emergencyName,
            emergencyContactPhone: emergencyPhone,
            companyName: selectedUserType == .corporate ? companyName : nil,
            wwccNumber: isOver18 ? wwcNumber : nil,
            wwccExpiry: isOver18 ? wwcExpiry : nil,
            isDukeOfEd: isDukeOfEd,
            referralSource: referralSource,
            hasAcceptedFoodSafety: hasAcceptedFoodSafety,
            hasAcceptedTerms: hasAcceptedTerms
        )
        registrationService.submitRegistration(registrationData)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isSubmitting = false
                if case .failure(let error) = completion {
                    switch error {
                    case .invalidData:
                        self?.errorMessage = "Please check your information and try again."
                    case .networkError:
                        self?.errorMessage = "Network error. Please check your connection and try again."
                    case .serverError(let message):
                        self?.errorMessage = "Server error: \(message)"
                    case .unknown:
                        self?.errorMessage = "An unexpected error occurred. Please try again."
                    }
                }
            } receiveValue: { [weak self] _ in
                self?.showSuccessMessage = true
            }
            .store(in: &cancellables)
    }
} 