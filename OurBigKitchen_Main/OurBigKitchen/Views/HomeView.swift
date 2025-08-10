import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeDashboardViewModel()
    @State private var animateContent = false
    @State private var heroScale = false
    @State private var impactPulse = false
    @Binding var selectedTab: Int
    @State private var showMealTrackingPopup = false
    @State private var mealTrackingInfo: (timeSpent: String, mealsMade: String) = ("2.5", "45")
    @State private var waveOffset: CGFloat = 0
    
    init(selectedTab: Binding<Int>) {
        self._selectedTab = selectedTab
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ThemeManager.Colors.background
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Hero section with enhanced design
                        enhancedHeroSection
                        
                        // Impact dashboard with animated cards
                        enhancedImpactDashboard
                            .padding(.horizontal)
                            .offset(y: animateContent ? 0 : 20)
                            .opacity(animateContent ? 1 : 0)
                        
                        // Quick actions
                        enhancedQuickActionsSection
                            .padding(.horizontal)
                            .offset(y: animateContent ? 0 : 30)
                            .opacity(animateContent ? 1 : 0)
                        
                        // Upcoming sessions
                        enhancedUpcomingSessionsSection
                            .padding(.horizontal)
                            .offset(y: animateContent ? 0 : 40)
                            .opacity(animateContent ? 1 : 0)
                        
                        // Footer
                        Text("© Our Big Kitchen \(Calendar.current.component(.year, from: Date()))")
                            .font(.caption)
                            .foregroundColor(Color(.secondaryLabel))
                            .padding(.vertical, 20)
                            .offset(y: animateContent ? 0 : 50)
                            .opacity(animateContent ? 1 : 0)
                    }
                }
                .refreshable {
                    Task {
                        await refreshData()
                    }
                }
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                    }
                }
            }
        }
    }
    
    private var enhancedHeroSection: some View {
        VStack(spacing: 16) {
            // Hero content
            Text("Welcome to Our Big Kitchen")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(ThemeManager.Colors.primary)
            
            Text("Join us in making a difference")
                .font(.subheadline)
                .foregroundColor(ThemeManager.Colors.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.large)
                .fill(Color.white)
                .shadow(radius: ThemeManager.Shadow.medium)
        )
        .padding(.horizontal)
    }
    
    private var enhancedImpactDashboard: some View {
        VStack(spacing: 16) {
            Text("Our Impact")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(ThemeManager.Colors.primary)
            
            HStack(spacing: 16) {
                ImpactCard(
                    title: "Meals Served",
                    value: "1,234",
                    icon: "fork.knife"
                )
                
                ImpactCard(
                    title: "Volunteers",
                    value: "567",
                    icon: "person.2.fill"
                )
            }
        }
    }
    
    private var enhancedQuickActionsSection: some View {
        VStack(spacing: 16) {
            Text("Quick Actions")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(ThemeManager.Colors.primary)
            
            HStack(spacing: 16) {
                QuickActionButton(
                    title: "Volunteer",
                    icon: "hand.raised.fill",
                    action: { selectedTab = 2 }
                )
                
                QuickActionButton(
                    title: "Donate",
                    icon: "heart.fill",
                    action: { /* Handle donation */ }
                )
            }
        }
    }
    
    private var enhancedUpcomingSessionsSection: some View {
        VStack(spacing: 16) {
            Text("Upcoming Sessions")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(ThemeManager.Colors.primary)
            
            ForEach(viewModel.upcomingSessions) { session in
                SessionCard(session: session)
            }
        }
    }
    
    private func refreshData() async {
        // Implement data refresh logic
    }
}

struct ImpactCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(ThemeManager.Colors.primary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(ThemeManager.Colors.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.medium)
                .fill(Color.white)
                .shadow(radius: ThemeManager.Shadow.small)
        )
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.medium)
                    .fill(ThemeManager.Colors.primary)
            )
            .foregroundColor(.white)
        }
    }
}

struct SessionCard: View {
    let session: UpcomingSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(session.title)
                .font(.headline)
            
            Text(session.date, style: .date)
                .font(.subheadline)
                .foregroundColor(ThemeManager.Colors.secondary)
            
            Text(session.formattedDuration)
                .font(.caption)
                .foregroundColor(ThemeManager.Colors.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.medium)
                .fill(Color.white)
                .shadow(radius: ThemeManager.Shadow.small)
        )
    }
}

#Preview {
    HomeView(selectedTab: .constant(0))
} 