import SwiftUI

struct RegistrationTestView: View {
    @State private var selectedScenario: MockRegistrationService.MockScenario = .success
    @State private var showRegistrationFlow = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("Test Scenarios") {
                    Button("Success") {
                        selectedScenario = .success
                        showRegistrationFlow = true
                    }
                    
                    Button("Network Error") {
                        selectedScenario = .networkError
                        showRegistrationFlow = true
                    }
                    
                    Button("Invalid Data") {
                        selectedScenario = .invalidData
                        showRegistrationFlow = true
                    }
                    
                    Button("Server Error") {
                        selectedScenario = .serverError
                        showRegistrationFlow = true
                    }
                    
                    Button("Delayed Success (3s)") {
                        selectedScenario = .delayedSuccess(delay: 3)
                        showRegistrationFlow = true
                    }
                }
            }
            .navigationTitle("Registration Tests")
            .fullScreenCover(isPresented: $showRegistrationFlow) {
                RegistrationFlowView(mockService: MockRegistrationService(scenario: selectedScenario))
                    .environmentObject(ImpactService.shared)
            }
        }
    }
}

#Preview {
    RegistrationTestView()
} 