import SwiftUI

struct SimpleTermsView: View {
    @EnvironmentObject var appState: AppState
    @State private var hasReadTerms = false
    
    // Warm color scheme to match app theme
    private let primaryColor = Color(red: 0.93, green: 0.46, blue: 0.12) // Orange
    private let backgroundColor = Color(red: 1.0, green: 0.98, blue: 0.94) // Cream
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    // Background that fills the entire screen
                    backgroundColor.edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 0) {
                        // Logo with fallback
                        Image("AppLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.6, height: geometry.size.height * 0.15)
                            .padding(.top, geometry.size.height * 0.03)
                            .background(
                                Image(systemName: "heart.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: geometry.size.height * 0.12)
                                    .foregroundColor(primaryColor)
                                    .opacity(0.0001) // Almost invisible but shown if AppLogo fails
                            )
                            .onAppear {
                                print("SimpleTermsView appeared")
                            }
                        
                        Text("Terms and Conditions")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(primaryColor)
                            .padding(.top, geometry.size.height * 0.01)
                        
                        // Terms content in a scrollable container with fixed height
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Welcome to Our Big Kitchen!")
                                    .font(.headline)
                                
                                Text("By using this application, you agree to the following terms and conditions:")
                                
                                Group {
                                    Text("1. Privacy Policy")
                                        .fontWeight(.semibold)
                                    Text("We respect your privacy and are committed to protecting your personal data. Our Privacy Policy outlines how we collect, use, and store your information.")
                                    
                                    Text("2. User Responsibilities")
                                        .fontWeight(.semibold)
                                    Text("Users are responsible for maintaining the confidentiality of their account information and for all activities that occur under their account.")
                                    
                                    Text("3. Volunteer Commitments")
                                        .fontWeight(.semibold)
                                    Text("When registering for volunteer activities, you commit to attending as scheduled. Please provide at least 24 hours notice if you need to cancel.")
                                    
                                    Text("4. Content Sharing")
                                        .fontWeight(.semibold)
                                    Text("By sharing content through the app, you grant Our Big Kitchen a non-exclusive license to use, reproduce, and distribute that content for promotional purposes.")
                                }
                            }
                            .padding()
                        }
                        .frame(height: geometry.size.height * 0.4)
                        .background(Color.white.opacity(0.5))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        // Make the toggle very prominent with improved touch target
                        Button(action: {
                            // Toggle the value when the entire button is tapped
                            hasReadTerms.toggle()
                            print("Toggle tapped, now: \(hasReadTerms)")
                        }) {
                            HStack {
                                Image(systemName: hasReadTerms ? "checkmark.square.fill" : "square")
                                    .font(.system(size: 22))
                                    .foregroundColor(hasReadTerms ? primaryColor : .gray)
                                    .padding(.trailing, 8)
                                
                                Text("I have read and agree to the terms and conditions")
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            .padding()
                            .background(Color.white.opacity(0.3))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(hasReadTerms ? primaryColor : Color.gray.opacity(0.5), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal)
                        .padding(.top, geometry.size.height * 0.02)
                        .buttonStyle(PlainButtonStyle())
                        .contentShape(Rectangle())
                        
                        // Accept Terms button - larger and more prominent
                        Button(action: {
                            acceptTerms()
                        }) {
                            Text("Accept Terms")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16) // Larger vertical padding
                                .background(
                                    hasReadTerms ? 
                                    primaryColor : Color.gray
                                )
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(!hasReadTerms)
                        .padding(.horizontal)
                        .padding(.top, geometry.size.height * 0.02)
                        .buttonStyle(PlainButtonStyle())
                        .contentShape(Rectangle())
                        
                        // Skip button - clear and prominent
                        Button(action: {
                            acceptTerms()
                        }) {
                            HStack {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.system(size: 24))
                                Text("SKIP FOR DEMO")
                                    .font(.title)
                                    .fontWeight(.black)
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 24)
                            .padding(.horizontal, 36)
                            .background(Color.orange)
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                        }
                        .padding(.top, 30)
                        .padding(.bottom, 30)
                        
                        Spacer(minLength: geometry.size.height * 0.05)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .onAppear {
                        print("SimpleTermsView onAppear - appState.hasAcceptedTerms: \(appState.hasAcceptedTerms)")
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .transition(.opacity)
        .edgesIgnoringSafeArea(.all)
    }
    
    private func acceptTerms() {
        print("Accepting terms...")
        
        Task { @MainActor in
            // Update UserDefaults in a single batch
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: "termsAccepted")
            defaults.set(true, forKey: "hasAcceptedTerms")
            defaults.set(false, forKey: "hasAcceptedHealthProtocols")
            
            // Reset health protocols to ensure it's not skipped
            appState.resetHealthProtocols()
            
            // Update AppState for terms
            appState.acceptTerms()
            
            // Post a single notification to trigger UI updates
            NotificationCenter.default.post(name: .didUpdateTerms, object: nil)
        }
    }
}

#Preview {
    SimpleTermsView()
        .environmentObject(AppState())
} 