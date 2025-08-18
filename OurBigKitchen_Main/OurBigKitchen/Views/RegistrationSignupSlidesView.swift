import SwiftUI
import UIKit
import Foundation

struct RegistrationSignupSlidesView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var salesforceManager = SalesforceIntegrationManager()
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Form Data
    @State private var currentStep = 0
    @State private var volunteerType: VolunteerType = .individual
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var dateOfBirth = Date()
    @State private var wwccNumber = ""
    @State private var wwccExpiryDate = Date()
    
    // MARK: - Agreements
    @State private var acceptedTerms = false
    @State private var acceptedHealthProtocols = false
    @State private var acceptedPrivacyPolicy = false
    
    // MARK: - UI States
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSalesforceSync = false
    
    // MARK: - Constants
    private let primaryColor = ThemeManager.Colors.primary
    private let backgroundColor = Color(red: 1.0, green: 0.98, blue: 0.94)
    private let totalSteps = 5
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundColor
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    headerView(geometry: geometry)
                    
                    TabView(selection: $currentStep) {
                        volunteerTypeSelectionView
                            .tag(0)
                        
                        personalInfoView
                            .tag(1)
                        
                        wwccView
                            .tag(2)
                        
                        agreementsView
                            .tag(3)
                        
                        accountCreationView
                            .tag(4)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
                    
                    navigationButtons
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showSalesforceSync) {
            // Success view after Salesforce sync
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text("Account Created Successfully!")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Your account has been created and synced with Salesforce.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
                Button("Continue") {
                    // Navigate to main app
                }
                .buttonStyle(ButtonStyles.springy)
            }
            .padding()
        }
    }
    
    // MARK: - Computed Properties
    
    private var canProceed: Bool {
        switch currentStep {
        case 0:
            return volunteerType != nil
        case 1:
            return !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                   !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                   !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                   !password.isEmpty &&
                   password == confirmPassword &&
                   isValidEmail(email)
        case 2:
            let age = Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
            if age >= 18 {
                return !wwccNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                       wwccExpiryDate > Date()
            }
            return true
        case 3:
            return acceptedTerms && acceptedHealthProtocols && acceptedPrivacyPolicy
        case 4:
            return true // Final step always allows proceeding
        default:
            return false
        }
    }
    
    private var isLastStep: Bool {
        currentStep == totalSteps - 1
    }
    
    private var isFirstStep: Bool {
        currentStep == 0
    }
    
    // MARK: - Header View
    
    private func headerView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                ForEach(0..<totalSteps, id: \.self) { step in
                    Circle()
                        .fill(step <= currentStep ? primaryColor : Color.gray.opacity(0.3))
                        .frame(width: 12, height: 12)
                        .scaleEffect(step == currentStep ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: currentStep)
                }
            }
            .padding(.top, 20)
            
            Text(stepTitle)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(primaryColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var stepTitle: String {
        switch currentStep {
        case 0: return "Volunteer Type"
        case 1: return "Personal Information"
        case 2: return "Working with Children Check"
        case 3: return "Agreements"
        case 4: return "Create Account"
        default: return ""
        }
    }
    
    // MARK: - Navigation Buttons
    
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            if !isFirstStep {
                Button(action: previousStep) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(primaryColor)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(primaryColor, lineWidth: 1)
                    )
                }
            }
            
            Spacer()
            
            Button(action: nextStep) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text(isLastStep ? "Create Account" : "Next")
                        if !isLastStep {
                            Image(systemName: "chevron.right")
                        }
                    }
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(canProceed ? primaryColor : Color.gray.opacity(0.5))
                .cornerRadius(8)
            }
            .disabled(!canProceed || isLoading)
        }
    }
    
    // MARK: - Step Views
    
    private var volunteerTypeSelectionView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("Choose Your Volunteer Type")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(primaryColor)
                    .multilineTextAlignment(.center)
                
                Text("Select how you'd like to volunteer with OurBigKitchen")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            VStack(spacing: 16) {
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
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding(.vertical, 20)
    }
    
    private func volunteerTypeButton(type: VolunteerType, title: String, subtitle: String, icon: String) -> some View {
        Button(action: { volunteerType = type }) {
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
            .padding(20)
            .background(volunteerType == type ? primaryColor : Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(volunteerType == type ? primaryColor : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    private var personalInfoView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Text("Personal Information")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(primaryColor)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 20) {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("First Name")
                            .font(.headline)
                            .foregroundColor(primaryColor)
                        
                        TextField("First Name", text: $firstName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.words)
                            .disableAutocorrection(true)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Last Name")
                            .font(.headline)
                            .foregroundColor(primaryColor)
                        
                        TextField("Last Name", text: $lastName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.words)
                            .disableAutocorrection(true)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email Address")
                        .font(.headline)
                        .foregroundColor(primaryColor)
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(.headline)
                        .foregroundColor(primaryColor)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Confirm Password")
                        .font(.headline)
                        .foregroundColor(primaryColor)
                    
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Date of Birth")
                        .font(.headline)
                        .foregroundColor(primaryColor)
                    
                    DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                        .labelsHidden()
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding(.vertical, 20)
    }
    
    private var wwccView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            let age = Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
            
            if age >= 18 {
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
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("WWCC Number")
                                .font(.headline)
                                .foregroundColor(primaryColor)
                            
                            TextField("WWCC Number", text: $wwccNumber)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Expiry Date")
                                .font(.headline)
                                .foregroundColor(primaryColor)
                            
                            DatePicker("Expiry Date", selection: $wwccExpiryDate, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .labelsHidden()
                        }
                    }
                    .padding(.horizontal, 20)
                }
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
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
                        .padding(.horizontal, 20)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 20)
    }
    
    private var agreementsView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Text("Agreements & Policies")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(primaryColor)
                .multilineTextAlignment(.center)
            
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
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding(.vertical, 20)
    }
    
    private func agreementCheckbox(isChecked: Binding<Bool>, title: String, description: String) -> some View {
        Button(action: { isChecked.wrappedValue.toggle() }) {
            HStack(spacing: 16) {
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
    
    private var accountCreationView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 60))
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
                    .padding(.horizontal, 20)
                
                accountSummaryView
            }
            
            Spacer()
        }
        .padding(.vertical, 20)
    }
    
    private var accountSummaryView: some View {
        VStack(spacing: 16) {
            summaryRow(label: "Volunteer Type", value: volunteerType == .individual ? "Individual" : "Corporate")
            summaryRow(label: "Name", value: "\(firstName) \(lastName)")
            summaryRow(label: "Email", value: email)
            
            let age = Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
            if age >= 18 {
                summaryRow(label: "WWCC Number", value: wwccNumber.isEmpty ? "Not provided" : wwccNumber)
            }
        }
        .padding(20)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }
    
    private func summaryRow(label: String, value: String) -> some View {
        HStack {
            Text("\(label):")
                .fontWeight(.semibold)
                .foregroundColor(primaryColor)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Navigation Methods
    
    private func nextStep() {
        guard currentStep < totalSteps - 1 else {
            Task {
                await createAccount()
            }
            return
        }
        
        withAnimation {
            currentStep += 1
        }
    }
    
    private func previousStep() {
        guard currentStep > 0 else { return }
        
        withAnimation {
            currentStep -= 1
        }
    }
    
    // MARK: - Account Creation
    
    private func createAccount() async {
        isLoading = true
        
        guard validateForm() else {
            isLoading = false
            return
        }
        
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
        
        await syncToSalesforce()
        updateAppStateWithUserProfile()
        isLoading = false
    }
    
    private func validateForm() -> Bool {
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
        guard acceptedTerms && acceptedHealthProtocols && acceptedPrivacyPolicy else {
            showValidationError("Please accept all agreements")
            return false
        }
        
        // Validate WWCC for adults
        let age = Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
        if age >= 18 {
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
    
    private func showValidationError(_ message: String) {
        errorMessage = message
        showError = true
    }
    
    // MARK: - App State Integration
    
    private func updateAppStateWithUserProfile() {
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
    
    // MARK: - Salesforce Integration
    
    private func syncToSalesforce() async {
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
        .store(in: &salesforceManager.cancellables)
    }
    
    // MARK: - Helper Methods
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

// MARK: - Preview

struct RegistrationSignupSlidesView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationSignupSlidesView()
            .environmentObject(AppState())
    }
} 