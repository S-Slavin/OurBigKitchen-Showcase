import SwiftUI

// This wrapper ensures we always show standard login with a fresh instance
struct StandardLoginWrapper: View {
    // Remove the UUID that forces recreation of the view each time
    // @State private var uniqueID = UUID() // Force view recreation when sheet opens
    
    var body: some View {
        // Remove the ID modifier to prevent forced recreation
        LoginView()
            // .id(uniqueID)
            .onAppear {
                // Only log that we appeared without forcing recreation
                print("Login wrapper appeared")
            }
    }
} 