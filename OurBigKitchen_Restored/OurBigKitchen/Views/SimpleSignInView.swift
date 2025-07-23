import SwiftUI
import UIKit

struct SimpleSignInView: View {
    @EnvironmentObject var appState: AppState
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var groupCode = ""
    @State private var loginType = 0  // 0 = Individual, 1 = Group Code
    @State private var isSignUp = 0   // 0 = Login, 1 = Sign Up
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var rememberPassword = false
    @State private var isLoading = false
    @State private var animationAmount = 1.0
    
    // Animation states
    @State private var animateIn = false
    @State private var animateFields = false
    @State private var animateButtons = false
    
    // Warm color scheme to match app theme - using ThemeManager colors
    private let primaryColor = ThemeManager.Colors.primary
    private let accentColor = ThemeManager.Colors.accent
    private let backgroundColor = Color(red: 1.0, green: 0.98, blue: 0.94) // Cream
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background layer - enhanced with more decorative elements
                enhancedBackground
                
                ScrollView(showsIndicators: false) {
                    // Content layer
                    VStack(spacing: 20) {
                        // Logo with animation
                        logoView(geometry: geometry)
                            .scaleEffect(animateIn ? 1.0 : 0.9)
                            .opacity(animateIn ? 1.0 : 0.0)
                        
                        // Welcome message
                        Text(isSignUp == 0 ? "Welcome Back!" : "Join Our Community")
                            .font(.system(.title, design: .rounded, weight: .bold))
                            .foregroundColor(primaryColor)
                            .padding(.top, 8)
                            .padding(.bottom, 10)
                            .scaleEffect(animateIn ? 1.0 : 0.95)
                            .opacity(animateIn ? 1.0 : 0.0)
                        
                        // Subtitle
                        Text(isSignUp == 0 ? 
                            "Sign in to continue your journey" : 
                            "Create an account to get started")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 20)
                            .padding(.horizontal, 20)
                            .opacity(animateIn ? 0.8 : 0.0)
                        
                        // Main form
                        formCard(geometry: geometry)
                            .offset(y: animateFields ? 0 : 20)
                            .opacity(animateFields ? 1.0 : 0.0)
                        
                        // Additional footer options
                        footerView
                            .padding(.top, 15)
                            .offset(y: animateButtons ? 0 : 15)
                            .opacity(animateButtons ? 1.0 : 0.0)
                        
                        // Skip option for development
                        #if DEBUG
                        Button(action: {
                            authenticateUser(skipValidation: true)
                        }) {
                            Text("Skip Authentication")
                                .font(.footnote)
                                .foregroundColor(.gray.opacity(0.7))
                                .padding(.top, 5)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.top, 10)
                        .opacity(animateButtons ? 0.7 : 0.0)
                        #endif
                        
                        Spacer()
                    }
                    .padding(.top, geometry.safeAreaInsets.top + 20)
                    .padding(.bottom, 30)
                }
            }
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                startAnimations()
            }
            .onChange(of: isSignUp) { _ in
                // Reset error state when switching between login/signup
                showError = false
                
                // Re-animate fields with slight delay
                withAnimation(.easeOut(duration: 0.2)) {
                    animateFields = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        animateFields = true
                    }
                }
            }
            .onChange(of: loginType) { _ in
                // Reset error state when switching between individual/group
                showError = false
                
                // Re-animate fields with slight delay
                withAnimation(.easeOut(duration: 0.2)) {
                    animateFields = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        animateFields = true
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .transition(.opacity)
    }
    
    // Start animation sequence
    private func startAnimations() {
        // Staggered animation sequence
        withAnimation(.easeOut(duration: 0.6)) {
            animateIn = true
        }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
            animateFields = true
        }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.4)) {
            animateButtons = true
        }
        
        // Background animation
        withAnimation(.easeInOut(duration: 7).repeatForever(autoreverses: true)) {
            animationAmount = 1.03
        }
    }
    
    // MARK: - Enhanced Background Layer
    
    private var enhancedBackground: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    backgroundColor,
                    backgroundColor.opacity(0.95),
                    Color(red: 1.0, green: 0.92, blue: 0.86)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            // Animated decorative elements with transparent logo instead of circles
            ZStack {
                // Top left decorative element - REMOVING
                // Bottom right decorative element - REMOVING
                // Additional decorative elements - REMOVING
            }
        }
    }
    
    // MARK: - Logo View
    
    private func logoView(geometry: GeometryProxy) -> some View {
        Image("AppLogo")
            .resizable()
            .scaledToFit()
            .frame(width: geometry.size.width * 0.4)
            .padding(.top, geometry.size.height * 0.02)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Form Card View
    
    private func formCard(geometry: GeometryProxy) -> some View {
        VStack(spacing: 20) {
            // Login/Sign Up Toggle
            loginSignUpToggle
            
            // Individual/Group toggle
            loginTypeToggle
            
            // Form fields
            formFields
            
            // Error message
            if showError {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            // Action buttons
            actionButtons
        }
        .padding(.vertical, 25)
        .padding(.horizontal, 5)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.white.opacity(0.8))
                .shadow(color: Color.black.opacity(0.07), radius: 20, x: 0, y: 10)
        )
        .padding(.horizontal, 20)
    }
    
    // MARK: - Login/SignUp Toggle - Enhanced with animations
    
    private var loginSignUpToggle: some View {
        HStack(spacing: 0) {
            // Login pill
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isSignUp = 0
                    appState.isSigningUp = false
                }
            }) {
                Text("Login")
                    .font(.headline)
                    .fontWeight(isSignUp == 0 ? .semibold : .medium)
                    .padding(.vertical, 14)
                    .frame(width: UIScreen.main.bounds.width * 0.4)
                    .foregroundColor(isSignUp == 0 ? .white : primaryColor)
                    .background(
                        ZStack {
                            if isSignUp == 0 {
                                // Active state
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [primaryColor, accentColor]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .shadow(color: primaryColor.opacity(0.3), radius: 5, x: 0, y: 3)
                            } else {
                                // Inactive state
                                Capsule()
                                    .stroke(primaryColor, lineWidth: 1)
                            }
                        }
                    )
            }
            .buttonStyle(ButtonStyles.scale)
            
            // Sign Up pill
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isSignUp = 1
                    appState.isSigningUp = true
                }
            }) {
                Text("Sign Up")
                    .font(.headline)
                    .fontWeight(isSignUp == 1 ? .semibold : .medium)
                    .padding(.vertical, 14)
                    .frame(width: UIScreen.main.bounds.width * 0.4)
                    .foregroundColor(isSignUp == 1 ? .white : primaryColor)
                    .background(
                        ZStack {
                            if isSignUp == 1 {
                                // Active state
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [primaryColor, accentColor]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .shadow(color: primaryColor.opacity(0.3), radius: 5, x: 0, y: 3)
                            } else {
                                // Inactive state
                                Capsule()
                                    .stroke(primaryColor, lineWidth: 1)
                            }
                        }
                    )
            }
            .buttonStyle(ButtonStyles.scale)
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Individual/Group Toggle - Enhanced with modern pill design
    
    private var loginTypeToggle: some View {
        HStack(spacing: 10) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    loginType = 0
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "person.fill")
                        .imageScale(.medium)
                    Text("Individual")
                        .font(.subheadline)
                        .fontWeight(loginType == 0 ? .semibold : .medium)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .foregroundColor(loginType == 0 ? .white : .secondary)
                .background(
                    Capsule()
                        .fill(loginType == 0 ? 
                            Color(red: 0.3, green: 0.7, blue: 0.3) : 
                            Color.gray.opacity(0.15))
                        .shadow(color: loginType == 0 ? 
                                Color(red: 0.3, green: 0.7, blue: 0.3).opacity(0.3) :
                                Color.clear, 
                                radius: 5, x: 0, y: 2)
                )
            }
            .buttonStyle(ButtonStyles.scale)
            
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    loginType = 1
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "person.3.fill")
                        .imageScale(.medium)
                    Text("Group")
                        .font(.subheadline)
                        .fontWeight(loginType == 1 ? .semibold : .medium)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .foregroundColor(loginType == 1 ? .white : .secondary)
                .background(
                    Capsule()
                        .fill(loginType == 1 ? 
                            Color(red: 0.93, green: 0.46, blue: 0.12) : 
                            Color.gray.opacity(0.15))
                        .shadow(color: loginType == 1 ? 
                                Color(red: 0.93, green: 0.46, blue: 0.12).opacity(0.3) :
                                Color.clear, 
                                radius: 5, x: 0, y: 2)
                )
            }
            .buttonStyle(ButtonStyles.scale)
        }
        .padding(.top, 10)
        .padding(.bottom, 5)
    }
    
    // MARK: - Form Fields - Enhanced with animations and improved styling
    
    private var formFields: some View {
        VStack(spacing: 16) {
            if isSignUp == 1 {
                // SIGN UP FIELDS with staggered animations
                ModernTextField(
                    placeholder: "First Name",
                    text: $firstName,
                    icon: "person.fill"
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .scale.combined(with: .opacity)
                ))
                
                ModernTextField(
                    placeholder: "Last Name",
                    text: $lastName,
                    icon: "person.fill"
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .scale.combined(with: .opacity)
                ))
            }
            
            // Common fields
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
            
            if loginType == 1 {
                ModernTextField(
                    placeholder: "Group Code",
                    text: $groupCode,
                    icon: "person.3.fill"
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .scale.combined(with: .opacity)
                ))
            }
            
            if isSignUp == 0 {
                // Remember password (login only) with improved styling
                Toggle(isOn: $rememberPassword) {
                    Text("Remember me")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .toggleStyle(SwitchToggleStyle(tint: primaryColor))
                .padding(.horizontal, 5)
                .padding(.top, 4)
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Action Buttons - Enhanced with improved styling
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            // Sign In / Sign Up Button
            Button(action: {
                // Add haptic feedback
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                
                isLoading = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    authenticateUser()
                    isLoading = false
                }
            }) {
                ZStack {
                    // Button text
                    Text(isSignUp == 1 ? "Create Account" : "Sign In")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .opacity(isLoading ? 0 : 1)
                    
                    // Loading indicator
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.2)
                    }
                }
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            primaryColor,
                            accentColor
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(25)
                .shadow(color: primaryColor.opacity(0.4), radius: 8, x: 0, y: 5)
            }
            .disabled(isLoading)
            .buttonStyle(ButtonStyles.scale)
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
    }
    
    // MARK: - Footer View
    
    private var footerView: some View {
        VStack(spacing: 25) {
            // Forgot password link (only for login)
            if isSignUp == 0 {
                Button(action: {
                    // Handle forgot password
                }) {
                    Text("Forgot your password?")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(primaryColor)
                }
                .buttonStyle(ButtonStyles.scale)
            }
            
            // Alternative sign in options
            VStack(spacing: 16) {
                Text("or continue with")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 20) {
                    socialSignInButton(imageName: "g.circle.fill", color: Color(red: 0.95, green: 0.3, blue: 0.25))
                    socialSignInButton(imageName: "f.square.fill", color: Color(red: 0.25, green: 0.4, blue: 0.95))
                    socialSignInButton(imageName: "applelogo", color: .black)
                }
            }
        }
    }
    
    // Social sign in button
    private func socialSignInButton(imageName: String, color: Color) -> some View {
        Button(action: {
            // Social sign in logic
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }) {
            Image(systemName: imageName)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                )
        }
        .buttonStyle(ButtonStyles.scale)
    }
    
    // MARK: - Authentication Logic
    
    private func authenticateUser(skipValidation: Bool = false) {
        // Perform validation if not skipping
        if !skipValidation {
            // Validate required fields
            if isSignUp == 1 {
                // Sign up validation
                if firstName.isEmpty || lastName.isEmpty {
                    showError = true
                    errorMessage = "Please enter your first and last name"
                    return
                }
            }
            
            if email.isEmpty {
                showError = true
                errorMessage = "Please enter your email"
                return
            }
            
            if password.isEmpty {
                showError = true
                errorMessage = "Please enter your password"
                return
            }
            
            if loginType == 1 && groupCode.isEmpty {
                showError = true
                errorMessage = "Please enter a group code"
                return
            }
        }
        
        // Run on background thread to avoid main thread I/O warning
        DispatchQueue.global(qos: .userInitiated).async {
            // Create user with proper firstName and lastName
            let user = AppModels.User(
                id: UUID().uuidString,
                firstName: self.firstName.isEmpty ? "Test" : self.firstName,
                lastName: self.lastName.isEmpty ? "User" : self.lastName,
                email: self.email,
                role: .volunteer
            )
            
            // Save user to persistence
            do {
                try PersistenceManager.shared.save(user, forKey: "currentUser")
                
                // Set authentication flags
                let defaults = UserDefaults.standard
                defaults.set(true, forKey: "hasSignedIn")
                defaults.set(true, forKey: "isAuthenticated")
                
                // Save password if requested (for login mode only)
                if self.isSignUp == 0 && self.rememberPassword {
                    // Note: In a real app, you would use Keychain for this
                    defaults.set(self.email, forKey: "savedEmail")
                    // In a real app, never store passwords in UserDefaults - use Keychain
                    // This is just for demonstration
                    defaults.set(self.password, forKey: "savedPassword") 
                }
                
                // Set UserDefaults for onboarding completion
                UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                
                // Post notifications on main thread
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .didUpdateAuth, object: nil)
                }
            } catch {
                print("Error saving user: \(error)")
                DispatchQueue.main.async {
                    self.showError = true
                    self.errorMessage = "Failed to save user data"
                }
            }
        }
    }
}

// Modern text field with icon - enhanced styling
struct ModernTextField: View {
    var placeholder: String
    @Binding var text: String
    var icon: String
    var keyboardType: UIKeyboardType = .default
    
    @State private var isFocused = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(isFocused ? ThemeManager.Colors.primary : ThemeManager.Colors.primary.opacity(0.6))
                .frame(width: 30)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
            
            TextField(placeholder, text: $text, onEditingChanged: { editing in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isFocused = editing
                }
            })
            .keyboardType(keyboardType)
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .font(.system(size: 17, weight: .regular))
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(isFocused ? 0.08 : 0.05), radius: isFocused ? 8 : 5, x: 0, y: isFocused ? 4 : 2)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isFocused ? ThemeManager.Colors.primary.opacity(0.5) : Color.gray.opacity(0.2), lineWidth: isFocused ? 1.5 : 1)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
        )
    }
}

// Modern secure field with icon - enhanced styling
struct ModernSecureField: View {
    var placeholder: String
    @Binding var text: String
    var icon: String
    
    @State private var isFocused = false
    @State private var showPassword = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(isFocused ? ThemeManager.Colors.primary : ThemeManager.Colors.primary.opacity(0.6))
                .frame(width: 30)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
            
            if showPassword {
                TextField(placeholder, text: $text, onEditingChanged: { editing in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isFocused = editing
                    }
                })
                .keyboardType(.default)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .font(.system(size: 17, weight: .regular))
            } else {
                SecureField(placeholder, text: $text)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .font(.system(size: 17, weight: .regular))
                    .onTapGesture {
                        withAnimation {
                            isFocused = true
                        }
                    }
            }
            
            Button(action: {
                showPassword.toggle()
            }) {
                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(Color.gray.opacity(0.6))
                    .font(.system(size: 15))
                    .padding(.trailing, 8)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(isFocused ? 0.08 : 0.05), radius: isFocused ? 8 : 5, x: 0, y: isFocused ? 4 : 2)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isFocused ? ThemeManager.Colors.primary.opacity(0.5) : Color.gray.opacity(0.2), lineWidth: isFocused ? 1.5 : 1)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
        )
    }
}

struct SimpleSignInView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleSignInView()
            .environmentObject(AppState())
    }
} 