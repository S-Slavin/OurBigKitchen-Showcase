import SwiftUI

struct AuthTypeSelectionView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedType: AuthType = .volunteer
    @State private var selectedAction: AuthAction = .signIn
    @State private var showSignInView = false
    @State private var showSignUpView = false
    
    private let primaryColor = ThemeManager.Colors.primary
    private let accentColor = ThemeManager.Colors.accent
    private let backgroundColor = Color(red: 1.0, green: 0.98, blue: 0.94)
    
    enum AuthType {
        case volunteer
        case corporate
    }
    
    enum AuthAction {
        case signIn
        case signUp
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    // Modern background
                    LinearGradient(
                        gradient: Gradient(colors: [backgroundColor, backgroundColor.opacity(0.95), Color(red: 1.0, green: 0.92, blue: 0.86)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .edgesIgnoringSafeArea(.all)

                    VStack(spacing: 24) {
                        // Logo
                        Image("AppLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.4)
                            .padding(.top, geometry.size.height * 0.02)
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
                                    selectedAction = .signIn
                                }
                                
                                AuthActionButton(
                                    title: "Sign Up",
                                    subtitle: "Create new account",
                                    icon: "person.badge.plus.fill",
                                    isSelected: selectedAction == .signUp,
                                    primaryColor: primaryColor,
                                    accentColor: accentColor
                                ) {
                                    selectedAction = .signUp
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Volunteer Type Selection (only for sign up)
                        if selectedAction == .signUp {
                            VStack(spacing: 16) {
                                Text("I will volunteer as:")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .padding(.top, 20)
                                    .padding(.bottom, 10)
                                
                                VStack(spacing: 16) {
                                    AuthTypeButton(
                                        title: "Individual Volunteer",
                                        subtitle: "Volunteer on your own",
                                        icon: "person.fill",
                                        isSelected: selectedType == .volunteer,
                                        primaryColor: primaryColor,
                                        accentColor: accentColor
                                    ) {
                                        selectedType = .volunteer
                                    }
                                    
                                    AuthTypeButton(
                                        title: "Corporate/Group",
                                        subtitle: "Volunteer with your organization",
                                        icon: "building.2.fill",
                                        isSelected: selectedType == .corporate,
                                        primaryColor: primaryColor,
                                        accentColor: accentColor
                                    ) {
                                        selectedType = .corporate
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        Spacer()
                        
                        // Continue Button
                        Button(action: {
                            if selectedAction == .signIn {
                                showSignInView = true
                            } else {
                                showSignUpView = true
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
                    .padding(.top, geometry.safeAreaInsets.top + 20)
                    .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(true)
        }
        .navigationDestination(isPresented: $showSignInView) {
            SimpleSignInView()
        }
        .navigationDestination(isPresented: $showSignUpView) {
            RegistrationSignupSlidesView()
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

// MARK: - Auth Type Button

struct AuthTypeButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let isSelected: Bool
    let primaryColor: Color
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : primaryColor)
                    .frame(width: 40)
                
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
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