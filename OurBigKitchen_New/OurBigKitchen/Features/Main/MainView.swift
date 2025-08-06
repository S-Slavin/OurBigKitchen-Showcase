import SwiftUI
import ComposableArchitecture

public struct MainView: View {
    let store: StoreOf<MainFeature>
    
    public init(store: StoreOf<MainFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: \.selectedTab) { viewStore in
            TabView(selection: viewStore.binding(
                get: { $0 },
                send: MainFeature.Action.tabSelected
            )) {
                // Home Tab
                HomeView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                    .tag(MainFeature.State.Tab.home)
                
                // Impact Tab
                ImpactView(store: store.scope(state: \.impact, action: \.impact))
                    .tabItem {
                        Image(systemName: "heart.fill")
                        Text("Impact")
                    }
                    .tag(MainFeature.State.Tab.impact)
                
                // Events Tab
                EventsView()
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Events")
                    }
                    .tag(MainFeature.State.Tab.events)
                
                // Profile Tab
                ProfileView(store: Store(initialState: ProfileFeature.State()) {
                    ProfileFeature()
                })
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Profile")
                    }
                    .tag(MainFeature.State.Tab.profile)
            }
        }
    }
}

// Temporary HomeView until we implement it properly
private struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Welcome to Our Big Kitchen")
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Quick Actions Card
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Quick Actions")
                                .font(.headline)
                            
                            HStack(spacing: 15) {
                                QuickActionButton(
                                    title: "Log Hours",
                                    systemImage: "clock.fill",
                                    color: .blue
                                )
                                
                                QuickActionButton(
                                    title: "View Events",
                                    systemImage: "calendar",
                                    color: .green
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        
                        // Impact Summary Card
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Your Impact")
                                .font(.headline)
                            
                            HStack {
                                ImpactMetricView(
                                    value: "150",
                                    label: "Meals Served",
                                    systemImage: "fork.knife"
                                )
                                
                                Divider()
                                
                                ImpactMetricView(
                                    value: "12",
                                    label: "Hours",
                                    systemImage: "clock"
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        
                        // Upcoming Events Card
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Upcoming Events")
                                .font(.headline)
                            
                            ForEach(1...3, id: \.self) { _ in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Community Kitchen")
                                            .font(.subheadline)
                                            .bold()
                                        Text("Tomorrow, 9:00 AM")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 5)
                                
                                if _ != 3 {
                                    Divider()
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 5)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image("LogoTransparent")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 30)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "bell.fill")
                    }
                }
            }
        }
    }
}

private struct QuickActionButton: View {
    let title: String
    let systemImage: String
    let color: Color
    
    var body: some View {
        VStack {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 50, height: 50)
                .background(color.opacity(0.2))
                .clipShape(Circle())
            
            Text(title)
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct ImpactMetricView: View {
    let value: String
    let label: String
    let systemImage: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.title2)
                .bold()
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
} 