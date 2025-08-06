import SwiftUI
import ComposableArchitecture

public struct HomeView: View {
    public init() {}
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome Section
                    VStack(spacing: 10) {
                        Text("Welcome to Our Big Kitchen!")
                            .font(.largeTitle)
                            .bold()
                            .multilineTextAlignment(.center)
                        
                        Text("Together, we're making a difference in our community")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    
                    // Quick Stats
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        QuickStatCard(
                            title: "Meals Served",
                            value: "2,500+",
                            systemImage: "fork.knife",
                            color: .blue
                        )
                        
                        QuickStatCard(
                            title: "Volunteers",
                            value: "150+",
                            systemImage: "person.3.fill",
                            color: .green
                        )
                        
                        QuickStatCard(
                            title: "Events",
                            value: "45+",
                            systemImage: "calendar",
                            color: .orange
                        )
                        
                        QuickStatCard(
                            title: "Impact Score",
                            value: "9.8",
                            systemImage: "star.fill",
                            color: .purple
                        )
                    }
                    .padding(.horizontal)
                    
                    // Featured Actions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Get Involved")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            ActionCard(
                                title: "Log Your Impact",
                                subtitle: "Track your volunteering hours and meals prepared",
                                systemImage: "plus.circle.fill",
                                color: .blue
                            )
                            
                            ActionCard(
                                title: "Upcoming Events",
                                subtitle: "Join community cooking sessions",
                                systemImage: "calendar.badge.plus",
                                color: .green
                            )
                            
                            ActionCard(
                                title: "Share Your Story",
                                subtitle: "Inspire others with your impact",
                                systemImage: "square.and.arrow.up",
                                color: .orange
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct QuickStatCard: View {
    let title: String
    let value: String
    let systemImage: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .bold()
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct ActionCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

#Preview {
    HomeView()
} 