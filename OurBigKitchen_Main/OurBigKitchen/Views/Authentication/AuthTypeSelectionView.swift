import SwiftUI

struct AuthTypeSelectionView: View {
    @EnvironmentObject var appState: AppState
    @State private var showSignUpView = false
    
    private let primaryColor = ThemeManager.Colors.primary
    private let accentColor = ThemeManager.Colors.accent
    private let backgroundColor = Color(red: 1.0, green: 0.98, blue: 0.94)
    
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
            
            Text("Let's get you started with your volunteer journey")
                .font(.subheadline)
                .foregroundColor(accentColor)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
            
            // Direct Sign Up Button
            VStack(spacing: 16) {
                Text("Ready to make a difference?")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.bottom, 10)
                
                Button(action: {
                    print("DEBUG: Sign Up button tapped!")
                    showSignUpView = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "person.badge.plus.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        VStack(spacing: 4) {
                            Text("Get Started")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("Create your volunteer account")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
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
                
                // Sign In Option (smaller, secondary)
                Button(action: {
                    print("DEBUG: Sign In button tapped!")
                    // TODO: Add sign in functionality if needed
                }) {
                    Text("Already have an account? Sign In")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .underline()
                }
                .padding(.top, 8)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .background(backgroundColor)
        .edgesIgnoringSafeArea(.all)
        .sheet(isPresented: $showSignUpView) {
            NavigationView {
                RegistrationSignupSlidesView()
            }
        }
    }
}

struct AuthTypeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        AuthTypeSelectionView()
            .environmentObject(AppState())
    }
} 