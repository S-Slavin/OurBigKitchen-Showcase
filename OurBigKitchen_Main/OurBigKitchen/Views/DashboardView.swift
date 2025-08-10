import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = MainViewModel()
    @StateObject private var contentViewModel = ContentViewModel()
    @State private var showingSocialSharingView = false
    @State private var showingWebView = false
    @State private var showingLoginSheet = false
    @State private var bookingURL = "https://ourbigkitchen.org/volunteer/group-bookings"
    @State private var webViewTitle = "Group Booking"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    welcomeSection
                    
                    socialSharingSection
                    
                    groupVolunteerBookingSection
                    
                    quickActionsSection
                    
                    upcomingEventsSection
                    
                    impactSummarySection
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .refreshable {
                // Refresh data
            }
            .sheet(isPresented: $showingSocialSharingView) {
                VStack {
                    HStack {
                        Spacer()
                        Button("SKIP FOR DEMO") {
                            showingSocialSharingView = false
                        }
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 24)
                        .background(Color.orange)
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                        .padding()
                    }
                    
                    SocialSharingView()
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingWebView) {
                VStack {
                    HStack {
                        Spacer()
                        Button("SKIP FOR DEMO") {
                            showingWebView = false
                        }
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 24)
                        .background(Color.orange)
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                        .padding()
                    }
                    
                    WebViewScreen(url: URL(string: bookingURL)!, title: webViewTitle)
                        .edgesIgnoringSafeArea(.bottom)
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingLoginSheet, onDismiss: {
                // Refresh auth state when login sheet is dismissed
                contentViewModel.checkAuthentication()
                print("DashboardView login sheet dismissed")
            }) {
                VStack {
                    HStack {
                        Spacer()
                        Button("SKIP FOR DEMO") {
                            showingLoginSheet = false
                        }
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 24)
                        .background(Color.orange)
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                        .padding()
                    }
                    
                    // Use our independent login wrapper
                    StandardLoginWrapper()
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
    }
    
    // MARK: - Welcome Section
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome to Our Big Kitchen")
                .font(.headline)
            
            Text("Making a difference through food and community")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Social Sharing Section
    private var socialSharingSection: some View {
        VStack(spacing: 12) {
            Text("Share Your Impact")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button {
                showingSocialSharingView = true
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 20))
                    
                    Text("Share Your OBK Experience")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            Text("Let your networks know about the impact you're making!")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Group Volunteer Booking Section
    private var groupVolunteerBookingSection: some View {
        VStack(spacing: 12) {
            Text("Group Volunteering")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button {
                bookingURL = "https://ourbigkitchen.org/volunteer/group-bookings"
                webViewTitle = "Group Volunteering"
                showingWebView = true
            } label: {
                HStack {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 20))
                    
                    Text("Book a Personalized Group Volunteer Session")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            Text("Organize a team building or community service event with your organization")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Quick Actions
    private var quickActionsSection: some View {
        VStack(spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 15) {
                actionButton(title: "Volunteer", systemImage: "person.2.fill", color: .blue) {
                    // Navigate to volunteer view
                }
                
                actionButton(title: "Events", systemImage: "calendar", color: .orange) {
                    // Navigate to events
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func actionButton(title: String, systemImage: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 22))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(.systemGray5))
            .cornerRadius(8)
        }
    }
    
    // MARK: - Upcoming Events
    private var upcomingEventsSection: some View {
        VStack(spacing: 12) {
            Text("Upcoming Events")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("No upcoming events. Check the Events tab to browse all available activities.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
                .background(Color(.systemGray5))
                .cornerRadius(8)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Impact Summary
    private var impactSummarySection: some View {
        VStack(spacing: 12) {
            Text("Your Impact")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 15) {
                impactStat(value: "0", label: "Meals", systemImage: "fork.knife")
                impactStat(value: "0", label: "Hours", systemImage: "clock.fill")
                impactStat(value: "0", label: "People", systemImage: "person.2.fill")
            }
            
            NavigationLink(destination: ImpactDashboardView()) {
                Text("View Full Impact Dashboard")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                    .padding(.top, 8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func impactStat(value: String, label: String, systemImage: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.system(size: 18))
                .foregroundColor(.blue)
            
            Text(value)
                .font(.title3.bold())
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color(.systemGray5))
        .cornerRadius(8)
    }
}

#Preview {
    DashboardView()
} 