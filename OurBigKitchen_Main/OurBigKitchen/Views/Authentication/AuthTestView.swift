import SwiftUI

struct AuthTestView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var testResults: [String] = []
    @State private var showLoginView = false
    @State private var showSignUpView = false
    @State private var showPasswordResetView = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Test Actions")) {
                    Button("Create Test User") {
                        // TODO: Implement test user creation
                        print("Test user creation not implemented")
                    }
                    .buttonStyle(ButtonStyles.springy)
                    
                    Button("Clear Test Data") {
                        // TODO: Implement test data clearing
                        print("Test data clearing not implemented")
                    }
                    .buttonStyle(ButtonStyles.springy)
                    
                    Button("Print Current State") {
                        // TODO: Implement state printing
                        print("State printing not implemented")
                    }
                }
                
                Section(header: Text("Test Views")) {
                    Button("Show Login View") {
                        showLoginView = true
                    }
                    
                    Button("Show Sign Up View") {
                        showSignUpView = true
                    }
                    
                    Button("Show Password Reset View") {
                        showPasswordResetView = true
                    }
                }
                
                Section(header: Text("Test Results")) {
                    ForEach(testResults, id: \.self) { result in
                        Text(result)
                    }
                }
            }
            .navigationTitle("Auth Testing")
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
            .sheet(isPresented: $showLoginView) {
                VStack {
                    HStack {
                        Spacer()
                        Button("SKIP FOR DEMO") {
                            showLoginView = false
                        }
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 24)
                        .background(Color.orange)
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                        .padding()
                    }
                    
                    NavigationView {
                        CorporateLoginView()
                            .environmentObject(AppState())
                    }
                }
            }
            .sheet(isPresented: $showSignUpView) {
                VStack {
                    HStack {
                        Spacer()
                        Button("SKIP FOR DEMO") {
                            showSignUpView = false
                        }
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 24)
                        .background(Color.orange)
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                        .padding()
                    }
                    
                    NavigationView {
                        CorporateSignInView()
                            .environmentObject(AppState())
                    }
                }
            }
            .sheet(isPresented: $showPasswordResetView) {
                VStack {
                    HStack {
                        Spacer()
                        Button("SKIP FOR DEMO") {
                            showPasswordResetView = false
                        }
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 24)
                        .background(Color.orange)
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                        .padding()
                    }
                    
                    PasswordResetView()
                }
            }
        }
    }
}

#Preview {
    AuthTestView()
        .environmentObject(AppState())
} 