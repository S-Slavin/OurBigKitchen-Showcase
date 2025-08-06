import SwiftUI
import UIKit

struct WWCAuthView: View {
    @EnvironmentObject var appState: AppState
    @State private var isSignUp = 0   // 0 = Login, 1 = Sign Up
    @State private var animateIn = false
    @State private var animateFields = false
    @State private var animateButtons = false
    
    // Warm color scheme to match app theme
    private let primaryColor = ThemeManager.Colors.primary
    private let accentColor = ThemeManager.Colors.accent
    private let backgroundColor = Color(red: 1.0, green: 0.98, blue: 0.94) // Cream
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background layer
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
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Logo with animation
                        Image("AppLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.4)
                            .padding(.top, geometry.size.height * 0.02)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                            .scaleEffect(animateIn ? 1.0 : 0.9)
                            .opacity(animateIn ? 1.0 : 0.0)
                        
                        // Welcome message
                        Text("WWC Volunteer Authentication")
                            .font(.system(.title, design: .rounded, weight: .bold))
                            .foregroundColor(primaryColor)
                            .padding(.top, 8)
                            .padding(.bottom, 10)
                            .scaleEffect(animateIn ? 1.0 : 0.95)
                            .opacity(animateIn ? 1.0 : 0.0)
                        
                        // Subtitle
                        Text("Please select your authentication method")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 20)
                            .padding(.horizontal, 20)
                            .opacity(animateIn ? 0.8 : 0.0)
                        
                        // Main form card
                        VStack(spacing: 20) {
                            // Login/Sign Up Toggle
                            loginSignUpToggle
                            
                            // Continue Button
                            NavigationLink(
                                destination: destinationView,
                                label: {
                                    Text("Continue")
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
                            )
                            .buttonStyle(ButtonStyles.scale)
                        }
                        .padding(.vertical, 25)
                        .padding(.horizontal, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color.white.opacity(0.8))
                                .shadow(color: Color.black.opacity(0.07), radius: 20, x: 0, y: 10)
                        )
                        .padding(.horizontal, 20)
                        .offset(y: animateFields ? 0 : 20)
                        .opacity(animateFields ? 1.0 : 0.0)
                        
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
    }
    
    // Start animation sequence
    private func startAnimations() {
        withAnimation(.easeOut(duration: 0.6)) {
            animateIn = true
        }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
            animateFields = true
        }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.4)) {
            animateButtons = true
        }
    }
    
    // MARK: - Login/SignUp Toggle
    
    private var loginSignUpToggle: some View {
        HStack(spacing: 0) {
            // Login pill
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isSignUp = 0
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
        .background(
            Capsule()
                .fill(Color.gray.opacity(0.1))
        )
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private var destinationView: some View {
        switch isSignUp {
        case 0:
            WWCLoginView()
        case 1:
            WWCSignInView()
        default:
            WWCLoginView()
        }
    }
}

struct WWCAuthView_Previews: PreviewProvider {
    static var previews: some View {
        WWCAuthView()
            .environmentObject(AppState())
    }
} 