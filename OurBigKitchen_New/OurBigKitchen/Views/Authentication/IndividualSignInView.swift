import SwiftUI
import Combine

// Simple ViewModel for Individual Sign In
class IndividualSignInViewModel: ObservableObject {
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var password = ""
    @Published var hasAcceptedTerms = false
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    func loginAsIndividual() {
        guard !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty, !password.isEmpty, hasAcceptedTerms else {
            if !hasAcceptedTerms {
                errorMessage = "Please accept the terms and conditions"
            } else {
                errorMessage = "Please fill in all fields"
            }
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        // Simulate login process
        Task { @MainActor in
            await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            
            do {
                let user = AppModels.User(
                    id: UUID().uuidString,
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    role: .volunteer
                )
                try PersistenceManager.shared.save(user, forKey: "currentUser")
                UserDefaults.standard.set(true, forKey: "isAuthenticated")
                UserDefaults.standard.set(true, forKey: "hasSignedIn")
                NotificationCenter.default.post(name: .didUpdateAuth, object: nil)
            } catch {
                errorMessage = "Failed to save user data: \(error.localizedDescription)"
            }
            
            isLoading = false
        }
    }
    
    func loginWithApple() {
        guard hasAcceptedTerms else {
            errorMessage = "Please accept the terms and conditions"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        // Simulate Apple login
        Task { @MainActor in
            await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            
            do {
                let user = AppModels.User(
                    id: UUID().uuidString,
                    firstName: "Apple",
                    lastName: "User",
                    email: "apple.user@icloud.com",
                    role: .volunteer
                )
                try PersistenceManager.shared.save(user, forKey: "currentUser")
                UserDefaults.standard.set(true, forKey: "isAuthenticated")
                UserDefaults.standard.set(true, forKey: "hasSignedIn")
                NotificationCenter.default.post(name: .didUpdateAuth, object: nil)
            } catch {
                errorMessage = "Failed to save Apple user data: \(error.localizedDescription)"
            }
            
            isLoading = false
        }
    }
}

struct IndividualSignInView: View {
    @StateObject private var viewModel = IndividualSignInViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                Text("Individual Volunteer Sign In")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.top, 40)
                
                // Form Fields
                VStack(spacing: 16) {
                    TextField("First Name", text: $viewModel.firstName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.words)
                    
                    TextField("Last Name", text: $viewModel.lastName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.words)
                    
                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                // Terms and Conditions
                Toggle("I accept the terms and conditions", isOn: $viewModel.hasAcceptedTerms)
                    .padding(.horizontal)
                
                // Error Message
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                // Sign In Button
                Button(action: {
                    viewModel.loginAsIndividual()
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Sign In")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .disabled(viewModel.isLoading)
                .padding(.horizontal)
                
                // Apple Sign In Button
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
                    .padding()
                    .background(Color.black)
                    .cornerRadius(10)
                }
                .disabled(viewModel.isLoading)
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarBackButtonHidden(false)
    }
}

struct IndividualSignInView_Previews: PreviewProvider {
    static var previews: some View {
        IndividualSignInView()
    }
} 