import SwiftUI
import Combine

// Forward reference to UserAuthInfo if needed
// Remove this if UserAuthInfo is already accessible
// from a shared import
extension UserAuthInfo {}

class LoginViewModel: ObservableObject {
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var password = ""
    @Published var groupCode = ""
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var isAuthenticated = false
    @Published var selectedLoginType: LoginType = .groupCode
    @Published var showError = false
    
    enum LoginType: String, CaseIterable {
        case groupCode = "Group Code"
        case email = "Email"
        case social = "Social"
    }
    
    private var cancellables = Set<AnyCancellable>()
    private let authManager = AuthManager.shared
    
    init() {
        isAuthenticated = authManager.isAuthenticated
        
        // Use existing user info if available
        if let user = authManager.currentUser {
            self.email = user.email
            self.firstName = user.firstName
            self.lastName = user.lastName
        }
        
        // Subscribe to auth state changes
        authManager.$isAuthenticated
            .sink { [weak self] isAuthenticated in
                self?.isAuthenticated = isAuthenticated
            }
            .store(in: &cancellables)
        
        authManager.$isLoading
            .sink { [weak self] isLoading in
                self?.isLoading = isLoading
            }
            .store(in: &cancellables)
        
        authManager.$error
            .compactMap { $0?.localizedDescription }
            .sink { [weak self] errorMessage in
                self?.errorMessage = errorMessage
                self?.showError = true
            }
            .store(in: &cancellables)
    }
    
    func login() {
        switch selectedLoginType {
        case .groupCode:
            loginWithGroupCode()
        case .email:
            loginWithEmail()
        case .social:
            // Social login is handled directly in the view
            break
        }
    }
    
    func loginWithGroupCode() {
        guard isValidEmail(), !groupCode.isEmpty else {
            showError(message: "Please enter a valid email and group code")
            return
        }
        
        authManager.loginWithGroupCode(email: email, groupCode: groupCode)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure = completion {
                        self?.showError(message: "Failed to login with group code")
                    }
                },
                receiveValue: { [weak self] _ in
                    self?.clearFields()
                }
            )
            .store(in: &cancellables)
    }
    
    func loginWithEmail() {
        guard isValidEmail(), !password.isEmpty, !firstName.isEmpty, !lastName.isEmpty else {
            showError(message: "Please fill in all fields")
            return
        }
        
        authManager.login(email: email, password: password)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure = completion {
                        self?.showError(message: "Failed to login with email")
                    }
                },
                receiveValue: { [weak self] _ in
                    self?.clearFields()
                }
            )
            .store(in: &cancellables)
    }
    
    func loginWithApple() {
        authManager.loginWithApplePublisher()
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure = completion {
                        self?.showError(message: "Failed to login with Apple")
                    }
                },
                receiveValue: { [weak self] _ in
                    self?.clearFields()
                }
            )
            .store(in: &cancellables)
    }
    
    func loginWithGmail() {
        authManager.loginWithGmailPublisher()
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure = completion {
                        self?.showError(message: "Failed to login with Gmail")
                    }
                },
                receiveValue: { [weak self] _ in
                    self?.clearFields()
                }
            )
            .store(in: &cancellables)
    }
    
    private func isValidEmail() -> Bool {
        if email.isEmpty || !email.contains("@") {
            showError(message: "Please enter a valid email address")
            return false
        }
        return true
    }
    
    private func clearFields() {
        email = ""
        password = ""
        firstName = ""
        lastName = ""
        groupCode = ""
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
    
    var isEmailFormValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !email.isEmpty &&
        email.contains("@") &&
        password.count >= 6
    }
}

struct LoginView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = LoginViewModel()
    @State private var showTermsSheet = false
    @State private var showForgotPassword = false
    @State private var showSignUp = false
    @State private var showError = false
    @State private var errorMessage = ""
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    // Warm color scheme
    private let primaryColor = Color(red: 0.93, green: 0.46, blue: 0.12) // Orange
    private let secondaryColor = Color(red: 0.98, green: 0.82, blue: 0.25) // Yellow
    private let accentColor = Color(red: 0.85, green: 0.33, blue: 0.10) // Dark Orange
    private let backgroundColor = Color(red: 1.0, green: 0.98, blue: 0.94) // Cream
    
    init() {
        // Initialize without onboarding state
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Logo and title
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .padding(.top, 40)
                
                Text("Welcome to Our Big Kitchen")
                    .font(.title)
                    .fontWeight(.bold)
                
                // Login type selector
                Picker("Login Type", selection: $viewModel.selectedLoginType) {
                    Text("Group Code").tag(LoginViewModel.LoginType.groupCode)
                    Text("Email").tag(LoginViewModel.LoginType.email)
                    Text("Social").tag(LoginViewModel.LoginType.social)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Login forms
                ScrollView {
                    VStack(spacing: 20) {
                        switch viewModel.selectedLoginType {
                        case .groupCode:
                            groupCodeLoginForm
                        case .email:
                            emailLoginForm
                        case .social:
                            socialLoginForm
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
    
    private var groupCodeLoginForm: some View {
        VStack(spacing: 15) {
            TextField("Group Code", text: $viewModel.groupCode)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            
            Button(action: {
                viewModel.loginWithGroupCode()
            }) {
                Text("Login with Group Code")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue)
                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    )
            }
            .buttonStyle(ButtonStyles.scale)
            .disabled(viewModel.isLoading || viewModel.groupCode.isEmpty)
        }
    }
    
    private var emailLoginForm: some View {
        VStack(spacing: 15) {
            TextField("First Name", text: $viewModel.firstName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.words)
            
            TextField("Last Name", text: $viewModel.lastName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.words)
            
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: {
                viewModel.loginWithEmail()
            }) {
                Text("Login with Email")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue)
                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    )
            }
            .buttonStyle(ButtonStyles.scale)
            .disabled(viewModel.isLoading || !viewModel.isEmailFormValid)
        }
    }
    
    private var socialLoginForm: some View {
        VStack(spacing: 15) {
            Button(action: {
                viewModel.loginWithApple()
            }) {
                HStack {
                    Image(systemName: "apple.logo")
                    Text("Continue with Apple")
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black)
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                )
            }
            .buttonStyle(ButtonStyles.scale)
            .disabled(viewModel.isLoading)
            
            Button(action: {
                viewModel.loginWithGmail()
            }) {
                HStack {
                    Image(systemName: "g.circle.fill")
                    Text("Continue with Google")
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(ButtonStyles.scale)
            .disabled(viewModel.isLoading)
        }
    }
}

#Preview {
    LoginView()
} 