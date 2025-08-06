import SwiftUI
import ComposableArchitecture

public struct OnboardingView: View {
    let store: StoreOf<OnboardingFeature>
    
    public init(store: StoreOf<OnboardingFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            TabView(selection: viewStore.binding(
                get: \.currentPage,
                send: OnboardingFeature.Action.pageChanged
            )) {
                // Welcome Page
                VStack(spacing: 20) {
                    Image("onboarding_welcome")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 40)
                    
                    Text("Welcome to Our Big Kitchen")
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    Text("Join us in making a difference in our community through food and volunteering.")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .tag(OnboardingFeature.Page.welcome)
                
                // Impact Page
                VStack(spacing: 20) {
                    Image("onboarding_impact")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 40)
                    
                    Text("Make an Impact")
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    Text("Track your contributions and see how you're helping to feed families in need.")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .tag(OnboardingFeature.Page.impact)
                
                // Community Page
                VStack(spacing: 20) {
                    Image("onboarding_community")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 40)
                    
                    Text("Join Our Community")
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    Text("Connect with other volunteers and see the collective impact we're making.")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .tag(OnboardingFeature.Page.community)
                
                // Last Page
                VStack(spacing: 20) {
                    Image("onboarding_start")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 40)
                    
                    Text("Ready to Begin?")
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    Text("Let's start making a difference together.")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: { viewStore.send(.getStartedTapped) }) {
                        Text("Get Started")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                }
                .tag(OnboardingFeature.Page.last)
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewStore.currentPage != .last {
                        Button("Skip") {
                            viewStore.send(.getStartedTapped)
                        }
                    }
                }
            }
        }
    }
}

extension OnboardingFeature.Page {
    var imageName: String {
        switch self {
        case .welcome:
            return "onboarding_welcome"
        case .impact:
            return "onboarding_impact"
        case .community:
            return "onboarding_community"
        case .last:
            return "onboarding_start"
        }
    }
    
    var title: String {
        switch self {
        case .welcome:
            return "Welcome to Our Big Kitchen"
        case .impact:
            return "Make an Impact"
        case .community:
            return "Join Our Community"
        case .last:
            return "Ready to Begin?"
        }
    }
    
    var description: String {
        switch self {
        case .welcome:
            return "Your journey to making a difference starts here. Together, we can create positive change in our community."
        case .impact:
            return "Track your volunteer hours, see your impact, and contribute to meaningful projects that help those in need."
        case .community:
            return "Connect with fellow volunteers, share experiences, and be part of a growing community dedicated to helping others."
        case .last:
            return "Let's get started on your volunteering journey with Our Big Kitchen."
        }
    }
} 