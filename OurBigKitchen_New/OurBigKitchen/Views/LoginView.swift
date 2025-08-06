import SwiftUI

struct LoginView: View {
    @State private var authViewModel = AuthViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 16) {
                        Image("AppLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120)
                            .background(Color.clear)
                        
                        Text("Welcome to OurBigKitchen")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(authViewModel.isSignUp ? "Create your account" : "Sign in to continue")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                    
                    // Form
                    VStack(spacing: 20) {
                        if authViewModel.isSignUp {
                            HStack(spacing: 12) {
                                TextField("First Name", text: $authViewModel.firstName)
                                    .textFieldStyle(RoundedTextFieldStyle())
                                
                                TextField("Last Name", text: $authViewModel.lastName)
                                    .textFieldStyle(RoundedTextFieldStyle())
                            }
                        }
                        
                        TextField("Email", text: $authViewModel.email)
                            .textFieldStyle(RoundedTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                        
                        SecureField("Password", text: $authViewModel.password)
                            .textFieldStyle(RoundedTextFieldStyle())
                        
                        if authViewModel.isSignUp {
                            SecureField("Confirm Password", text: $authViewModel.confirmPassword)
                                .textFieldStyle(RoundedTextFieldStyle())
                        }
                        
                        if !authViewModel.isSignUp {
                            HStack {
                                Toggle("Remember me", isOn: $authViewModel.rememberPassword)
                                    .font(.footnote)
                                Spacer()
                                Button("Forgot Password?") {
                                    // Handle forgot password
                                }
                                .font(.footnote)
                                .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Sign In/Up Button
                    Button(action: {
                        Task {
                            if authViewModel.isSignUp {
                                await authViewModel.signUp()
                            } else {
                                await authViewModel.signIn()
                            }
                        }
                    }) {
                        HStack {
                            if authViewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            
                            Text(authViewModel.isSignUp ? "Create Account" : "Sign In")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.orange, Color.red]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(28)
                        .disabled(authViewModel.isLoading)
                    }
                    .padding(.horizontal)
                    
                    // Toggle Mode
                    HStack {
                        Text(authViewModel.isSignUp ? "Already have an account?" : "Don't have an account?")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        
                        Button(authViewModel.isSignUp ? "Sign In" : "Sign Up") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                authViewModel.toggleMode()
                            }
                        }
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
        .alert("Error", isPresented: $authViewModel.showError) {
            Button("OK") {
                authViewModel.clearError()
            }
        } message: {
            Text(authViewModel.errorMessage)
        }
        .onChange(of: authViewModel.isAuthenticated) { _, isAuthenticated in
            if isAuthenticated {
                dismiss()
            }
        }
    }
}

// Custom TextField Style
struct RoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
    }
}

#Preview {
    LoginView()
} 