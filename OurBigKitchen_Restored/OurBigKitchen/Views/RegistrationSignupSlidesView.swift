import SwiftUI

struct RegistrationSignupSlidesView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = RegistrationFlowViewModel()
    @State private var currentPage = 0
    @State private var hasScrolledToBottom = false
    @State private var selectedType: VolunteerType?
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var dob = Date()
    @State private var wwcNumber = ""
    @State private var wwcExpiry = Date()
    @State private var hasAcceptedTerms = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    let onComplete: (VolunteerType) -> Void
    
    enum VolunteerType {
        case individual
        case corporate
    }
    
    // Colors
    private let primaryColor = Color("OBKPrimary")
    private let secondaryColor = Color("OBKSecondary")
    
    private var isOver18: Bool {
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: dob, to: now)
        return (ageComponents.year ?? 0) >= 18
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Progress indicator
                HStack(spacing: 4) {
                    ForEach(0..<4, id: \.self) { step in
                        Capsule()
                            .fill(step <= currentPage ? primaryColor : Color.gray.opacity(0.3))
                            .frame(height: 6)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.top, 24)
                .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 20) {
                        switch currentPage {
                        case 0:
                            // Volunteer Type Selection
                            VStack(spacing: 24) {
                                Text("Choose Volunteer Type")
                                    .font(.title2.bold())
                                    .padding(.bottom, 8)
                                
                                VStack(spacing: 16) {
                                    Button(action: { selectedType = .individual }) {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text("Individual Volunteer")
                                                    .font(.headline)
                                                Text("Join as an individual to help in the kitchen")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                            Spacer()
                                            Image(systemName: selectedType == .individual ? "checkmark.circle.fill" : "circle")
                                        }
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                    }
                                    
                                    Button(action: { selectedType = .corporate }) {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text("Corporate Group")
                                                    .font(.headline)
                                                Text("Register your organization for group volunteering")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                            Spacer()
                                            Image(systemName: selectedType == .corporate ? "checkmark.circle.fill" : "circle")
                                        }
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                        case 1:
                            // Personal Details
                            VStack(spacing: 24) {
                                Text("Personal Details")
                                    .font(.title2.bold())
                                    .padding(.bottom, 8)
                                
                                VStack(spacing: 16) {
                                    TextField("First Name", text: $firstName)
                                        .textContentType(.givenName)
                                        .textFieldStyle(.roundedBorder)
                                        .padding(.horizontal)
                                    
                                    TextField("Last Name", text: $lastName)
                                        .textContentType(.familyName)
                                        .textFieldStyle(.roundedBorder)
                                        .padding(.horizontal)
                                    
                                    TextField("Email", text: $email)
                                        .textContentType(.emailAddress)
                                        .keyboardType(.emailAddress)
                                        .textFieldStyle(.roundedBorder)
                                        .padding(.horizontal)
                                    
                                    SecureField("Password", text: $password)
                                        .textContentType(.newPassword)
                                        .textFieldStyle(.roundedBorder)
                                        .padding(.horizontal)
                                    
                                    SecureField("Confirm Password", text: $confirmPassword)
                                        .textContentType(.newPassword)
                                        .textFieldStyle(.roundedBorder)
                                        .padding(.horizontal)
                                    
                                    DatePicker("Date of Birth", selection: $dob, displayedComponents: .date)
                                        .datePickerStyle(.compact)
                                        .padding(.horizontal)
                                }
                            }
                            
                        case 2:
                            // Terms and Conditions
                            VStack {
                                Text("Terms and Conditions")
                                    .font(.title2.bold())
                                    .padding(.bottom, 8)
                                
                                ScrollView {
                                    Text(termsAndConditionsText)
                                        .padding()
                                        .onChange(of: geometry.frame(in: .global).minY) { _ in
                                            DispatchQueue.main.async {
                                                let scrollView = UIScrollView.current
                                                if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.bounds.height - 20) {
                                                    hasScrolledToBottom = true
                                                }
                                            }
                                        }
                                }
                                .frame(height: geometry.size.height * 0.5)
                                
                                Toggle(isOn: $hasAcceptedTerms) {
                                    Text("I have read and accept the terms and conditions")
                                }
                                .disabled(!hasScrolledToBottom)
                                .padding()
                                
                                if !hasScrolledToBottom {
                                    Text("Please scroll to the bottom to accept")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                        case 3:
                            // WWCC Details (if over 18)
                            VStack(spacing: 24) {
                                Text("Working With Children Check")
                                    .font(.title2.bold())
                                    .padding(.bottom, 8)
                                
                                if isOver18 {
                                    Text("As you are 18 or over, you must provide a valid Working With Children Check (WWCC).\n\nWe'll send you reminders at 3 months, 2 months, 1 month, 2 weeks, 1 week, and 1 day before expiry.")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                    
                                    TextField("WWCC Number", text: $wwcNumber)
                                        .textFieldStyle(.roundedBorder)
                                        .padding(.horizontal)
                                    
                                    DatePicker("WWCC Expiry Date", selection: $wwcExpiry, displayedComponents: .date)
                                        .datePickerStyle(.compact)
                                        .padding(.horizontal)
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Link("Apply for a WWCC", destination: URL(string: "https://www.service.nsw.gov.au/transaction/apply-for-a-working-with-children-check")!)
                                        Link("Update or change name", destination: URL(string: "https://www.kidsguardian.nsw.gov.au/child-safe-organisations/working-with-children-check/apply")!)
                                        Link("Recover WWCC number", destination: URL(string: "https://www.kidsguardian.nsw.gov.au/child-safe-organisations/working-with-children-check/apply")!)
                                    }
                                    .font(.footnote)
                                    .foregroundColor(.blue)
                                    .padding(.horizontal)
                                } else {
                                    Text("You are under 18. WWCC is not required.")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                }
                            }
                        default:
                            EmptyView()
                        }
                    }
                }
                
                // Navigation buttons
                HStack {
                    if currentPage > 0 {
                        Button("Back") {
                            withAnimation {
                                currentPage -= 1
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Spacer()
                    
                    if currentPage < 3 {
                        Button("Next") {
                            withAnimation {
                                currentPage += 1
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!canProceed)
                    } else {
                        Button(action: completeRegistration) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Complete Registration")
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!canProceed || isLoading)
                    }
                }
                .padding()
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var canProceed: Bool {
        switch currentPage {
        case 0:
            return selectedType != nil
        case 1:
            return !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty &&
                   !password.isEmpty && password == confirmPassword
        case 2:
            return hasScrolledToBottom && hasAcceptedTerms
        case 3:
            return !isOver18 || (!wwcNumber.isEmpty && wwcExpiry > Date())
        default:
            return false
        }
    }
    
    private func completeRegistration() {
        guard let type = selectedType else { return }
        isLoading = true
        
        // Create user object
        let user = AppModels.User(
            id: UUID().uuidString,
            firstName: firstName,
            lastName: lastName,
            email: email,
            role: type == .individual ? .volunteer : .corporateVolunteer,
            wwcNumber: isOver18 ? wwcNumber : nil,
            wwcExpiry: isOver18 ? wwcExpiry : nil
        )
        
        // Attempt to save user and complete registration
        Task {
            do {
                try await viewModel.registerUser(user, password: password)
                await MainActor.run {
                    isLoading = false
                    onComplete(type)
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
    
    private var termsAndConditionsText: String {
        """
        Terms and Conditions for Our Big Kitchen
        
        1. Volunteer Agreement
        By volunteering with Our Big Kitchen, you agree to:
        - Follow all safety protocols and guidelines
        - Maintain confidentiality regarding sensitive information
        - Respect fellow volunteers and staff
        - Adhere to scheduled commitments
        
        2. Health and Safety
        - Follow food safety guidelines
        - Report any injuries or incidents immediately
        - Use required protective equipment
        - Maintain cleanliness standards
        
        3. Code of Conduct
        - Treat everyone with respect
        - No discrimination or harassment
        - Follow instructions from staff
        - Maintain professional behavior
        
        4. Working with Children
        - Must have valid WWCC if 18+
        - Follow child protection guidelines
        - Report any concerns immediately
        
        5. Confidentiality
        - Protect sensitive information
        - No unauthorized photos/videos
        - Respect privacy of others
        
        6. Property and Equipment
        - Use equipment properly
        - Report any damage
        - Clean and store properly
        
        7. Attendance
        - Arrive on time
        - Notify of absences
        - Complete assigned shifts
        
        8. Media and Communications
        - Follow social media guidelines
        - Get permission for photos
        - Represent OBK positively
        
        9. Termination
        - OBK reserves right to terminate
        - Follow exit procedures
        - Return any property
        
        10. Updates
        - Terms may be updated
        - Notification of changes
        - Continued volunteering implies acceptance
        """
    }
}

// ScrollView extension to detect bottom
extension UIScrollView {
    static var current: UIScrollView {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        let viewController = window?.rootViewController
        return viewController?.view.subviews.first { $0 is UIScrollView } as! UIScrollView
    }
} 