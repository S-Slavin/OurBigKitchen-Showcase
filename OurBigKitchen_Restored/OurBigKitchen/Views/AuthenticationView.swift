import SwiftUI
import Combine

// Shared authentication state that persists across sign-in flows
class UserAuthInfo {
    static let shared = UserAuthInfo()
    
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var hasAcceptedTerms: Bool = false
    var hasProvidedInfo: Bool {
        !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty
    }
    var hasProvidedName: Bool {
        !firstName.isEmpty && !lastName.isEmpty
    }
    var hasProvidedEmail: Bool {
        !email.isEmpty
    }
    
    private init() {
        // Load terms acceptance from UserDefaults
        hasAcceptedTerms = UserDefaults.standard.bool(forKey: "hasAcceptedTerms")
    }
    
    func saveUserInfo(firstName: String, lastName: String, email: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
    }
}

@MainActor
class AuthenticationViewModel: ObservableObject {
    enum LoginType: String, CaseIterable {
        case individual = "Individual"
        case groupCode = "Group Code"
    }
    
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var password = ""
    @Published var groupCode = ""
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var isAuthenticated = false
    @Published var hasAcceptedTerms = false
    @Published var loginType: LoginType = .individual
    
    private var cancellables = Set<AnyCancellable>()
    private let authManager = AuthManager.shared
    
    init() {
        // Check if already logged in
        isAuthenticated = authManager.isAuthenticated
        
        // Use existing user info if available
        if let firstName = UserDefaults.standard.string(forKey: "firstName"),
           let lastName = UserDefaults.standard.string(forKey: "lastName"),
           let email = UserDefaults.standard.string(forKey: "email") {
            self.firstName = firstName
            self.lastName = lastName
            self.email = email
        }
        
        // Check terms and conditions status
        hasAcceptedTerms = UserDefaults.standard.bool(forKey: "hasAcceptedTerms")
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func login() {
        switch loginType {
        case .individual:
            loginAsIndividual()
        case .groupCode:
            loginWithGroupCode()
        }
    }
    
    func loginAsIndividual() {
        guard !firstName.isEmpty, !lastName.isEmpty, isValidEmail(email), !password.isEmpty, hasAcceptedTerms else {
            if !hasAcceptedTerms {
                errorMessage = "Please accept the terms and conditions"
            } else if password.isEmpty {
                errorMessage = "Please enter a password"
            } else {
                errorMessage = "Please enter valid first name, last name, and email"
            }
            return
        }
        
        // Save user info
        UserAuthInfo.shared.saveUserInfo(firstName: firstName, lastName: lastName, email: email)
        UserAuthInfo.shared.hasAcceptedTerms = hasAcceptedTerms
        
        isLoading = true
        errorMessage = ""
        
        // Simulate successful login
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            let user = AppModels.User(
                firstName: self.firstName,
                lastName: self.lastName,
                email: self.email,
                role: .volunteer
            )
            
            do {
                try self.authManager.saveUser(user: user)
                self.isAuthenticated = true
                NotificationCenter.default.post(name: .didUpdateAuth, object: nil)
                self.clearFields()
            } catch {
                self.errorMessage = "Failed to save user data: \(error.localizedDescription)"
            }
            
            self.isLoading = false
        }
    }
    
    func loginWithGroupCode() {
        guard !firstName.isEmpty, !lastName.isEmpty, isValidEmail(email), !groupCode.isEmpty, !password.isEmpty, hasAcceptedTerms else {
            if !hasAcceptedTerms {
                errorMessage = "Please accept the terms and conditions"
            } else if !isValidEmail(email) {
                errorMessage = "Please enter a valid email address"
            } else if firstName.isEmpty || lastName.isEmpty {
                errorMessage = "Please enter your first and last name"
            } else if password.isEmpty {
                errorMessage = "Please enter a password"
            } else {
                errorMessage = "Please enter a valid group code"
            }
            return
        }
        
        UserAuthInfo.shared.hasAcceptedTerms = hasAcceptedTerms
        UserAuthInfo.shared.saveUserInfo(firstName: firstName, lastName: lastName, email: email)
        
        isLoading = true
        errorMessage = ""
        
        // Use existing loginWithGroupCode method from AuthManager
        authManager.loginWithGroupCode(email: email, groupCode: groupCode)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Failed to login with group code: \(error.localizedDescription)"
                    }
                    self?.isLoading = false
                },
                receiveValue: { [weak self] _ in
                    self?.isAuthenticated = true
                    NotificationCenter.default.post(name: .didUpdateAuth, object: nil)
                    self?.clearFields()
                }
            )
            .store(in: &cancellables)
    }
    
    func loginWithApple() {
        guard hasAcceptedTerms else {
            errorMessage = "Please accept the terms and conditions"
            return
        }
        
        UserAuthInfo.shared.hasAcceptedTerms = hasAcceptedTerms
        
        isLoading = true
        errorMessage = ""
        
        // Simulate Apple sign-in flow
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            let mockedAppleUser = AppModels.User(
                firstName: "Apple",
                lastName: "User",
                email: "apple.user@example.com",
                role: .volunteer
            )
            
            do {
                try self.authManager.saveAppleUser(user: mockedAppleUser)
                self.isAuthenticated = true
                NotificationCenter.default.post(name: .didUpdateAuth, object: nil)
            } catch {
                self.errorMessage = "Failed to save Apple user: \(error.localizedDescription)"
            }
            
            self.isLoading = false
        }
    }
    
    func loginWithGmail() {
        guard hasAcceptedTerms else {
            errorMessage = "Please accept the terms and conditions"
            return
        }
        
        UserAuthInfo.shared.hasAcceptedTerms = hasAcceptedTerms
        
        isLoading = true
        errorMessage = ""
        
        // Simulate Gmail sign-in flow
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            let mockedGmailUser = AppModels.User(
                firstName: "Gmail",
                lastName: "User",
                email: "gmail.user@example.com",
                role: .volunteer
            )
            
            do {
                try self.authManager.saveGmailUser(user: mockedGmailUser)
                self.isAuthenticated = true
                NotificationCenter.default.post(name: .didUpdateAuth, object: nil)
            } catch {
                self.errorMessage = "Failed to save Gmail user: \(error.localizedDescription)"
            }
            
            self.isLoading = false
        }
    }
    
    func clearFields() {
        firstName = ""
        lastName = ""
        email = ""
        password = ""
        groupCode = ""
        errorMessage = ""
    }
}

struct AuthenticationView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = AuthenticationViewModel()
    @State private var showTermsSheet = false
    var onAuthenticated: () -> Void
    
    // Warm color scheme
    private let primaryColor = Color(red: 0.93, green: 0.46, blue: 0.12) // Orange
    private let secondaryColor = Color(red: 0.98, green: 0.82, blue: 0.25) // Yellow
    private let accentColor = Color(red: 0.85, green: 0.33, blue: 0.10) // Dark Orange
    private let backgroundColor = Color(red: 1.0, green: 0.98, blue: 0.94) // Cream
    
    // Custom ViewModifier to simplify text field styling
    struct CustomTextFieldStyle: ViewModifier {
        let backgroundColor: Color
        let strokeColor: Color
        
        func body(content: Content) -> some View {
            content
                .padding()
                .background(backgroundColor)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(strokeColor, lineWidth: 1)
                )
        }
    }
    
    // Extension to make it easier to apply the style
    private func applyFieldStyle<T: View>(_ view: T) -> some View {
        view.modifier(CustomTextFieldStyle(backgroundColor: backgroundColor, strokeColor: primaryColor))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Logo
                VStack(spacing: 16) {
                    Image("OurBigKitchenLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 150)
                    
                    Text("Our Big Kitchen")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(primaryColor)
                    
                    Text("Making a difference through food and community")
                        .font(.headline)
                        .foregroundColor(accentColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 20)
                
                // Login type selector
                Picker("Login Type", selection: $viewModel.loginType) {
                    ForEach(AuthenticationViewModel.LoginType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Form fields
                VStack(spacing: 20) {
                    if viewModel.loginType == .individual {
                        // Individual login form
                        VStack(alignment: .leading, spacing: 12) {
                            Text("First Name")
                                .font(.callout)
                                .foregroundColor(accentColor)
                            
                            TextField("First Name", text: $viewModel.firstName)
                                .textContentType(.givenName)
                                .modifier(CustomTextFieldStyle(backgroundColor: backgroundColor, strokeColor: primaryColor))
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Last Name")
                                .font(.callout)
                                .foregroundColor(accentColor)
                            
                            TextField("Last Name", text: $viewModel.lastName)
                                .textContentType(.familyName)
                                .modifier(CustomTextFieldStyle(backgroundColor: backgroundColor, strokeColor: primaryColor))
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Email")
                                .font(.callout)
                                .foregroundColor(accentColor)
                            
                            TextField("Email", text: $viewModel.email)
                                .keyboardType(.emailAddress)
                                .textContentType(.emailAddress)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .modifier(CustomTextFieldStyle(backgroundColor: backgroundColor, strokeColor: primaryColor))
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Password")
                                .font(.callout)
                                .foregroundColor(accentColor)
                            
                            SecureField("Password", text: $viewModel.password)
                                .textContentType(.password)
                                .modifier(CustomTextFieldStyle(backgroundColor: backgroundColor, strokeColor: primaryColor))
                        }
                    } else {
                        // Group code login form
                        VStack(alignment: .leading, spacing: 12) {
                            Text("First Name")
                                .font(.callout)
                                .foregroundColor(accentColor)
                            
                            TextField("First Name", text: $viewModel.firstName)
                                .textContentType(.givenName)
                                .modifier(CustomTextFieldStyle(backgroundColor: backgroundColor, strokeColor: primaryColor))
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Last Name")
                                .font(.callout)
                                .foregroundColor(accentColor)
                            
                            TextField("Last Name", text: $viewModel.lastName)
                                .textContentType(.familyName)
                                .modifier(CustomTextFieldStyle(backgroundColor: backgroundColor, strokeColor: primaryColor))
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Email")
                                .font(.callout)
                                .foregroundColor(accentColor)
                            
                            TextField("Email", text: $viewModel.email)
                                .keyboardType(.emailAddress)
                                .textContentType(.emailAddress)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .modifier(CustomTextFieldStyle(backgroundColor: backgroundColor, strokeColor: primaryColor))
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Password")
                                .font(.callout)
                                .foregroundColor(accentColor)
                            
                            SecureField("Password", text: $viewModel.password)
                                .textContentType(.password)
                                .modifier(CustomTextFieldStyle(backgroundColor: backgroundColor, strokeColor: primaryColor))
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Group Code")
                                .font(.callout)
                                .foregroundColor(accentColor)
                            
                            TextField("Enter your group code", text: $viewModel.groupCode)
                                .modifier(CustomTextFieldStyle(backgroundColor: backgroundColor, strokeColor: primaryColor))
                        }
                    }
                }
                .padding(.horizontal)
                
                // Error message
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Terms and conditions
                VStack(spacing: 16) {
                    Divider()
                        .background(primaryColor)
                        .padding(.vertical, 8)
                    
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: viewModel.hasAcceptedTerms ? "checkmark.square.fill" : "square")
                            .foregroundColor(viewModel.hasAcceptedTerms ? primaryColor : accentColor)
                            .font(.title3)
                            .onTapGesture {
                                viewModel.hasAcceptedTerms.toggle()
                            }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("I accept the Terms and Conditions and consent to my data being processed according to the Privacy Policy")
                                .font(.footnote)
                                .foregroundColor(accentColor)
                        }
                        .onTapGesture {
                            showTermsSheet = true
                        }
                        
                        Spacer()
                    }
                }
                .padding(.horizontal)
                
                // Sign in buttons
                VStack(spacing: 16) {
                    Button(action: {
                        viewModel.login()
                    }) {
                        Text(viewModel.loginType == .individual ? "Sign In" : "Sign In with Group Code")
                            .font(.headline)
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
                            .cornerRadius(12)
                    }
                    .buttonStyle(ButtonStyles.scale)
                    
                    Divider()
                        .background(primaryColor)
                        .padding(.vertical, 8)
                    
                    Text("Or sign in with")
                        .font(.subheadline)
                        .foregroundColor(accentColor)
                    
                    Button(action: {
                        viewModel.loginWithApple()
                    }) {
                        HStack {
                            Image(systemName: "apple.logo")
                            Text("Sign in with Apple")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.black)
                        .cornerRadius(12)
                    }
                    .buttonStyle(ButtonStyles.scale)
                    
                    Button(action: {
                        viewModel.loginWithGmail()
                    }) {
                        HStack {
                            Image(systemName: "envelope.fill")
                            Text("Sign in with Gmail")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.red)
                        .cornerRadius(12)
                    }
                    .buttonStyle(ButtonStyles.scale)
                }
                .padding(.horizontal)
                
                Spacer(minLength: 20)
                
                // Skip authentication button for testing
                Button {
                    // Force authentication to proceed
                    appState.isAuthenticated = true
                    onAuthenticated()
                } label: {
                    HStack {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 18))
                        Text("SKIP FOR DEMO")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 24)
                    .background(Color.orange)
                    .cornerRadius(12)
                }
                .padding(.bottom, 20)
                .buttonStyle(ButtonStyles.scale)
            }
            .padding()
            .disabled(viewModel.isLoading)
            .background(backgroundColor.ignoresSafeArea())
        }
        .overlay {
            if viewModel.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .overlay {
                        VStack {
                            ProgressView()
                                .scaleEffect(1.5)
                                .padding(.bottom, 10)
                            Text("Authenticating...")
                                .foregroundColor(.white)
                        }
                        .padding(24)
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 10)
                    }
            }
        }
        .sheet(isPresented: $showTermsSheet) {
            VStack {
                HStack {
                    Spacer()
                    Button("SKIP FOR DEMO") {
                        showTermsSheet = false
                    }
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 24)
                    .background(Color.orange)
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                    .padding()
                }
                
                TermsView(showTermsSheet: $showTermsSheet)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .onChange(of: viewModel.isAuthenticated) { newValue in
            if newValue {
                appState.isAuthenticated = true
                onAuthenticated()
            }
        }
        .onAppear {
            print("AuthenticationView appeared")
        }
    }
}

#Preview {
    AuthenticationView(onAuthenticated: {})
        .environmentObject(AppState())
} 