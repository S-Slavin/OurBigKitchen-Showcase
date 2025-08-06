import XCTest
import ComposableArchitecture
@testable import OurBigKitchen

@MainActor
final class AppFeatureTests: XCTestCase {
    func testInitialState() async {
        let store = TestStore(
            initialState: AppFeature.State(),
            reducer: AppFeature()
        )
        
        // App should start in onboarding state
        guard case .onboarding = store.state else {
            XCTFail("App should start in onboarding state")
            return
        }
    }
    
    func testCompleteFlow() async {
        let store = TestStore(
            initialState: AppFeature.State(),
            reducer: AppFeature()
        ) {
            $0.auth = AuthClient(
                login: { _, _ in
                    User(id: "test-id", email: "test@example.com")
                },
                isAuthenticated: { true },
                logout: { }
            )
        }
        
        // 1. Complete onboarding
        await store.send(.onboarding(.delegate(.didCompleteOnboarding))) {
            $0 = .authentication(AuthenticationFeature.State())
        }
        
        // 2. Authenticate
        await store.send(.authentication(.delegate(.didAuthenticate))) {
            $0 = .main(MainFeature.State())
        }
        
        // 3. Logout
        await store.send(.authentication(.delegate(.didLogout))) {
            $0 = .onboarding(OnboardingFeature.State())
        }
    }
    
    func testOnboardingToAuthTransition() async {
        let store = TestStore(
            initialState: AppFeature.State(),
            reducer: AppFeature()
        )
        
        await store.send(.onboarding(.delegate(.didCompleteOnboarding))) {
            $0 = .authentication(AuthenticationFeature.State())
        }
    }
    
    func testAuthToMainTransition() async {
        let store = TestStore(
            initialState: .authentication(AuthenticationFeature.State()),
            reducer: AppFeature()
        )
        
        await store.send(.authentication(.delegate(.didAuthenticate))) {
            $0 = .main(MainFeature.State())
        }
    }
    
    func testMainToOnboardingTransition() async {
        let store = TestStore(
            initialState: .main(MainFeature.State()),
            reducer: AppFeature()
        )
        
        await store.send(.authentication(.delegate(.didLogout))) {
            $0 = .onboarding(OnboardingFeature.State())
        }
    }
    
    func testOnboardingOnlyAppearsAtStart() async {
        let store = TestStore(
            initialState: AppFeature.State(),
            reducer: AppFeature()
        )
        
        // 1. Complete onboarding
        await store.send(.onboarding(.delegate(.didCompleteOnboarding))) {
            $0 = .authentication(AuthenticationFeature.State())
        }
        
        // 2. Authenticate
        await store.send(.authentication(.delegate(.didAuthenticate))) {
            $0 = .main(MainFeature.State())
        }
        
        // 3. Logout and verify we go back to onboarding as specified
        await store.send(.authentication(.delegate(.didLogout))) {
            $0 = .onboarding(OnboardingFeature.State())
        }
    }
} 