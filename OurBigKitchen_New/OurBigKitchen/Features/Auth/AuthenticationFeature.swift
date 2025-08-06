import Foundation
import ComposableArchitecture

public struct AuthenticationFeature: Reducer {
    public struct State: Equatable {
        public var email = ""
        public var password = ""
        public var isLoading = false
        public var error: String?
        
        public init() {}
    }
    
    public enum Action: Equatable {
        case emailChanged(String)
        case passwordChanged(String)
        case loginTapped
        case signInTapped  // Add the missing action that AppFeature expects
        case loginResponse(TaskResult<AppModels.User>)
        case logoutTapped
        case logoutResponse(TaskResult<Void>)
        case delegate(Delegate)
        
        public enum Delegate: Equatable {
            case didAuthenticate
            case didLogout
        }
    }
    
    @Dependency(\.auth) var auth
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .emailChanged(email):
                state.email = email
                return .none
                
            case let .passwordChanged(password):
                state.password = password
                return .none
                
            case .loginTapped, .signInTapped:
                state.isLoading = true
                state.error = nil
                return .run { [email = state.email, password = state.password] send in
                    await send(.loginResponse(TaskResult { try await auth.signIn(email, password) }))
                }
                
            case .loginResponse(.success):
                state.isLoading = false
                return .send(.delegate(.didAuthenticate))
                
            case let .loginResponse(.failure(error)):
                state.isLoading = false
                state.error = error.localizedDescription
                return .none
                
            case .logoutTapped:
                state.isLoading = true
                return .run { send in
                    await send(.logoutResponse(TaskResult { try await auth.signOut() }))
                }
                
            case .logoutResponse(.success):
                state.isLoading = false
                return .send(.delegate(.didLogout))
                
            case let .logoutResponse(.failure(error)):
                state.isLoading = false
                state.error = error.localizedDescription
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
} 