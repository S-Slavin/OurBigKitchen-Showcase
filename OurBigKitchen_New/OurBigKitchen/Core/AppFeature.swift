import Foundation
import ComposableArchitecture

@Reducer
public struct AppFeature {
    @ObservableState
    public enum State: Equatable {
        case onboarding(OnboardingFeature.State)
        case authentication(AuthenticationFeature.State)
        case main(MainFeature.State)
        
        public init() {
            self = .onboarding(OnboardingFeature.State())
        }
    }
    
    public enum Action: Equatable {
        case onboarding(OnboardingFeature.Action)
        case authentication(AuthenticationFeature.Action)
        case main(MainFeature.Action)
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.onboarding, action: \.onboarding) {
            OnboardingFeature()
        }
        Scope(state: \.authentication, action: \.authentication) {
            AuthenticationFeature()
        }
        Scope(state: \.main, action: \.main) {
            MainFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .onboarding(.completeOnboarding):
                state = .authentication(AuthenticationFeature.State())
                return .none
                
            case .authentication(.signInTapped):
                state = .main(MainFeature.State())
                return .none
                
            case .onboarding, .authentication, .main:
                return .none
            }
        }
    }
} 