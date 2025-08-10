import SwiftUI

struct WWCSignInView: View {
    @EnvironmentObject var appState: AppState
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var wwcNumber = ""
    @State private var wwcExpiryDate = Date()
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var hasAcceptedTerms = false
    @State private var showTermsSheet = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                Text("WWC Volunteer Sign Up")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                
                Text("Please provide your Working With Children check details")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                
                // Form
                VStack(spacing: 16) {
                    // Personal Information
                    Group {
                        TextField("First Name", text: $firstName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Last Name", text: $lastName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                    
                    // WWC Information
                    Group {
                        TextField("WWC Number", text: $wwcNumber)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                        
                        DatePicker(
                            "WWC Expiry Date",
                            selection: $wwcExpiryDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(CompactDatePickerStyle())
                    }
                    
                    // Password
                    Group {
                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        SecureField("Confirm Password", text: $confirmPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Terms and Conditions
                    Toggle(isOn: $hasAcceptedTerms) {
                        HStack {
                            Text("I accept the ")
                            Button("Terms and Conditions") {
                                showTermsSheet = true
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                }
                .padding(.horizontal)
                
                // Error Message
                if showError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                // Sign Up Button
                Button(action: signUp) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Sign Up")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .disabled(isLoading || !isFormValid)
                .opacity(isFormValid ? 1.0 : 0.6)
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Login Link
                HStack {
                    Text("Already have an account?")
                    NavigationLink("Log In", destination: WWCLoginView())
                        .foregroundColor(.blue)
                }
                .padding(.top, 10)
                
                Spacer()
            }
        }
        .navigationBarTitle("WWC Sign Up", displayMode: .inline)
        .sheet(isPresented: $showTermsSheet) {
            TermsAndConditionsView()
        }
    }
    
    private var isFormValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !email.isEmpty &&
        !wwcNumber.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        hasAcceptedTerms &&
        wwcExpiryDate > Date()
    }
    
    private func signUp() {
        guard isFormValid else { return }
        
        isLoading = true
        errorMessage = ""
        showError = false
        
        // TODO: Implement WWC verification
        // For now, simulate a network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Create user
            let user = AppModels.User(
                id: UUID().uuidString,
                firstName: firstName,
                lastName: lastName,
                email: email,
                role: .wwcVolunteer,
                preferences: AppModels.UserPreferences(),
                achievements: [],
                stats: AppModels.UserStats(),
                hasFoodSafetyRegistration: false,
                authProvider: "wwc"
            )
            
            // Save user and authenticate
            do {
                try PersistenceManager.shared.save(user, forKey: "currentUser")
                UserDefaults.standard.set(true, forKey: "isAuthenticated")
                UserDefaults.standard.set(true, forKey: "hasSignedIn")
                NotificationCenter.default.post(name: .didUpdateAuth, object: nil)
            } catch {
                errorMessage = "Failed to save user data: \(error.localizedDescription)"
                showError = true
            }
            
            isLoading = false
        }
    }
}

struct WWCLoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    
    // Warm color scheme
    private let primaryColor = Color(red: 0.93, green: 0.46, blue: 0.12) // Orange
    private let secondaryColor = Color(red: 0.98, green: 0.82, blue: 0.25) // Yellow
    private let accentColor = Color(red: 0.85, green: 0.33, blue: 0.10) // Dark Orange
    private let backgroundColor = Color(red: 1.0, green: 0.98, blue: 0.94) // Cream
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text("WWC Volunteer Login")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(primaryColor)
                .padding(.top, 40)
            
            // Form
            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)
            
            // Error Message
            if showError {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }
            
            // Login Button
            Button(action: login) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Log In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [primaryColor, accentColor]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(10)
                }
            }
            .disabled(isLoading || !isFormValid)
            .opacity(isFormValid ? 1.0 : 0.6)
            .padding(.horizontal)
            .padding(.top, 20)
            
            // Sign Up Link
            HStack {
                Text("Don't have an account?")
                NavigationLink("Sign Up", destination: WWCSignInView())
                    .foregroundColor(.blue)
            }
            .padding(.top, 10)
            
            Spacer()
        }
        .navigationBarTitle("WWC Login", displayMode: .inline)
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty
    }
    
    private func login() {
        guard isFormValid else { return }
        
        isLoading = true
        errorMessage = ""
        showError = false
        
        // TODO: Implement actual login
        // For now, simulate a network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Check if user exists and has WWC role
            if let user = try? PersistenceManager.shared.load(AppModels.User.self, forKey: "currentUser"),
               user.role == .wwcVolunteer {
                UserDefaults.standard.set(true, forKey: "isAuthenticated")
                UserDefaults.standard.set(true, forKey: "hasSignedIn")
                NotificationCenter.default.post(name: .didUpdateAuth, object: nil)
            } else {
                errorMessage = "Invalid email or password"
                showError = true
            }
            
            isLoading = false
        }
    }
}

struct WWCSignInView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WWCSignInView()
                .environmentObject(AppState())
        }
    }
} 