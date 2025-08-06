import SwiftUI
import ComposableArchitecture

struct RootView: View {
    let store: StoreOf<AppFeature>
    
    var body: some View {
        SwitchStore(store) { state in
            switch state {
            case .onboarding:
                CaseLet(/AppFeature.State.onboarding, action: AppFeature.Action.onboarding) { store in
                    OnboardingView(store: store)
                }
            case .authentication:
                CaseLet(/AppFeature.State.authentication, action: AppFeature.Action.authentication) { store in
                    AuthenticationView(store: store)
                }
            case .main:
                CaseLet(/AppFeature.State.main, action: AppFeature.Action.main) { store in
                    MainView(store: store)
                }
            }
        }
    }
} 