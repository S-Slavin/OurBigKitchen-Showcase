import Foundation
import SwiftUI

struct ResetAppState {
    static func resetOnboardingFlow() {
        print("DEBUG: Starting app onboarding state reset")
        
        // Reset all UserDefaults that control the onboarding flow
        let defaults = UserDefaults.standard
        
        // First batch - authentication related
        defaults.set(false, forKey: "hasSeenOnboarding")
        defaults.set(false, forKey: "hasSignedIn")
        defaults.set(false, forKey: "isAuthenticated")
        
        // Second batch - terms related
        defaults.set(false, forKey: "hasAcceptedTerms")
        defaults.set(false, forKey: "termsAccepted")
        defaults.set(false, forKey: "com.ourbigkitchen.hasCompletedOnboarding")
        
        // Third batch - other settings
        defaults.set(false, forKey: "hasAcceptedHealthProtocols")
        
        // Ensure changes are written immediately
        defaults.synchronize()
        
        print("DEBUG: UserDefaults reset complete")
        
        // Post notifications with a small delay between them to avoid race conditions
        DispatchQueue.main.async {
            // First notify of auth changes
            NotificationCenter.default.post(name: .didUpdateAuth, object: nil)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // Then notify of terms changes
                NotificationCenter.default.post(name: .didUpdateTerms, object: nil)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    // Finally notify of health protocol changes
                    NotificationCenter.default.post(name: .didUpdateHealthProtocols, object: nil)
                    
                    print("DEBUG: All reset notifications posted")
                }
            }
        }
    }
}

// A utility view to reset the app state for development
struct ResetOnboardingButton: View {
    var body: some View {
        Button("Reset Onboarding") {
            ResetAppState.resetOnboardingFlow()
        }
        .padding()
        .background(Color.red.opacity(0.8))
        .foregroundColor(.white)
        .cornerRadius(10)
    }
}

#Preview {
    ResetOnboardingButton()
} 