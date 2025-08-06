import SwiftUI
import ComposableArchitecture

public struct ProfileView: View {
    let store: StoreOf<ProfileFeature>
    
    public init(store: StoreOf<ProfileFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                        // Profile Header
                        VStack(spacing: 15) {
                            if let user = viewStore.user {
                                Group {
                                    if let profileImageURL = user.profileImageURL,
                                       let url = URL(string: profileImageURL) {
                                        AsyncImage(url: url) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                        } placeholder: {
                                            Image(systemName: "person.circle.fill")
                                                .resizable()
                                                .foregroundColor(.gray)
                                        }
                                    } else {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .foregroundColor(.gray)
                                    }
                                }
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.blue, lineWidth: 3)
                                )
                                
                                Text(user.fullName)
                                    .font(.title)
                                    .bold()
                                
                                Text(user.role.rawValue.capitalized)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                if let bio = user.bio {
                                    Text(bio)
                                        .font(.body)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                }
                            }
                        }
                        .padding()
                        
                        // Stats Section
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Your Impact")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            HStack(spacing: 20) {
                                StatView(
                                    value: "\(viewStore.stats.hoursVolunteered)",
                                    label: "Hours",
                                    systemImage: "clock.fill"
                                )
                                
                                StatView(
                                    value: "\(viewStore.stats.mealsPrepared)",
                                    label: "Meals",
                                    systemImage: "fork.knife"
                                )
                                
                                StatView(
                                    value: "\(viewStore.stats.eventsAttended)",
                                    label: "Events",
                                    systemImage: "calendar"
                                )
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(radius: 5)
                        }
                        
                        // Recent Activities
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Recent Activities")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(viewStore.recentActivities) { activity in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(activity.title)
                                            .font(.subheadline)
                                            .bold()
                                        Text(activity.description)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text(activity.date, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .shadow(radius: 5)
                            }
                        }
                        
                        // Achievements
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Achievements")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(viewStore.achievements) { achievement in
                                        VStack {
                                            Circle()
                                                .fill(Color.blue)
                                                .frame(width: 60, height: 60)
                                                .overlay(
                                                    Image(systemName: "star.fill")
                                                        .foregroundColor(.white)
                                                )
                                            
                                            Text(achievement.title)
                                                .font(.caption)
                                                .multilineTextAlignment(.center)
                                        }
                                        .frame(width: 80)
                                    }
                                }
                                .padding()
                            }
                        }
                        
                        Button(action: { viewStore.send(.logoutTapped) }) {
                            Text("Log Out")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { viewStore.send(.editProfileTapped) }) {
                            Text("Edit")
                        }
                    }
                }
                .onAppear {
                    viewStore.send(.onAppear)
                }
            }
        }
    }
}

private struct StatView: View {
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