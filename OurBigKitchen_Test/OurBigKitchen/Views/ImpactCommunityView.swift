import SwiftUI

struct ImpactCommunityView: View {
    @StateObject private var viewModel = ImpactCommunityViewModel()
    
    // Use the centralized theme colors for consistency
    private let primaryColor = ThemeManager.Colors.primary
    private let secondaryColor = ThemeManager.Colors.secondary
    private let backgroundColor = ThemeManager.Colors.background
    
    var body: some View {
        ZStack {
            backgroundColor.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Global impact metrics
                    globalImpactSection
                    
                    // Community goals
                    communityGoalsSection
                    
                    // Top contributors
                    topContributorsSection
                    
                    // Recent community photos
                    communityPhotosSection
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal)
                .padding(.top, 16)
            }
            .refreshable {
                await viewModel.loadCommunityData()
            }
            .overlay {
                if viewModel.isLoading {
                    loadingOverlay
                }
            }
        }
        .navigationTitle("Community Impact")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.loadCommunityData()
        }
    }
    
    // MARK: - Global Impact Section
    
    private var globalImpactSection: some View {
        VStack(spacing: 20) {
            // Header and title
            VStack(spacing: 8) {
                Text("Our Collective Impact")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Together, we're making a difference")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Main metrics
            HStack(spacing: 0) {
                globalMetricCard(
                    value: viewModel.totalMealsServed,
                    label: "Meals Served",
                    icon: "fork.knife",
                    color: ThemeManager.Colors.mealsServed
                )
                
                globalMetricCard(
                    value: viewModel.totalVolunteerHours,
                    label: "Volunteer Hours",
                    icon: "clock.fill",
                    color: ThemeManager.Colors.hoursContributed
                )
                
                globalMetricCard(
                    value: viewModel.totalPeopleHelped,
                    label: "People Helped",
                    icon: "person.2.fill",
                    color: ThemeManager.Colors.primary
                )
            }
            
            // Secondary metrics
            HStack(spacing: 0) {
                globalMetricCard(
                    value: viewModel.totalWasteReduced,
                    label: "Waste Reduced (kg)",
                    icon: "leaf.fill",
                    color: ThemeManager.Colors.wasteReduced
                )
                
                globalMetricCard(
                    value: viewModel.totalCarbonSaved,
                    label: "CO₂ Saved (kg)",
                    icon: "globe.asia.australia.fill",
                    color: .green
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeManager.Colors.cardBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    private func globalMetricCard(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundColor(.primary)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
    
    // MARK: - Community Goals Section
    
    private var communityGoalsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Community Goals")
                .font(.headline)
                .foregroundColor(.primary)
            
            ForEach(viewModel.communityGoals) { goal in
                goalProgressBar(goal)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeManager.Colors.cardBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    private func goalProgressBar(_ goal: CommunityGoal) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: goal.icon)
                    .foregroundColor(goal.color)
                    .font(.system(size: 14))
                
                Text(goal.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(goal.current)/\(goal.target)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ZStack(alignment: .leading) {
                // Background progress bar
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 8)
                
                // Actual progress bar
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [goal.color, goal.color.opacity(0.7)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(16, CGFloat(goal.current) / CGFloat(goal.target) * UIScreen.main.bounds.width * 0.8), height: 8)
            }
            
            if !goal.description.isEmpty {
                Text(goal.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Top Contributors Section
    
    private var topContributorsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Top Contributors")
                .font(.headline)
                .foregroundColor(.primary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.topContributors) { contributor in
                        contributorCard(contributor)
                    }
                }
                .padding(.horizontal, 4)
                .padding(.bottom, 8)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeManager.Colors.cardBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    private func contributorCard(_ contributor: Contributor) -> some View {
        VStack(spacing: 12) {
            // Avatar/image
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [primaryColor.opacity(0.8), secondaryColor.opacity(0.6)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                if contributor.isOrganization {
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                } else {
                    Text(contributor.nameInitials)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            // Name and contribution
            VStack(spacing: 4) {
                Text(contributor.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(contributor.contributionDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .frame(width: 100)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
    
    // MARK: - Community Photos Section
    
    private var communityPhotosSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Community Moments")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    // View all photos
                }) {
                    Text("View All")
                        .font(.subheadline)
                        .foregroundColor(primaryColor)
                }
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(viewModel.communityPhotos) { photo in
                    communityPhotoCell(photo)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeManager.Colors.cardBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    private func communityPhotoCell(_ photo: CommunityPhoto) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Placeholder for photo - in a real app, this would be an actual image
            ZStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.gray.opacity(0.5),
                                Color.gray.opacity(0.3)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .aspectRatio(1.0, contentMode: .fit)
                    .cornerRadius(8)
                
                Image(systemName: photo.icon)
                    .font(.system(size: 30))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(photo.caption)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(photo.author)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Loading Overlay
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.2)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: ThemeManager.Colors.primary))
                    .scaleEffect(1.5)
                
                Text("Loading...")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
            )
            .shadow(radius: 20)
        }
    }
}

// MARK: - Models

struct CommunityGoal: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let color: Color
    let current: Int
    let target: Int
}

struct Contributor: Identifiable {
    let id: String
    let name: String
    let contributionValue: Int
    let contributionType: String // "meals" or "hours" or "donations"
    let isOrganization: Bool
    
    var nameInitials: String {
        name.components(separatedBy: " ")
            .prefix(2)
            .compactMap { $0.first }
            .map { String($0) }
            .joined()
    }
    
    var contributionDescription: String {
        switch contributionType {
        case "meals":
            return "\(contributionValue) meals"
        case "hours":
            return "\(contributionValue) hours"
        case "donations":
            return "$\(contributionValue)"
        default:
            return "\(contributionValue) contributions"
        }
    }
}

struct CommunityPhoto: Identifiable {
    let id: String
    let caption: String
    let author: String
    let date: Date
    let icon: String // Placeholder for actual images
}

// MARK: - ViewModel

class ImpactCommunityViewModel: ObservableObject {
    @Published var totalMealsServed: String = "0"
    @Published var totalVolunteerHours: String = "0"
    @Published var totalPeopleHelped: String = "0"
    @Published var totalWasteReduced: String = "0"
    @Published var totalCarbonSaved: String = "0"
    @Published var communityGoals: [CommunityGoal] = []
    @Published var topContributors: [Contributor] = []
    @Published var communityPhotos: [CommunityPhoto] = []
    @Published var isLoading: Bool = false
    
    @MainActor
    func loadCommunityData() async {
        isLoading = true
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // In a real app, this would fetch from an API or database
        generateDummyData()
        
        isLoading = false
    }
    
    func loadCommunityData() {
        Task {
            await loadCommunityData()
        }
    }
    
    private func generateDummyData() {
        // Global metrics
        totalMealsServed = "245,678"
        totalVolunteerHours = "38,450"
        totalPeopleHelped = "82,345"
        totalWasteReduced = "12,450"
        totalCarbonSaved = "31,125"
        
        // Community goals
        communityGoals = [
            CommunityGoal(
                id: "1",
                title: "June Meal Target",
                description: "Help us reach 50,000 meals this month",
                icon: "fork.knife",
                color: ThemeManager.Colors.mealsServed,
                current: 32500,
                target: 50000
            ),
            CommunityGoal(
                id: "2",
                title: "Volunteer Hours",
                description: "5,000 volunteer hours will help us expand services",
                icon: "clock.fill",
                color: ThemeManager.Colors.hoursContributed,
                current: 3200,
                target: 5000
            ),
            CommunityGoal(
                id: "3",
                title: "Food Waste Reduction",
                description: "Help save 2,000kg of food from landfill",
                icon: "leaf.fill",
                color: ThemeManager.Colors.wasteReduced,
                current: 1450,
                target: 2000
            )
        ]
        
        // Top contributors
        topContributors = [
            Contributor(
                id: "1",
                name: "Sarah Johnson",
                contributionValue: 245,
                contributionType: "hours",
                isOrganization: false
            ),
            Contributor(
                id: "2",
                name: "ABC Corporation",
                contributionValue: 1250,
                contributionType: "meals",
                isOrganization: true
            ),
            Contributor(
                id: "3",
                name: "Michael Smith",
                contributionValue: 180,
                contributionType: "hours",
                isOrganization: false
            ),
            Contributor(
                id: "4",
                name: "City Bank",
                contributionValue: 5000,
                contributionType: "donations",
                isOrganization: true
            ),
            Contributor(
                id: "5",
                name: "Local School",
                contributionValue: 850,
                contributionType: "meals",
                isOrganization: true
            )
        ]
        
        // Community photos
        communityPhotos = [
            CommunityPhoto(
                id: "1",
                caption: "Meal Prep Session",
                author: "John D.",
                date: Date().addingTimeInterval(-86400 * 2),
                icon: "fork.knife"
            ),
            CommunityPhoto(
                id: "2",
                caption: "Team Building Day",
                author: "ABC Corp",
                date: Date().addingTimeInterval(-86400 * 3),
                icon: "person.3.fill"
            ),
            CommunityPhoto(
                id: "3",
                caption: "Food Distribution",
                author: "Community Team",
                date: Date().addingTimeInterval(-86400 * 5),
                icon: "bag.fill"
            ),
            CommunityPhoto(
                id: "4",
                caption: "Volunteer Awards",
                author: "Sarah J.",
                date: Date().addingTimeInterval(-86400 * 7),
                icon: "trophy.fill"
            )
        ]
    }
}

#Preview {
    NavigationView {
        ImpactCommunityView()
    }
} 