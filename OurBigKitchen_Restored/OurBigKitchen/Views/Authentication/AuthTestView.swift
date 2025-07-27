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
                    Button("Setup Test User") {
                        Task {
                            await TestUtils.createTestUser()
                            testResults.append("Test user created successfully")
                        }
                    }
                    
                    Button("Clear Test Data") {
                        Task {
                            await TestUtils.clearTestData()
                            testResults.append("Test data cleared successfully")
                        }
                    }
                    
                    Button("Show Current State") {
                        Task {
                            await TestUtils.printCurrentState()
                            testResults.append("Current state printed to console")
                        }
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
                NavigationView {
                    CorporateLoginView()
                        .environmentObject(AppState())
                }
            }
            .sheet(isPresented: $showSignUpView) {
                NavigationView {
                    CorporateSignInView()
                        .environmentObject(AppState())
                }
            }
            .sheet(isPresented: $showPasswordResetView) {
                PasswordResetView()
            }
        }
    }
}

#Preview {
    AuthTestView()
        .environmentObject(AppState())
} 