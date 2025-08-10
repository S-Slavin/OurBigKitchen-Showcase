import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var sessionService: SessionService
    @EnvironmentObject var impactService: ImpactService
    @StateObject private var viewModel = ImpactViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Header
                VStack {
                    if let imageURL = authService.currentUser?.profileImageURL,
                       let url = URL(string: imageURL) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        } placeholder: {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 120, height: 120)
                        }
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 120, height: 120)
                    }
                    
                    Text(authService.currentUser?.fullName ?? "Guest")
                        .font(.title2)
                        .bold()
                    
                    if let bio = authService.currentUser?.bio {
                        Text(bio)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .padding()
                
                // Stats Section
                if let stats = authService.currentUser?.stats {
                    HStack(spacing: 30) {
                        VStack {
                            Text("\(stats.hoursVolunteered)")
                                .font(.title)
                                .bold()
                            Text("Hours")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack {
                            Text("\(stats.mealsPrepared)")
                                .font(.title)
                                .bold()
                            Text("Meals")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack {
                            Text("\(stats.eventsAttended)")
                                .font(.title)
                                .bold()
                            Text("Events")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.medium)
                            .fill(Color.white)
                            .shadow(radius: ThemeManager.Shadow.small)
                    )
                    .padding(.horizontal)
                }
                
                // Achievements Section
                if let achievements = authService.currentUser?.achievements, !achievements.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Achievements")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(achievements) { achievement in
                                    VStack(alignment: .leading) {
                                        Text(achievement.title)
                                            .font(.subheadline)
                                            .bold()
                                        Text(achievement.description)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(achievement.dateAchieved, style: .date)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding()
                                    .frame(width: 200)
                                    .background(
                                        RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.small)
                                            .fill(Color.white)
                                            .shadow(radius: ThemeManager.Shadow.small)
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Recent Activities Section
                VStack(alignment: .leading) {
                    Text("Recent Activities")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if !impactService.impactPosts.isEmpty {
                        ForEach(impactService.impactPosts) { post in
                            ImpactPostCard(post: post)
                        }
                    } else {
                        Text("No recent activities")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
            }
        }
        .navigationTitle("Profile")
    }
}

struct ImpactPostCard: View {
    let post: ImpactPost
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(post.message)
                .font(.body)
            
            HStack {
                ForEach(post.tags, id: \.self) { tag in
                    Text("#\(tag)")
                        .font(.caption)
                        .foregroundColor(ThemeManager.Colors.accent)
                }
            }
            
            Text(post.date, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Label("\(post.views)", systemImage: "eye.fill")
                Label("\(post.shares)", systemImage: "square.and.arrow.up")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.medium)
                .fill(Color.white)
                .shadow(radius: ThemeManager.Shadow.small)
        )
        .padding(.horizontal)
    }
} 