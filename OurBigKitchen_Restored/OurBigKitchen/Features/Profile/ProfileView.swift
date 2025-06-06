import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var impactService: ImpactService
    @EnvironmentObject var sessionService: SessionService
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Profile Header
                    ProfileHeaderView()
                    
                    // Statistics Section
                    StatisticsView()
                    
                    // Recent Activity
                    RecentActivityView()
                    
                    // Achievements
                    AchievementsView()
                    
                    Spacer()
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct ProfileHeaderView: View {
    @EnvironmentObject var authService: AuthenticationService
    
    var body: some View {
        VStack(spacing: 20) {
            // Profile Image
            Button(action: {
                // Handle profile image change
            }) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                }
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            }
            
            // User Info
            VStack(spacing: 8) {
                Text(authService.currentUser?.fullName ?? "John Doe")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(authService.currentUser?.email ?? "john.doe@example.com")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Edit Profile Button
                Button(action: {
                    // Handle edit profile
                }) {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Edit Profile")
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(20)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct StatisticsView: View {
    @EnvironmentObject var impactService: ImpactService
    @EnvironmentObject var sessionService: SessionService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Your Statistics")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                StatisticCard(
                    icon: "calendar",
                    title: "Total Sessions",
                    value: "\(sessionService.getSessions().count)",
                    color: .blue
                )
                
                StatisticCard(
                    icon: "clock",
                    title: "Hours Volunteered",
                    value: String(format: "%.1f", impactService.getImpacts().reduce(0) { $0 + $1.hours }),
                    color: .green
                )
                
                StatisticCard(
                    icon: "fork.knife",
                    title: "Meals Served",
                    value: "\(impactService.totalMealsServed)",
                    color: .orange
                )
                
                StatisticCard(
                    icon: "heart",
                    title: "Impact Score",
                    value: "\(impactService.livesTouched)",
                    color: .red
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct StatisticCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.1))
                .cornerRadius(12)
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

struct RecentActivityView: View {
    @EnvironmentObject var impactService: ImpactService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Recent Activity")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("View All") {
                    // Navigate to full activity list
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            if impactService.getImpacts().isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "clock")
                        .font(.title)
                        .foregroundColor(.gray)
                    
                    Text("No recent activity")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(30)
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(impactService.getImpacts().prefix(3)) { impact in
                        ActivityRowView(impact: impact)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct ActivityRowView: View {
    let impact: Impact
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.green)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(impact.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    Text(impact.location)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(impact.hours, specifier: "%.1f")h")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct AchievementsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Achievements")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                AchievementBadge(
                    icon: "star.fill",
                    title: "First Volunteer",
                    earned: true,
                    color: .yellow
                )
                
                AchievementBadge(
                    icon: "flame.fill",
                    title: "10 Hours",
                    earned: false,
                    color: .orange
                )
                
                AchievementBadge(
                    icon: "heart.fill",
                    title: "Community Hero",
                    earned: false,
                    color: .red
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct AchievementBadge: View {
    let icon: String
    let title: String
    let earned: Bool
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(earned ? color : .gray)
                .frame(width: 40, height: 40)
                .background((earned ? color : Color.gray).opacity(0.1))
                .cornerRadius(20)
            
            Text(title)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(earned ? .primary : .secondary)
                .multilineTextAlignment(.center)
        }
        .opacity(earned ? 1.0 : 0.6)
    }
} 