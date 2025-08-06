import Foundation
import ComposableArchitecture

@Reducer
public struct MainFeature {
    @ObservableState
    public struct State: Equatable {
        public enum Tab: Int, CaseIterable {
            case home = 0
            case impact = 1
            case events = 2
            case profile = 3
        }
        
        public var selectedTab: Tab = .home
        public var impact = ImpactFeature.State()
        
        public init() {}
    }
    
    public enum Action: Equatable {
        case tabSelected(State.Tab)
        case impact(ImpactFeature.Action)
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.impact, action: \.impact) {
            ImpactFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .tabSelected(let tab):
                state.selectedTab = tab
                return .none
                
            case .impact:
                return .none
            }
        }
    }
} 