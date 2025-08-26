import SwiftUI
import UIKit

struct SimpleSignInView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var authViewModel = AuthViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var rememberPassword = false
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    // Animation states
    @State private var animateIn = false
    @State private var animateFields = false
    @State private var animateButtons = false
    
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
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Logo
                        Image("AppLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.4)
                            .padding(.top, geometry.size.height * 0.02)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                            .scaleEffect(animateIn ? 1.0 : 0.9)
                            .opacity(animateIn ? 1.0 : 0.0)
                        
                        // Welcome message
                        Text("Welcome Back!")
                            .font(.system(.title, design: .rounded, weight: .bold))
                            .foregroundColor(primaryColor)
                            .padding(.top, 8)
                            .padding(.bottom, 10)
                            .scaleEffect(animateIn ? 1.0 : 0.95)
                            .opacity(animateIn ? 1.0 : 0.0)
                        
                        // Subtitle
                        Text("Sign in to continue your journey")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 20)
                            .padding(.horizontal, 20)
                            .opacity(animateIn ? 0.8 : 0.0)
                        
                        // Login form
                        loginFormCard
                            .offset(y: animateFields ? 0 : 20)
                            .opacity(animateFields ? 1.0 : 0.0)
                        
                        // Footer options
                        footerView
                            .padding(.top, 15)
                            .offset(y: animateButtons ? 0 : 15)
                            .opacity(animateButtons ? 1.0 : 0.0)
                        
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
        }
        .navigationBarHidden(true)
        .transition(.opacity)
        .onReceive(authViewModel.$isAuthenticated) { isAuthenticated in
            print("DEBUG: SimpleSignInView - authViewModel.isAuthenticated changed to: \(isAuthenticated)")
            if isAuthenticated {
                print("DEBUG: Authentication successful, setting appState properties...")
                // User is authenticated, now they need to choose Individual/Corporate
                DispatchQueue.main.async {
                    appState.isAuthenticated = true
                    appState.needsToChooseVolunteerType = true
                    print("DEBUG: appState.isAuthenticated = \(appState.isAuthenticated)")
                    print("DEBUG: appState.needsToChooseVolunteerType = \(appState.needsToChooseVolunteerType)")
                    
                    // Force UI update
                    appState.objectWillChange.send()
                }
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
    }
    
    // MARK: - Login Form Card
    
    private var loginFormCard: some View {
        VStack(spacing: 20) {
            // Form fields
            VStack(spacing: 16) {
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
                
                // Remember password
                Toggle(isOn: $rememberPassword) {
                    Text("Remember me")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .toggleStyle(SwitchToggleStyle(tint: primaryColor))
                .padding(.horizontal, 5)
                .padding(.top, 4)
            }
            .padding(.horizontal, 20)
            
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
            
            // Sign In Button
            Button(action: {
                print("Sign In button tapped!")
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                
                // Set the published properties on the view model
                authViewModel.email = email
                authViewModel.password = password
                authViewModel.rememberPassword = rememberPassword
                
                print("Email: \(email), Password: \(password)")
                print("Calling authViewModel.signIn()...")
                
                // Call the parameterless signIn method
                Task {
                    await authViewModel.signIn()
                }
            }) {
                ZStack {
                    Text("Sign In")
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
            .disabled(isLoading)
            .buttonStyle(ButtonStyles.scale)
            .padding(.horizontal, 20)
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
    }
    
    // MARK: - Footer View
    
    private var footerView: some View {
        VStack(spacing: 25) {
            // Forgot password link
            Button(action: {
                // Handle forgot password
            }) {
                Text("Forgot your password?")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(primaryColor)
            }
            .buttonStyle(ButtonStyles.scale)
            
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
    
    // MARK: - Animations
    
    private func startAnimations() {
        withAnimation(.easeOut(duration: 0.3)) {
            animateIn = true
        }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.1)) {
            animateFields = true
        }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.2)) {
            animateButtons = true
        }
    }
}

// MARK: - Preview

struct SimpleSignInView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleSignInView()
            .environmentObject(AppState())
    }
} 