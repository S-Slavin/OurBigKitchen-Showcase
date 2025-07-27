import SwiftUI

struct CorporateSignInView: View {
    @EnvironmentObject var appState: AppState
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var groupCode = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    private let primaryColor = ThemeManager.Colors.primary
    private let accentColor = ThemeManager.Colors.accent
    private let backgroundColor = Color(red: 1.0, green: 0.98, blue: 0.94)

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Modern background
                LinearGradient(
                    gradient: Gradient(colors: [backgroundColor, backgroundColor.opacity(0.95), Color(red: 1.0, green: 0.92, blue: 0.86)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Logo (optional, for consistency)
                        Image("AppLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.4)
                            .padding(.top, geometry.size.height * 0.02)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)

                        Text("Corporate Sign Up")
                            .font(.system(.title, design: .rounded, weight: .bold))
                            .foregroundColor(primaryColor)
                            .padding(.top, 8)
                            .padding(.bottom, 10)

                        // Card with fields
                        VStack(spacing: 18) {
                            ModernTextField(placeholder: "First Name", text: $firstName, icon: "person.fill")
                            ModernTextField(placeholder: "Last Name", text: $lastName, icon: "person.fill")
                            ModernTextField(placeholder: "Email", text: $email, icon: "envelope.fill", keyboardType: .emailAddress)
                            ModernSecureField(placeholder: "Password", text: $password, icon: "lock.fill")
                            ModernSecureField(placeholder: "Confirm Password", text: $confirmPassword, icon: "lock.fill")
                            ModernTextField(placeholder: "Group 4-digit Code", text: $groupCode, icon: "number.circle.fill", keyboardType: .numberPad)

                            if showError {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .padding(.vertical, 5)
                                    .padding(.horizontal, 20)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .transition(.move(edge: .top).combined(with: .opacity))
                            }

                            Button(action: signUp) {
                                ZStack {
                                    Text("Sign Up")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .opacity(isLoading ? 0 : 1)
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(1.2)
                                    }
                                }
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
                            .disabled(isLoading || !isFormValid)
                            .buttonStyle(ButtonStyles.scale)
                            .padding(.horizontal, 10)
                            .padding(.top, 10)
                        }
                        .padding(.vertical, 25)
                        .padding(.horizontal, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color.white.opacity(0.8))
                                .shadow(color: Color.black.opacity(0.07), radius: 20, x: 0, y: 10)
                        )
                        .padding(.horizontal, 20)

                        HStack {
                            Text("Already have an account?")
                            NavigationLink("Log In", destination: CorporateLoginView())
                                .foregroundColor(primaryColor)
                        }
                        .padding(.top, 10)
                        Spacer()
                    }
                    .padding(.top, geometry.safeAreaInsets.top + 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarTitle("Corporate Sign Up", displayMode: .inline)
    }

    private var isFormValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        !groupCode.isEmpty &&
        groupCode.count == 4 &&
        Int(groupCode) != nil
    }

    private func signUp() {
        guard isFormValid else { return }
        isLoading = true
        errorMessage = ""
        showError = false
        Task {
            do {
                let user = User(
                    id: UUID().uuidString,
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    role: .corporate
                )
                try PersistenceManager.shared.save(user, forKey: "currentUser")
                UserDefaults.standard.set(true, forKey: "isAuthenticated")
                UserDefaults.standard.set(true, forKey: "hasSignedIn")
                NotificationCenter.default.post(name: .didUpdateAuth, object: nil)
            } catch let error as NSError {
                errorMessage = "Failed to save user data: \(error.localizedDescription)"
                showError = true
            }
            isLoading = false
        }
    }
}

struct CorporateLoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var showPasswordReset = false
    private let primaryColor = ThemeManager.Colors.primary
    private let accentColor = ThemeManager.Colors.accent
    private let backgroundColor = Color(red: 1.0, green: 0.98, blue: 0.94)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Modern background
                LinearGradient(
                    gradient: Gradient(colors: [backgroundColor, backgroundColor.opacity(0.95), Color(red: 1.0, green: 0.92, blue: 0.86)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Logo
                        Image("AppLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.4)
                            .padding(.top, geometry.size.height * 0.02)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)

                        Text("Corporate Volunteer Login")
                            .font(.system(.title, design: .rounded, weight: .bold))
                            .foregroundColor(primaryColor)
                            .padding(.top, 8)
                            .padding(.bottom, 10)
                        
                        // Card with fields
                        VStack(spacing: 18) {
                            ModernTextField(placeholder: "Email", text: $email, icon: "envelope.fill", keyboardType: .emailAddress)
                            ModernSecureField(placeholder: "Password", text: $password, icon: "lock.fill")
                            
                            if showError {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .padding(.vertical, 5)
                                    .padding(.horizontal, 20)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .transition(.move(edge: .top).combined(with: .opacity))
                            }
                            
                            Button(action: login) {
                                ZStack {
                                    Text("Log In")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .opacity(isLoading ? 0 : 1)
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(1.2)
                                    }
                                }
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
                            .disabled(isLoading || !isFormValid)
                            .buttonStyle(ButtonStyles.scale)
                            .padding(.horizontal, 10)
                            .padding(.top, 10)
                            
                            #if DEBUG
                            Button(action: demoLogin) {
                                Text("Demo Login")
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
                            .padding(.horizontal, 10)
                            #endif
                        }
                        .padding(.vertical, 25)
                        .padding(.horizontal, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color.white.opacity(0.8))
                                .shadow(color: Color.black.opacity(0.07), radius: 20, x: 0, y: 10)
                        )
                        .padding(.horizontal, 20)
                        
                        HStack {
                            Text("Don't have an account?")
                            NavigationLink("Sign Up", destination: CorporateSignInView())
                                .foregroundColor(primaryColor)
                        }
                        .padding(.top, 10)
                        
                        Button("Forgot Password?") {
                            showPasswordReset = true
                        }
                        .font(.footnote)
                        .foregroundColor(primaryColor)
                        .padding(.top, 8)
                        
                        Spacer()
                    }
                    .padding(.top, geometry.safeAreaInsets.top + 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarTitle("Corporate Login", displayMode: .inline)
        .sheet(isPresented: $showPasswordReset) {
            PasswordResetView()
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && ValidationUtils.isValidEmail(email)
    }
    
    private func login() {
        guard isFormValid else { return }
        
        isLoading = true
        errorMessage = ""
        showError = false
        
        Task {
            do {
                try await AuthService.shared.signIn(email: email, password: password)
            } catch let error as AuthError {
                errorMessage = error.localizedDescription
                showError = true
            } catch {
                errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
                showError = true
            }
            
            isLoading = false
        }
    }
    
    private func demoLogin() {
        isLoading = true
        errorMessage = ""
        showError = false
        
        Task {
            do {
                let user = User(
                    id: UUID().uuidString,
                    firstName: "Demo",
                    lastName: "User",
                    email: "demo@corporate.com",
                    role: .corporate
                )
                try PersistenceManager.shared.save(user, forKey: "currentUser")
                UserDefaults.standard.set(true, forKey: "isAuthenticated")
                UserDefaults.standard.set(true, forKey: "hasSignedIn")
                NotificationCenter.default.post(name: .didUpdateAuth, object: nil)
            } catch let error as NSError {
                errorMessage = "Failed to save demo user data: \(error.localizedDescription)"
                showError = true
            }
            isLoading = false
        }
    }
}

struct CorporateSignInView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CorporateSignInView()
                .environmentObject(AppState())
        }
        .preferredColorScheme(.light)
    }
} 