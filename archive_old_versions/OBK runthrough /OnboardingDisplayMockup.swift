import SwiftUI

struct OnboardingDisplayMockup: View {
    var body: some View {
        NavigationView {
            ZStack {
                // Warm background
                Color(red: 1.0, green: 0.95, blue: 0.9)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // OBK Logo with warm frame
                    ZStack {
                        Circle()
                            .fill(Color(red: 1.0, green: 0.6, blue: 0.3).opacity(0.1))
                            .frame(width: 100, height: 100)
                        
                        Text("OBK")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.3))
                            .overlay(
                                Circle()
                                    .stroke(Color(red: 1.0, green: 0.6, blue: 0.3), lineWidth: 2)
                            )
                    }
                    .padding(.top, 40)
                    
                    Spacer()
                    
                    // Main Content
                    VStack(spacing: 24) {
                        // Simple icon
                        Text("👥")
                            .font(.system(size: 80))
                            .padding(.bottom, 24)
                        
                        // Title
                        Text("Today's Recipients")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.3))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        
                        // Description
                        Text("See who needs your help today. Your meals make a real difference in their lives.")
                            .font(.system(size: 18))
                            .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.3))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .lineSpacing(6)
                    }
                    .padding(.top, 40)
                    
                    Spacer()
                    
                    // Bottom Navigation Bar
                    HStack(spacing: 0) {
                        NavigationLink(destination: Text("Home View")) {
                            VStack {
                                Text("Home")
                                    .font(.system(size: 16))
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        NavigationLink(destination: Text("Recipients View")) {
                            VStack {
                                Text("Recipients")
                                    .font(.system(size: 16))
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        NavigationLink(destination: Text("Profile View")) {
                            VStack {
                                Text("Profile")
                                    .font(.system(size: 16))
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.3))
                    .padding(.vertical, 16)
                    .background(Color.white)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// Preview Provider
struct OnboardingDisplayMockup_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OnboardingDisplayMockup()
                .previewDevice("iPhone 14 Pro")
                .previewDisplayName("iPhone 14 Pro")
            
            OnboardingDisplayMockup()
                .previewDevice("iPhone SE (3rd generation)")
                .previewDisplayName("iPhone SE")
        }
    }
} 