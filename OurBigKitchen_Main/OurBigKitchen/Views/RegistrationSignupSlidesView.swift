import SwiftUI
import UIKit
import Foundation

struct RegistrationSignupSlidesView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var salesforceManager = SalesforceIntegrationManager()
    @Environment(\.dismiss) private var dismiss
    
    // Form data
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
    
    // Agreements
    @State private var acceptedTerms = false
    @State private var acceptedHealthProtocols = false
    @State private var acceptedPrivacyPolicy = false
    
    // UI states
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var animateIn = false
    @State private var showSalesforceSync = false
    
    // Colors
    private let primaryColor = ThemeManager.Colors.primary
    private let accentColor = ThemeManager.Colors.accent
    private let backgroundColor = Color(red: 1.0, green: 0.98, blue: 0.94)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                backgroundColor
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Header with progress
                    headerView(geometry: geometry)
                    
                    // Content area
                    TabView(selection: $currentStep) {
                        // Step 1: Volunteer Type Selection
                        volunteerTypeSelectionView
                            .tag(0)
                        
                        // Step 2: Personal Information
                        personalInfoView
                            .tag(1)
                        
                        // Step 3: WWCC (if 18+)
                        wwccView
                            .tag(2)
                        
                        // Step 4: Agreements
                        agreementsView
                            .tag(3)
                        
                        // Step 5: Account Creation
                        accountCreationView
                            .tag(4)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
                    
                    // Navigation buttons
                    navigationButtons
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                animateIn = true
            }
        }
        .onReceive(authViewModel.$isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                // User is authenticated, now they need to choose Individual/Corporate
                appState.isAuthenticated = true
                appState.needsToChooseVolunteerType = true
                dismiss()
            }
        }
        .onReceive(authViewModel.$errorMessage) { errorMessage in
            if !errorMessage.isEmpty {
                self.errorMessage = errorMessage
                self.showError = true
            }
        }
        .onReceive(authViewModel.$isLoading) { isLoading in
            self.isLoading = isLoading
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .alert("Salesforce Sync", isPresented: $showSalesforceSync) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your registration has been synced to Salesforce CRM. You can now be tracked and managed through our volunteer management system.")
        }
    }
    
    // MARK: - Header View
    
    private func headerView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 15) {
            // Progress bar
            HStack(spacing: 0) {
                ForEach(0..<5) { index in
                    Rectangle()
                        .fill(index <= currentStep ? primaryColor : Color.gray.opacity(0.3))
                        .frame(height: 4)
                        .animation(.easeInOut(duration: 0.3), value: currentStep)
                }
            }
            .padding(.horizontal, 20)
            
            // Step indicator
            Text("Step \(currentStep + 1) of 5")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Step title
            Text(stepTitle)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(primaryColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding(.top, 20)
        .background(Color.white.opacity(0.9))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var stepTitle: String {
        switch currentStep {
        case 0: return "Choose Your Path"
        case 1: return "Personal Information"
        case 2: return "Background Check"
        case 3: return "Agreements"
        case 4: return "Create Account"
        default: return ""
        }
    }
    
    // MARK: - Step 1: Volunteer Type Selection
    
    private var volunteerTypeSelectionView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Icon and title
            VStack(spacing: 20) {
                Image(systemName: "person.3.fill")
                    .font(.system(size: 80))
                    .foregroundColor(primaryColor)
                    .scaleEffect(animateIn ? 1.0 : 0.8)
                    .opacity(animateIn ? 1.0 : 0.0)
                
                Text("How will you volunteer?")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            // Volunteer type options
            VStack(spacing: 20) {
                volunteerTypeButton(
                    type: .individual,
                    title: "Individual Volunteer",
                    subtitle: "Volunteer on your own",
                    icon: "person.fill",
                    color: Color(red: 0.3, green: 0.7, blue: 0.3)
                )
                
                volunteerTypeButton(
                    type: .corporate,
                    title: "Corporate/Group",
                    subtitle: "Volunteer with your organization",
                    icon: "building.2.fill",
                    color: Color(red: 0.93, green: 0.46, blue: 0.12)
                )
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding(.vertical, 20)
    }
    
    private func volunteerTypeButton(type: VolunteerType, title: String, subtitle: String, icon: String, color: Color) -> some View {
        Button(action: {
            volunteerType = type
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                currentStep = 1
            }
        }) {
            HStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(color)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
            )
        }
        .buttonStyle(ButtonStyles.scale)
    }
    
    // MARK: - Step 2: Personal Information
    
    private var personalInfoView: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Icon and title
                VStack(spacing: 15) {
                    Image(systemName: "person.text.rectangle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(primaryColor)
                    
                    Text("Tell us about yourself")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Form fields
                VStack(spacing: 20) {
                    ModernTextField(
                        placeholder: "First Name",
                        text: $firstName,
                        icon: "person.fill"
                    )
                    
                    ModernTextField(
                        placeholder: "Last Name",
                        text: $lastName,
                        icon: "person.fill"
                    )
                    
                    ModernTextField(
                        placeholder: "Email",
                        text: $email,
                        icon: "envelope.fill",
                        keyboardType: .emailAddress
                    )
                    
                    ModernSecureField(
                        placeholder: "Password",
                        text: $password,
                        icon: "lock.fill"
                    )
                    
                    ModernSecureField(
                        placeholder: "Confirm Password",
                        text: $confirmPassword,
                        icon: "lock.fill"
                    )
                    
                    // Date of Birth
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Date of Birth")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        DatePicker("", selection: $dateOfBirth, displayedComponents: .date)
                            .datePickerStyle(WheelDatePickerStyle())
                            .labelsHidden()
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            )
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer(minLength: 100)
            }
        }
    }
    
    // MARK: - Step 3: WWCC (if 18+)
    
    private var wwccView: some View {
        let isAdult = Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0 >= 18
        
        return ScrollView {
            VStack(spacing: 25) {
                // Icon and title
                VStack(spacing: 15) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 60))
                        .foregroundColor(primaryColor)
                    
                    Text("Background Check")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                if isAdult {
                    // WWCC required for adults
                    VStack(spacing: 20) {
                        Text("Working with Children Check (WWCC)")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("As you are 18 or older, you need a valid WWCC to volunteer with children.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 16) {
                            ModernTextField(
                                placeholder: "WWCC Number",
                                text: $wwccNumber,
                                icon: "number.circle.fill"
                            )
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("WWCC Expiry Date")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                
                                DatePicker("", selection: $wwccExpiryDate, displayedComponents: .date)
                                    .datePickerStyle(WheelDatePickerStyle())
                                    .labelsHidden()
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color(.systemBackground))
                                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                    )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Renewal reminder info
                        VStack(spacing: 10) {
                            Text("Renewal Reminders")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Text("We'll send you reminders at 3 months, 2 months, 1 month, 2 weeks, 1 week, and 1 day before expiry.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        .padding(.top, 10)
                    }
                } else {
                    // Under 18 - no WWCC required
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("No WWCC Required")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("You are under 18, so no Working with Children Check is required.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                }
                
                Spacer(minLength: 100)
            }
        }
    }
    
    // MARK: - Step 4: Agreements
    
    private var agreementsView: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Icon and title
                VStack(spacing: 15) {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 60))
                        .foregroundColor(primaryColor)
                    
                    Text("Terms & Agreements")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Agreement checkboxes
                VStack(spacing: 20) {
                    agreementCheckbox(
                        isChecked: $acceptedTerms,
                        title: "Terms of Service",
                        description: "I agree to the terms and conditions of volunteering"
                    )
                    
                    agreementCheckbox(
                        isChecked: $acceptedHealthProtocols,
                        title: "Health & Safety Protocols",
                        description: "I agree to follow all health and safety guidelines"
                    )
                    
                    agreementCheckbox(
                        isChecked: $acceptedPrivacyPolicy,
                        title: "Privacy Policy",
                        description: "I agree to the privacy policy and data handling"
                    )
                }
                .padding(.horizontal, 20)
                
                Spacer(minLength: 100)
            }
        }
    }
    
    private func agreementCheckbox(isChecked: Binding<Bool>, title: String, description: String) -> some View {
        Button(action: {
            isChecked.wrappedValue.toggle()
        }) {
            HStack(spacing: 15) {
                Image(systemName: isChecked.wrappedValue ? "checkmark.square.fill" : "square")
                    .font(.system(size: 24))
                    .foregroundColor(isChecked.wrappedValue ? primaryColor : .gray)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            )
        }
        .buttonStyle(ButtonStyles.scale)
    }
    
    // MARK: - Step 5: Account Creation
    
    private var accountCreationView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Icon and title
            VStack(spacing: 20) {
                Image(systemName: "person.badge.plus.fill")
                    .font(.system(size: 80))
                    .foregroundColor(primaryColor)
                
                Text("Create Your Account")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                Text("You're almost ready to start making a difference!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            // Account summary
            VStack(spacing: 15) {
                accountSummaryRow(icon: "person.fill", text: "\(firstName) \(lastName)")
                accountSummaryRow(icon: "envelope.fill", text: email)
                accountSummaryRow(icon: "person.3.fill", text: volunteerType == .individual ? "Individual Volunteer" : "Corporate/Group")
                
                if Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0 >= 18 {
                    accountSummaryRow(icon: "checkmark.shield.fill", text: "WWCC: \(wwccNumber)")
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
            )
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
    
    private func accountSummaryRow(icon: String, text: String) -> some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(primaryColor)
                .frame(width: 30)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
    
    // MARK: - Navigation Buttons
    
    private var navigationButtons: some View {
        HStack(spacing: 15) {
            // Back button
            if currentStep > 0 {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        currentStep -= 1
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                    }
                    .font(.headline)
                    .foregroundColor(primaryColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(primaryColor, lineWidth: 2)
                    )
                }
                .buttonStyle(ButtonStyles.scale)
            }
            
            // Next/Create Account button
            Button(action: {
                if currentStep < 4 {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        currentStep += 1
                    }
                } else {
                    // Create account
                    createAccount()
                }
            }) {
                HStack(spacing: 8) {
                    if currentStep == 4 {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.2)
                        } else {
                            Text("Create Account")
                        }
                    } else {
                        Text("Next")
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [primaryColor, accentColor]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(25)
                .shadow(color: primaryColor.opacity(0.4), radius: 8, x: 0, y: 5)
            }
            .disabled(isLoading || !canProceed)
            .buttonStyle(ButtonStyles.scale)
        }
    }
    
    private var canProceed: Bool {
        switch currentStep {
        case 0: return true // Volunteer type always selected
        case 1: return !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty && !password.isEmpty && password == confirmPassword
        case 2: return true // WWCC is optional for under 18
        case 3: return acceptedTerms && acceptedHealthProtocols && acceptedPrivacyPolicy
        case 4: return true // Ready to create account
        default: return false
        }
    }
    
    // MARK: - Account Creation
    
    private func createAccount() {
        // Validate all required fields
        guard !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all required fields"
            showError = true
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            showError = true
            return
        }
        
        guard acceptedTerms && acceptedHealthProtocols && acceptedPrivacyPolicy else {
            errorMessage = "Please accept all agreements"
            showError = true
            return
        }
        
        // Create account using AuthViewModel
        authViewModel.signUp(
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password,
            volunteerType: volunteerType,
            dateOfBirth: dateOfBirth,
            wwccNumber: wwccNumber.isEmpty ? nil : wwccNumber,
            wwccExpiryDate: wwccNumber.isEmpty ? nil : wwccExpiryDate
        )
        
        // Sync to Salesforce CRM
        syncToSalesforce()
    }
    
    // MARK: - Salesforce Integration
    
    private func syncToSalesforce() {
        let wwccExpiry = wwccNumber.isEmpty ? nil : wwccExpiryDate
        
        salesforceManager.syncUserRegistration(
            firstName: firstName,
            lastName: lastName,
            email: email,
            volunteerType: volunteerType,
            dateOfBirth: dateOfBirth,
            wwccNumber: wwccNumber.isEmpty ? nil : wwccNumber,
            wwccExpiryDate: wwccExpiry
        )
        .sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Salesforce sync failed: \(error.localizedDescription)")
                    // Don't show error to user as this is background sync
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
}

struct RegistrationSignupSlidesView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationSignupSlidesView()
            .environmentObject(AppState())
    }
} 