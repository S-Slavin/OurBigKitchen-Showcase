import Foundation
import ComposableArchitecture

@Reducer
public struct ProfileFeature {
    @ObservableState
    public struct State: Equatable {
        public var user: AppModels.User?
        public var isLoading = false
        public var showingSettings = false
        
        public init() {}
    }
    
    public enum Action: Equatable {
        case onAppear
        case loadProfile
        case profileLoaded(AppModels.User)
        case showSettings
        case hideSettings
        case signOut
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.loadProfile)
                
            case .loadProfile:
                state.isLoading = true
                return .run { send in
                    // Mock profile loading
                    try await Task.sleep(for: .milliseconds(500))
                    let mockUser = AppModels.User(
                        id: UUID(),
                        firstName: "Test",
                        lastName: "User",
                        email: "test@example.com",
                        role: .individual
                    )
                    await send(.profileLoaded(mockUser))
                }
                
            case .profileLoaded(let user):
                state.isLoading = false
                state.user = user
                return .none
                
            case .showSettings:
                state.showingSettings = true
                return .none
                
            case .hideSettings:
                state.showingSettings = false
                return .none
                
            case .signOut:
                state.user = nil
                return .none
            }
        }
    }
} 