import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Account")) {
                    if let user = appState.currentUser {
                        Text("Welcome, \(user.firstName) \(user.lastName)")
                            .font(.headline)
                            .padding()
                    }
                    
                    Button("Logout") {
                        AuthManager.shared.signOut()
                    }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Logout", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Logout", role: .destructive) {
                    appState.forceLogout()
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
        }
    }
} 