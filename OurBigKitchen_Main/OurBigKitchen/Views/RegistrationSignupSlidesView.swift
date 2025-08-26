import SwiftUI
import UIKit
import Foundation
import Combine // Added for Combine

// MARK: - Registration Signup Slides View
/// A multi-step registration flow for new volunteers with professional styling and validation
struct RegistrationSignupSlidesView: View {
    
    // MARK: - Dependencies
    @EnvironmentObject private var appState: AppState
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var salesforceManager = SalesforceIntegrationManager()
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Constants
    private enum Constants {
        static let totalSteps = 5
        static let animationDuration: Double = 0.3
        static let stepIndicatorSize: CGFloat = 10
        static let stepIndicatorScale: CGFloat = 1.1
        static let cornerRadius: CGFloat = 16
        static let buttonPadding: CGFloat = 16
        static let spacing: CGFloat = 20
        static let smallSpacing: CGFloat = 12
        static let iconSize: CGFloat = 50
        static let mobileSpacing: CGFloat = 8
        static let mobilePadding: CGFloat = 12
    }
    
    private enum Step: Int, CaseIterable {
        case volunteerType = 0
        case personalInfo = 1
        case wwcc = 2
        case agreements = 3
        case accountCreation = 4
        
        var title: String {
            switch self {
            case .volunteerType: return "Volunteer Type"
            case .personalInfo: return "Personal Information"
            case .wwcc: return "Working with Children Check"
            case .agreements: return "Agreements"
            case .accountCreation: return "Create Account"
            }
        }
    }
    
    // MARK: - Form Data
    @State private var currentStep = Step.volunteerType.rawValue
    @State private var volunteerType: VolunteerType = .individual
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var dateOfBirth = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    @State private var wwccNumber = ""
    @State private var wwccExpiryDate = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
    
    // MARK: - Agreements
    @State private var acceptedTerms = false
    @State private var acceptedHealthProtocols = false
    @State private var acceptedPrivacyPolicy = false
    
    // MARK: - UI States
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSalesforceSync = false
    
    // MARK: - Combine
    @State private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    private var primaryColor: Color { ThemeManager.Colors.primary }
    private var backgroundColor: Color { Color(red: 1.0, green: 0.98, blue: 0.94) }
    private var currentStepEnum: Step { Step(rawValue: currentStep) ?? .volunteerType }
    
    private var canProceed: Bool {
        let result: Bool
        switch currentStep {
        case Step.volunteerType.rawValue:
            result = true
        case Step.personalInfo.rawValue:
            result = isPersonalInfoValid
        case Step.wwcc.rawValue:
            result = isWWCCValid
        case Step.agreements.rawValue:
            result = areAgreementsAccepted
        case Step.accountCreation.rawValue:
            result = true
        default:
            result = false
        }
        

        
        return result
    }
    
    private var isLastStep: Bool { currentStep == Constants.totalSteps - 1 }
    private var isFirstStep: Bool { currentStep == 0 }
    
    // MARK: - Validation Computed Properties
    private var isPersonalInfoValid: Bool {
        let firstNameValid = !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let lastNameValid = !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let emailValid = !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && isValidEmail(email)
        let passwordValid = !password.isEmpty && password.count >= 6
        let passwordMatch = password == confirmPassword
        
        return firstNameValid && lastNameValid && emailValid && passwordValid && passwordMatch
    }
    
    private var isWWCCValid: Bool {
        let age = calculatedAge
        if age >= 18 {
            let wwccValid = !wwccNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                           wwccExpiryDate > Date()
            return wwccValid
        }
        return true
    }
    
    private var areAgreementsAccepted: Bool {
        acceptedTerms && acceptedHealthProtocols && acceptedPrivacyPolicy
    }
    
    private var calculatedAge: Int {
        calculateAge(from: dateOfBirth)
    }
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    headerView(geometry: geometry)
                    
                    stepContent
                        .padding(.top, Constants.mobileSpacing)
                    
                    navigationButtons
                        .padding(.horizontal, Constants.mobilePadding)
                        .padding(.bottom, geometry.safeAreaInsets.bottom + 20)
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showSalesforceSync) {
            successView
        }
        .onAppear {
            authViewModel.setAppState(appState)
        }
    }
}

// MARK: - UI Components
private extension RegistrationSignupSlidesView {
    
    var stepContent: some View {
        Group {
            switch currentStep {
            case Step.volunteerType.rawValue:
                volunteerTypeSelectionView
            case Step.personalInfo.rawValue:
                personalInfoView
            case Step.wwcc.rawValue:
                wwccView
            case Step.agreements.rawValue:
                agreementsView
            case Step.accountCreation.rawValue:
                accountCreationView
            default:
                EmptyView()
            }
        }
        .transition(.asymmetric(
            insertion: .move(edge: .trailing),
            removal: .move(edge: .leading)
        ))
        .animation(.easeInOut(duration: Constants.animationDuration), value: currentStep)

    }
    
    // MARK: - Header View
    func headerView(geometry: GeometryProxy) -> some View {
        VStack(spacing: Constants.smallSpacing) {
            stepIndicatorView
            progressBarView
            stepTitleView
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    var progressBarView: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Progress")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(progressPercentage * 100))%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(primaryColor)
            }
            
            ProgressView(value: progressPercentage)
                .progressViewStyle(LinearProgressViewStyle(tint: primaryColor))
                .scaleEffect(x: 1, y: 2, anchor: .center)
        }
        .padding(.horizontal, Constants.buttonPadding)
    }
    
    private var progressPercentage: Double {
        min(Double(currentStep + 1) / Double(Constants.totalSteps), 1.0)
    }
    
    var stepIndicatorView: some View {
        HStack(spacing: 8) {
            ForEach(0..<Constants.totalSteps, id: \.self) { step in
                Button(action: {
                    // Only allow navigation to completed steps or current step
                    if step <= currentStep {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = step
                        }
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(stepIndicatorColor(for: step))
                            .frame(width: Constants.stepIndicatorSize, height: Constants.stepIndicatorSize)
                        
                        if step < currentStep {
                            // Completed step
                            Image(systemName: "checkmark")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.white)
                        } else if step == currentStep {
                            // Current step
                            Circle()
                                .stroke(primaryColor, lineWidth: 2)
                                .frame(width: Constants.stepIndicatorSize + 4, height: Constants.stepIndicatorSize + 4)
                        }
                    }
                }
                .scaleEffect(step == currentStep ? Constants.stepIndicatorScale : 1.0)
                .animation(.easeInOut(duration: 0.2), value: currentStep)
                .disabled(step > currentStep) // Can't jump ahead
            }
        }
        .padding(.top, 20)
    }
    
    private func stepIndicatorColor(for step: Int) -> Color {
        if step < currentStep {
            return .green // Completed steps
        } else if step == currentStep {
            return primaryColor // Current step
        } else {
            return Color.gray.opacity(0.3) // Future steps
        }
    }
    
    var stepTitleView: some View {
        Text(currentStepEnum.title)
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundColor(primaryColor)
            .multilineTextAlignment(.center)
            .padding(.horizontal, Constants.buttonPadding)
    }
    
    // MARK: - Navigation Buttons
    var navigationButtons: some View {
        VStack(spacing: Constants.mobileSpacing) {
            // Skip for Demo button - available on every section
            HStack {
                Spacer()
                Button("Skip for Demo") {
                    withAnimation {
                        if currentStep < Constants.totalSteps {
                            currentStep += 1
                        }
                    }
                }
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .cornerRadius(12)
            }
            .padding(.horizontal, Constants.mobilePadding)
            
            // Main navigation buttons
            HStack(spacing: Constants.mobileSpacing) {
                if !isFirstStep {
                    backButton
                }
                
                Spacer()
                
                nextButton
            }
            .padding(.horizontal, Constants.mobilePadding)
        }
    }
    
    var backButton: some View {
        Button(action: previousStep) {
            HStack {
                Image(systemName: "chevron.left")
                Text("Back")
            }
            .font(.subheadline)
            .foregroundColor(primaryColor)
            .padding(.horizontal, Constants.mobilePadding)
            .padding(.vertical, 8)
            .background(Color.white)
            .cornerRadius(Constants.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .stroke(primaryColor, lineWidth: 1)
            )
        }
    }
    
    var nextButton: some View {
        Button(action: nextStep) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Text(isLastStep ? "Create Account" : "Next")
                        .font(.subheadline)
                    if !isLastStep {
                        Image(systemName: "chevron.right")
                    }
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, Constants.mobilePadding)
            .padding(.vertical, 8)
            .background(canProceed ? primaryColor : Color.gray.opacity(0.5))
            .cornerRadius(Constants.cornerRadius)
        }
        .disabled(!canProceed || isLoading)
        .overlay(
            Group {
                if !canProceed && !isLoading {
                    VStack {
                        Spacer()
                        Text(validationMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.top, 4)
                    }
                }
            }
        )
    }
    
    private var validationMessage: String {
        switch currentStep {
        case Step.personalInfo.rawValue:
            if firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return "First name is required"
            } else if lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return "Last name is required"
            } else if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return "Email is required"
            } else if !isValidEmail(email) {
                return "Please enter a valid email"
            } else if password.isEmpty {
                return "Password is required"
            } else if password.count < 6 {
                return "Password must be at least 6 characters"
            } else if password != confirmPassword {
                return "Passwords do not match"
            }
            return ""
        case Step.wwcc.rawValue:
            if calculatedAge >= 18 {
                if wwccNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    return "WWCC number is required for volunteers 18+"
                } else if wwccExpiryDate <= Date() {
                    return "WWCC expiry date must be in the future"
                }
            }
            return ""
        case Step.agreements.rawValue:
            if !acceptedTerms {
                return "Please accept Terms of Service"
            } else if !acceptedHealthProtocols {
                return "Please accept Health & Safety Protocols"
            } else if !acceptedPrivacyPolicy {
                return "Please accept Privacy Policy"
            }
            return ""
        default:
            return ""
        }
    }
}

// MARK: - Step Views
private extension RegistrationSignupSlidesView {
    
    var volunteerTypeSelectionView: some View {
        VStack(spacing: Constants.spacing) {
            Spacer()
            
            headerSection(
                title: "Choose Your Volunteer Type",
                subtitle: "Select how you'd like to volunteer with OurBigKitchen"
            )
            
            VStack(spacing: Constants.mobileSpacing) {
                volunteerTypeButton(
                    type: .individual,
                    title: "Individual Volunteer",
                    subtitle: "Volunteer on your own schedule",
                    icon: "person.fill"
                )
                
                volunteerTypeButton(
                    type: .corporate,
                    title: "Corporate Volunteer",
                    subtitle: "Organize team volunteer events",
                    icon: "building.2.fill"
                )
            }
            .padding(.horizontal, Constants.mobilePadding)
            
            Spacer()
        }
        .padding(.vertical, Constants.mobilePadding)
    }
    
    func volunteerTypeButton(type: VolunteerType, title: String, subtitle: String, icon: String) -> some View {
        Button(action: { 
            volunteerType = type
        }) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(volunteerType == type ? .white : primaryColor)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(volunteerType == type ? .white : primaryColor)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(volunteerType == type ? .white.opacity(0.8) : .secondary)
                }
                
                Spacer()
                
                if volunteerType == type {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.title2)
                }
            }
            .padding(Constants.mobilePadding)
            .background(volunteerType == type ? primaryColor : Color.white)
            .cornerRadius(Constants.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .stroke(volunteerType == type ? primaryColor : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    var personalInfoView: some View {
        ScrollView {
            VStack(spacing: Constants.spacing) {
                Text("Personal Information")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(primaryColor)
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)
                
                // Mandatory fields note
                HStack {
                    Text("*")
                        .foregroundColor(.red)
                        .fontWeight(.bold)
                    Text("indicates required fields")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 16)
                
                VStack(spacing: Constants.spacing) {
                    nameFieldsSection
                    emailFieldSection
                    passwordFieldsSection
                    dateOfBirthSection
                }
                .padding(.horizontal, Constants.buttonPadding)
                
                // Add bottom padding for scrolling
                Spacer(minLength: 100)
            }
        }
        .padding(.vertical, Constants.buttonPadding)
    }
    
    var nameFieldsSection: some View {
        VStack(spacing: Constants.spacing) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("First Name")
                        .font(.headline)
                        .foregroundColor(primaryColor)
                    Text("*")
                        .foregroundColor(.red)
                        .fontWeight(.bold)
                    
                    if !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }
                
                TextField("First Name", text: $firstName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.words)
                    .disableAutocorrection(true)
                    .frame(height: 44)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray.opacity(0.3) : .green, lineWidth: 1)
                    )
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Last Name")
                        .font(.headline)
                        .foregroundColor(primaryColor)
                    Text("*")
                        .foregroundColor(.red)
                        .fontWeight(.bold)
                    
                    if !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }
                
                TextField("Last Name", text: $lastName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.words)
                    .disableAutocorrection(true)
                    .frame(height: 44)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray.opacity(0.3) : .green, lineWidth: 1)
                    )
            }
        }
    }
    
    var emailFieldSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Email Address")
                    .font(.headline)
                    .foregroundColor(primaryColor)
                Text("*")
                    .foregroundColor(.red)
                    .fontWeight(.bold)
                
                if !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && isValidEmail(email) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                } else if !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isValidEmail(email) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .frame(height: 44)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(emailValidationColor, lineWidth: 1)
                )
        }
    }
    
    private var emailValidationColor: Color {
        if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return Color.gray.opacity(0.3)
        } else if isValidEmail(email) {
            return .green
        } else {
            return .red
        }
    }
    
    var passwordFieldsSection: some View {
        VStack(spacing: Constants.spacing) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Password")
                        .font(.headline)
                        .foregroundColor(primaryColor)
                    Text("*")
                        .foregroundColor(.red)
                        .fontWeight(.bold)
                    
                    if !password.isEmpty && password.count >= 6 {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    } else if !password.isEmpty && password.count < 6 {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(passwordValidationColor, lineWidth: 1)
                    )
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Confirm Password")
                        .font(.headline)
                        .foregroundColor(primaryColor)
                    Text("*")
                        .foregroundColor(.red)
                        .fontWeight(.bold)
                    
                    if !confirmPassword.isEmpty && password == confirmPassword {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    } else if !confirmPassword.isEmpty && password != confirmPassword {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(confirmPasswordValidationColor, lineWidth: 1)
                    )
            }
        }
    }
    
    private var passwordValidationColor: Color {
        if password.isEmpty {
            return Color.gray.opacity(0.3)
        } else if password.count >= 6 {
            return .green
        } else {
            return .red
        }
    }
    
    private var confirmPasswordValidationColor: Color {
        if confirmPassword.isEmpty {
            return Color.gray.opacity(0.3)
        } else if password == confirmPassword {
            return .green
        } else {
            return .red
        }
    }
    
    var dateOfBirthSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Date of Birth")
                    .font(.headline)
                    .foregroundColor(primaryColor)
                Text("*")
                    .foregroundColor(.red)
                    .fontWeight(.bold)
            }
            
            DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                .datePickerStyle(CompactDatePickerStyle())
                .labelsHidden()
        }
    }
    
    var wwccView: some View {
        ScrollView {
            VStack(spacing: Constants.spacing) {
                if calculatedAge >= 18 {
                    wwccRequiredView
                } else {
                    wwccNotRequiredView
                }
                
                // Add bottom padding for scrolling
                Spacer(minLength: 100)
            }
        }
        .padding(.vertical, Constants.buttonPadding)
    }
    
    var wwccRequiredView: some View {
        VStack(spacing: 20) {
            Text("Working with Children Check")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(primaryColor)
                .multilineTextAlignment(.center)
            
            Text("As you are 18 or older, you need a valid Working with Children Check to volunteer with food preparation.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Constants.buttonPadding)
            
            VStack(spacing: Constants.spacing) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("WWCC Number")
                            .font(.headline)
                            .foregroundColor(primaryColor)
                        Text("*")
                            .foregroundColor(.red)
                            .fontWeight(.bold)
                    }
                    
                    TextField("WWCC Number", text: $wwccNumber)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Expiry Date")
                            .font(.headline)
                            .foregroundColor(primaryColor)
                        Text("*")
                            .foregroundColor(.red)
                            .fontWeight(.bold)
                    }
                    
                    DatePicker("Expiry Date", selection: $wwccExpiryDate, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                        .labelsHidden()
                }
            }
            .padding(.horizontal, Constants.buttonPadding)
        }
    }
    
    var wwccNotRequiredView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: Constants.iconSize))
                .foregroundColor(.green)
            
            Text("No WWCC Required")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(primaryColor)
                .multilineTextAlignment(.center)
            
            Text("You are under 18, so no Working with Children Check is required.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Constants.buttonPadding)
        }
    }
    
    var agreementsView: some View {
        ScrollView {
            VStack(spacing: Constants.spacing) {
                Text("Agreements & Policies")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(primaryColor)
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)
                
                VStack(spacing: 20) {
                    agreementCheckbox(
                        isChecked: $acceptedTerms,
                        title: "Terms of Service",
                        description: "Read and agree to our terms and conditions"
                    )
                    
                    agreementCheckbox(
                        isChecked: $acceptedHealthProtocols,
                        title: "Health & Safety Protocols",
                        description: "Agree to follow food safety and health guidelines"
                    )
                    
                    agreementCheckbox(
                        isChecked: $acceptedPrivacyPolicy,
                        title: "Privacy Policy",
                        description: "Agree to how we collect and use your data"
                    )
                }
                .padding(.horizontal, Constants.buttonPadding)
                
                // Add bottom padding for scrolling
                Spacer(minLength: 100)
            }
        }
        .padding(.vertical, Constants.buttonPadding)
    }
    
    func agreementCheckbox(isChecked: Binding<Bool>, title: String, description: String) -> some View {
        Button(action: { isChecked.wrappedValue.toggle() }) {
            HStack(spacing: Constants.smallSpacing) {
                Image(systemName: isChecked.wrappedValue ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isChecked.wrappedValue ? primaryColor : .gray)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("I accept the \(title)")
                        .font(.headline)
                        .foregroundColor(primaryColor)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
    }
    
    var accountCreationView: some View {
        VStack(spacing: Constants.spacing) {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: Constants.iconSize))
                    .foregroundColor(primaryColor)
                
                Text("Ready to Create Your Account?")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(primaryColor)
                    .multilineTextAlignment(.center)
                
                Text("Review your information and create your volunteer account to get started with OurBigKitchen.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Constants.buttonPadding)
                
                accountSummaryView
            }
            
            Spacer()
            
            // Skip for Demo button
            Button(action: {
                // Skip to success view
                showSalesforceSync = true
            }) {
                Text("Skip for Demo")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .cornerRadius(12)
            }
            .padding(.bottom, 20)
        }
        .padding(.vertical, Constants.buttonPadding)
    }
    
    var accountSummaryView: some View {
        VStack(spacing: Constants.smallSpacing) {
            summaryRow(label: "Volunteer Type", value: volunteerType == .individual ? "Individual" : "Corporate")
            summaryRow(label: "Name", value: "\(firstName) \(lastName)")
            summaryRow(label: "Email", value: email)
            
            if calculatedAge >= 18 {
                summaryRow(label: "WWCC Number", value: wwccNumber.isEmpty ? "Not provided" : wwccNumber)
            }
        }
        .padding(Constants.buttonPadding)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(Constants.cornerRadius)
        .padding(.horizontal, Constants.buttonPadding)
    }
    
    func summaryRow(label: String, value: String) -> some View {
        HStack {
            Text("\(label):")
                .fontWeight(.semibold)
                .foregroundColor(primaryColor)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
    
    var successView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: Constants.iconSize))
                .foregroundColor(.green)
            
            Text("Account Created Successfully!")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Your account has been created and synced with Salesforce.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button("Continue to App") {
                // Dismiss the sheet and view
                showSalesforceSync = false
                dismiss()
            }
            .buttonStyle(ButtonStyles.springy)
        }
        .padding()
    }
    
    func headerSection(title: String, subtitle: String) -> some View {
        VStack(spacing: Constants.smallSpacing) {
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(primaryColor)
                .multilineTextAlignment(.center)
            
            Text(subtitle)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Constants.buttonPadding)
        }
    }
}

// MARK: - Navigation Methods
private extension RegistrationSignupSlidesView {
    
    func nextStep() {
        guard currentStep < Constants.totalSteps - 1 else {
            Task {
                await createAccount()
            }
            return
        }
        
        withAnimation {
            currentStep += 1
        }
    }
    
    func previousStep() {
        guard currentStep > 0 else { return }
        
        withAnimation {
            currentStep -= 1
        }
    }
}

// MARK: - Account Creation
private extension RegistrationSignupSlidesView {
    
    func createAccount() async {
        isLoading = true
        
        guard validateForm() else {
            isLoading = false
            return
        }
        
        // Attempt to create account
        await authViewModel.signUp(
            firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password,
            volunteerType: volunteerType,
            dateOfBirth: dateOfBirth,
            wwccNumber: wwccNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : wwccNumber.trimmingCharacters(in: .whitespacesAndNewlines),
            wwccExpiryDate: wwccNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : wwccExpiryDate
        )
        
        // Try to sync to Salesforce, but don't block on failure
        await syncToSalesforce()
        
        // Show success
        showSalesforceSync = true
        
        isLoading = false
    }
    
    func validateForm() -> Bool {
        // Validate required fields
        guard !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !password.isEmpty else {
            showValidationError("Please fill in all required fields")
            return false
        }
        
        // Validate password match
        guard password == confirmPassword else {
            showValidationError("Passwords do not match")
            return false
        }
        
        // Validate email format
        guard isValidEmail(email) else {
            showValidationError("Please enter a valid email address")
            return false
        }
        
        // Validate agreements
        guard areAgreementsAccepted else {
            showValidationError("Please accept all agreements")
            return false
        }
        
        // Validate WWCC for adults
        if calculatedAge >= 18 {
            guard !wwccNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                showValidationError("WWCC number is required for volunteers 18 and older")
                return false
            }
            
            guard wwccExpiryDate > Date() else {
                showValidationError("WWCC expiry date must be in the future")
                return false
            }
        }
        
        return true
    }
    
    func showValidationError(_ message: String) {
        errorMessage = message
        showError = true
    }
}

// MARK: - App State Integration
private extension RegistrationSignupSlidesView {
    
    func updateAppStateWithUserProfile() {
        let userProfile = AppModels.User(
            id: UUID().uuidString,
            firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            role: volunteerType == .individual ? .volunteer : .corporate,
            preferences: AppModels.UserPreferences(),
            achievements: [],
            stats: AppModels.UserStats(),
            hasFoodSafetyRegistration: false,
            dob: dateOfBirth,
            wwcNumber: wwccNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : wwccNumber.trimmingCharacters(in: .whitespacesAndNewlines),
            wwcExpiry: wwccNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : wwccExpiryDate,
            companyName: volunteerType == .corporate ? "Corporate Group" : nil
        )
        
        appState.userProfile = userProfile
    }
}

// MARK: - Salesforce Integration
private extension RegistrationSignupSlidesView {
    
    func syncToSalesforce() async {
        let wwccExpiry = wwccNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : wwccExpiryDate
        
        salesforceManager.syncUserRegistration(
            firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            volunteerType: volunteerType,
            dateOfBirth: dateOfBirth,
            wwccNumber: wwccNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : wwccNumber.trimmingCharacters(in: .whitespacesAndNewlines),
            wwccExpiryDate: wwccExpiry
        )
        .sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Salesforce sync failed: \(error.localizedDescription)")
                }
            },
            receiveValue: { salesforceId in
                print("Successfully synced to Salesforce with ID: \(salesforceId)")
                DispatchQueue.main.async {
                    self.showSalesforceSync = true
                }
            }
        )
        .store(in: &cancellables)
    }
}

// MARK: - Helper Methods
private extension RegistrationSignupSlidesView {
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func calculateAge(from dateOfBirth: Date) -> Int {
        let calendar = Calendar.current
        let now = Date()
        
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: now)
        let age = ageComponents.year ?? 0
        
        // Ensure age is reasonable (not negative or too high)
        return max(0, min(age, 120))
    }
}

// MARK: - Preview
struct RegistrationSignupSlidesView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationSignupSlidesView()
            .environmentObject(AppState())
    }
} 

// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(ThemeManager.Colors.primary)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(ThemeManager.Colors.primary)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(ThemeManager.Colors.primary, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
} 