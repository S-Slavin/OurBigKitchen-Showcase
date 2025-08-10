import SwiftUI

struct PasswordResetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var resetToken = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var showSuccess = false
    @State private var currentStep: ResetStep = .requestReset
    
    enum ResetStep {
        case requestReset
        case enterToken
        case enterNewPassword
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                Text(headerText)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                
                Text(subheaderText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                
                // Form
                VStack(spacing: 16) {
                    switch currentStep {
                    case .requestReset:
                        requestResetView
                    case .enterToken:
                        enterTokenView
                    case .enterNewPassword:
                        enterNewPasswordView
                    }
                }
                .padding(.horizontal)
                
                // Error Message
                if showError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                // Success Message
                if showSuccess {
                    Text("Password reset successful! You can now log in with your new password.")
                        .foregroundColor(.green)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                // Action Button
                Button(action: handleAction) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text(buttonText)
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
                
                Spacer()
            }
            .navigationBarTitle("Reset Password", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
    
    private var requestResetView: some View {
        TextField("Email", text: $email)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .keyboardType(.emailAddress)
            .textContentType(.emailAddress)
            .autocapitalization(.none)
    }
    
    private var enterTokenView: some View {
        TextField("Reset Token", text: $resetToken)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .autocapitalization(.none)
    }
    
    private var enterNewPasswordView: some View {
        VStack(spacing: 16) {
            SecureField("New Password", text: $newPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textContentType(.newPassword)
            
            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textContentType(.newPassword)
        }
    }
    
    private var headerText: String {
        switch currentStep {
        case .requestReset:
            return "Reset Password"
        case .enterToken:
            return "Enter Reset Token"
        case .enterNewPassword:
            return "Create New Password"
        }
    }
    
    private var subheaderText: String {
        switch currentStep {
        case .requestReset:
            return "Enter your email address and we'll send you a reset token"
        case .enterToken:
            return "Enter the reset token sent to your email"
        case .enterNewPassword:
            return "Create a new password for your account"
        }
    }
    
    private var buttonText: String {
        switch currentStep {
        case .requestReset:
            return "Send Reset Token"
        case .enterToken:
            return "Verify Token"
        case .enterNewPassword:
            return "Reset Password"
        }
    }
    
    private var isFormValid: Bool {
        switch currentStep {
        case .requestReset:
            return ValidationUtils.isValidEmail(email)
        case .enterToken:
            return !resetToken.isEmpty
        case .enterNewPassword:
            return ValidationUtils.isValidPassword(newPassword) && newPassword == confirmPassword
        }
    }
    
    private func handleAction() {
        guard isFormValid else { return }
        
        isLoading = true
        errorMessage = ""
        showError = false
        
        Task {
            do {
                switch currentStep {
                case .requestReset:
                    try await PasswordResetService.shared.requestPasswordReset(email: email)
                    currentStep = .enterToken
                case .enterToken:
                    // Verify token exists
                    if let _ = try? PersistenceManager.shared.load(PasswordResetRequest.self, forKey: "passwordReset_\(email)") {
                        currentStep = .enterNewPassword
                    } else {
                        throw PasswordResetError.invalidToken
                    }
                case .enterNewPassword:
                    try await PasswordResetService.shared.resetPassword(
                        email: email,
                        token: resetToken,
                        newPassword: newPassword
                    )
                    showSuccess = true
                    // Dismiss after a short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        dismiss()
                    }
                }
            } catch let error as PasswordResetError {
                errorMessage = error.localizedDescription
                showError = true
            } catch {
                errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
                showError = true
            }
            
            isLoading = false
        }
    }
} 