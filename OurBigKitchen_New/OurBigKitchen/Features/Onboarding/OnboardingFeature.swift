import Foundation
import ComposableArchitecture

@Reducer
public struct OnboardingFeature {
    @ObservableState
    public struct State: Equatable {
        public var currentPage = 0
        public var hasCompletedOnboarding = false
        
        public init() {}
    }
    
    public enum Action: Equatable {
        case nextPage
        case previousPage
        case completeOnboarding
        case skipOnboarding
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .nextPage:
                state.currentPage += 1
                return .none
                
            case .previousPage:
                if state.currentPage > 0 {
                    state.currentPage -= 1
                }
                return .none
                
            case .completeOnboarding, .skipOnboarding:
                state.hasCompletedOnboarding = true
                return .none
            }
        }
    }
} 