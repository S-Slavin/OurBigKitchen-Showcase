@MainActor
class UserSessionManager: ObservableObject {
    @Published private(set) var isAuthenticated = false
    @Published private(set) var currentUser: User?
    private let viewModel: AuthenticationViewModel
    
    init() {
        self.viewModel = AuthenticationViewModel()
    }
    
    func signIn() async throws {
        try await viewModel.signIn()
        isAuthenticated = true
        currentUser = viewModel.currentUser
    }
    
    func signOut() {
        viewModel.signOut()
        isAuthenticated = false
        currentUser = nil
    }
} 