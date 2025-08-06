import XCTest
import ComposableArchitecture
@testable import OurBigKitchen

@MainActor
final class AuthenticationFeatureTests: XCTestCase {
    func testEmailChanged() async {
        let store = TestStore(
            initialState: AuthenticationFeature.State(),
            reducer: AuthenticationFeature()
        )
        
        await store.send(.emailChanged("test@example.com")) {
            $0.email = "test@example.com"
        }
    }
    
    func testPasswordChanged() async {
        let store = TestStore(
            initialState: AuthenticationFeature.State(),
            reducer: AuthenticationFeature()
        )
        
        await store.send(.passwordChanged("password123")) {
            $0.password = "password123"
        }
    }
    
    func testSuccessfulLogin() async {
        let store = TestStore(
            initialState: AuthenticationFeature.State(),
            reducer: AuthenticationFeature()
        ) {
            $0.auth = AuthClient(
                login: { _, _ in
                    User(id: "test-id", email: "test@example.com")
                },
                isAuthenticated: { true },
                logout: { }
            )
        }
        
        await store.send(.loginTapped) {
            $0.isLoading = true
            $0.error = nil
        }
        
        await store.receive(.loginResponse(.success(User(id: "test-id", email: "test@example.com")))) {
            $0.isLoading = false
        }
        
        await store.receive(.delegate(.didAuthenticate))
    }
    
    func testFailedLogin() async {
        let store = TestStore(
            initialState: AuthenticationFeature.State(),
            reducer: AuthenticationFeature()
        ) {
            $0.auth = AuthClient(
                login: { _, _ in
                    throw AuthError.invalidCredentials
                },
                isAuthenticated: { false },
                logout: { }
            )
        }
        
        await store.send(.loginTapped) {
            $0.isLoading = true
            $0.error = nil
        }
        
        await store.receive(.loginResponse(.failure(AuthError.invalidCredentials))) {
            $0.isLoading = false
            $0.error = AuthError.invalidCredentials.localizedDescription
        }
    }
    
    func testSuccessfulLogout() async {
        let store = TestStore(
            initialState: AuthenticationFeature.State(),
            reducer: AuthenticationFeature()
        ) {
            $0.auth = AuthClient(
                login: { _, _ in
                    User(id: "test-id", email: "test@example.com")
                },
                isAuthenticated: { false },
                logout: { }
            )
        }
        
        await store.send(.logoutTapped) {
            $0.isLoading = true
        }
        
        await store.receive(.logoutResponse(.success(()))) {
            $0.isLoading = false
        }
        
        await store.receive(.delegate(.didLogout))
    }
    
    func testFailedLogout() async {
        let store = TestStore(
            initialState: AuthenticationFeature.State(),
            reducer: AuthenticationFeature()
        ) {
            $0.auth = AuthClient(
                login: { _, _ in
                    User(id: "test-id", email: "test@example.com")
                },
                isAuthenticated: { true },
                logout: {
                    throw AuthError.unknown
                }
            )
        }
        
        await store.send(.logoutTapped) {
            $0.isLoading = true
        }
        
        await store.receive(.logoutResponse(.failure(AuthError.unknown))) {
            $0.isLoading = false
            $0.error = AuthError.unknown.localizedDescription
        }
    }
} 