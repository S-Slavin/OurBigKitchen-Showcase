import SwiftUI

struct AuthTypeSelectionView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedAction: AuthAction = .signIn
    @State private var showSignInView = false
    @State private var showSignUpView = false
    
    private let primaryColor = ThemeManager.Colors.primary
    private let accentColor = ThemeManager.Colors.accent
    private let backgroundColor = Color(red: 1.0, green: 0.98, blue: 0.94)
    
    enum AuthAction {
        case signIn
        case signUp
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Logo
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 120)
                .padding(.top, 40)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)

            Text("Welcome to Our Big Kitchen")
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundColor(primaryColor)
                .padding(.top, 8)
                .padding(.bottom, 10)
            
            Text("Choose how you'd like to get started")
                .font(.subheadline)
                .foregroundColor(accentColor)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
            
            // Auth Action Selection (Sign In vs Sign Up)
            VStack(spacing: 16) {
                Text("I want to:")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.bottom, 10)
                
                HStack(spacing: 12) {
                    AuthActionButton(
                        title: "Sign In",
                        subtitle: "Already have an account",
                        icon: "person.fill",
                        isSelected: selectedAction == .signIn,
                        primaryColor: primaryColor,
                        accentColor: accentColor
                    ) {
                        print("DEBUG: Sign In button tapped!")
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedAction = .signIn
                        }
                        print("DEBUG: selectedAction set to: \(selectedAction)")
                    }
                    
                    AuthActionButton(
                        title: "Sign Up",
                        subtitle: "Create new account",
                        icon: "person.badge.plus.fill",
                        isSelected: selectedAction == .signUp,
                        primaryColor: primaryColor,
                        accentColor: accentColor
                    ) {
                        print("DEBUG: Sign Up button tapped!")
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedAction = .signUp
                        }
                        print("DEBUG: selectedAction set to: \(selectedAction)")
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Skip for Demo button
            Button(action: {
                print("DEBUG: Skip for Demo tapped on AuthTypeSelectionView")
                // Skip to main app
                DispatchQueue.main.async {
                    appState.isAuthenticated = true
                    appState.hasAcceptedTerms = true
                    appState.hasAcceptedHealthProtocols = true
                    appState.needsToChooseVolunteerType = false
                    appState.objectWillChange.send()
                }
            }) {
                Text("Skip for Demo")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .cornerRadius(12)
            }
            .padding(.bottom, 20)
            
            // Continue Button
            Button(action: {
                print("DEBUG: Continue button tapped!")
                print("DEBUG: selectedAction = \(selectedAction)")
                print("DEBUG: showSignUpView before = \(showSignUpView)")
                
                if selectedAction == .signIn {
                    print("DEBUG: Navigating to Sign In")
                    showSignInView = true
                } else {
                    print("DEBUG: Navigating to Sign Up")
                    showSignUpView = true
                    print("DEBUG: showSignUpView after = \(showSignUpView)")
                }
            }) {
                Text(selectedAction == .signIn ? "Sign In" : "Continue to Sign Up")
                    .font(.headline)
                    .fontWeight(.semibold)
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
                    .cornerRadius(25)
                    .shadow(color: primaryColor.opacity(0.4), radius: 8, x: 0, y: 5)
            }
            .buttonStyle(ButtonStyles.scale)
            .padding(.horizontal)
            .padding(.bottom, 30)
            

        }
        .background(backgroundColor)
        .edgesIgnoringSafeArea(.all)
        .sheet(isPresented: $showSignInView) {
            NavigationView {
                SimpleSignInView()
            }
        }
        .sheet(isPresented: $showSignUpView) {
            NavigationView {
                RegistrationSignupSlidesView()
            }
        }
    }
}

// MARK: - Auth Action Button

struct AuthActionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let isSelected: Bool
    let primaryColor: Color
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : primaryColor)
                    .frame(width: 40)
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? 
                        AnyShapeStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [primaryColor, accentColor]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        ) : 
                        AnyShapeStyle(Color.white.opacity(0.8))
                    )
            )
            .shadow(color: isSelected ? primaryColor.opacity(0.4) : Color.black.opacity(0.07), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}



struct AuthTypeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        AuthTypeSelectionView()
            .environmentObject(AppState())
    }
} 