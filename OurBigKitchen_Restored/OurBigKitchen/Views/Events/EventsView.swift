import SwiftUI
import Foundation

struct EventsView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Tab Bar
            HStack(spacing: 0) {
                TabButton(title: "All Events", isSelected: selectedTab == 0) {
                    withAnimation {
                        selectedTab = 0
                    }
                }
                
                if appState.userProfile?.isCorporate == true {
                    TabButton(title: "Corporate", isSelected: selectedTab == 1) {
                        withAnimation {
                            selectedTab = 1
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Content
            TabView(selection: $selectedTab) {
                AllEventsView()
                    .tag(0)
                
                if appState.userProfile?.isCorporate == true {
                    CorporateEventsView()
                        .tag(1)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .navigationTitle("Events")
        .onAppear {
            // Reset to first tab when view appears
            selectedTab = 0
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(isSelected ? ThemeManager.Colors.primary : ThemeManager.Colors.secondaryText)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(
                    VStack {
                        Spacer()
                        if isSelected {
                            Rectangle()
                                .fill(ThemeManager.Colors.primary)
                                .frame(height: 2)
                        }
                    }
                )
        }
    }
}

struct AllEventsView: View {
    @State private var events: [Event] = []
    @State private var isLoading = false
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                } else if events.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 40))
                            .foregroundColor(ThemeManager.Colors.secondaryText)
                        
                        Text("No events available")
                            .font(.headline)
                            .foregroundColor(ThemeManager.Colors.secondaryText)
                        
                        Text("Check back soon for upcoming events")
                            .font(.subheadline)
                            .foregroundColor(ThemeManager.Colors.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    ForEach(events) { event in
                        EventCard(event: event)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            loadEvents()
        }
    }
    
    private func loadEvents() {
        isLoading = true
        
        // TODO: Replace with actual API call
        // For now, load mock data with more variety
        let workItem = DispatchWorkItem {
            events = [
                Event(
                    title: "Community Kitchen",
                    description: "Join us for a community cooking event where we prepare meals for those in need. All skill levels welcome!",
                    startDate: Date(),
                    endDate: Date().addingTimeInterval(7200),
                    location: "Main Kitchen",
                    maxVolunteers: 20,
                    currentVolunteers: 5,
                    type: .cooking,
                    organizer: "Community Team",
                    requirements: ["Basic cooking skills", "Food safety knowledge"],
                    imageURL: nil
                ),
                Event(
                    title: "Corporate Team Building",
                    description: "Team building event for corporate volunteers. Learn cooking skills while making a difference.",
                    startDate: Date().addingTimeInterval(86400),
                    endDate: Date().addingTimeInterval(93600),
                    location: "Corporate Center",
                    maxVolunteers: 15,
                    currentVolunteers: 8,
                    type: .training,
                    organizer: "Corporate Team",
                    requirements: ["Team spirit", "Willingness to learn"],
                    imageURL: nil
                ),
                Event(
                    title: "Children's Workshop",
                    description: "Fun and educational cooking workshop for children. Learn basic cooking skills in a safe environment.",
                    startDate: Date().addingTimeInterval(172800),
                    endDate: Date().addingTimeInterval(180000),
                    location: "Children's Center",
                    maxVolunteers: 10,
                    currentVolunteers: 3,
                    type: .training,
                    organizer: "Education Team",
                    requirements: ["Parental supervision", "Basic kitchen safety"],
                    imageURL: nil
                )
            ]
            isLoading = false
        }
        DispatchQueue.main.async(execute: workItem)
    }
}

struct EventCard: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Event Type Badge
            Text(event.type.rawValue.capitalized)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(event.type.color)
                .cornerRadius(4)
            
            // Event Title
            Text(event.title)
                .font(.headline)
                .foregroundColor(ThemeManager.Colors.primaryText)
            
            // Event Description
            Text(event.description)
                .font(.subheadline)
                .foregroundColor(ThemeManager.Colors.secondaryText)
                .lineLimit(2)
            
            HStack {
                // Event Date and Time
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.formattedDateRange)
                        .font(.subheadline)
                        .foregroundColor(ThemeManager.Colors.secondaryText)
                }
                
                Spacer()
                
                // Location
                HStack {
                    Image(systemName: "location.fill")
                    Text(event.location)
                }
                .font(.subheadline)
                .foregroundColor(ThemeManager.Colors.secondaryText)
            }
            
            // Organizer
            HStack {
                Image(systemName: "person.fill")
                Text(event.organizer)
            }
            .font(.subheadline)
            .foregroundColor(ThemeManager.Colors.secondaryText)
            
            // Requirements
            if !event.requirements.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Requirements:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(ThemeManager.Colors.primaryText)
                    
                    ForEach(event.requirements, id: \.self) { requirement in
                        HStack(alignment: .top) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(ThemeManager.Colors.primary)
                            Text(requirement)
                                .font(.subheadline)
                                .foregroundColor(ThemeManager.Colors.secondaryText)
                        }
                    }
                }
            }
            
            // Volunteer Count
            HStack {
                Image(systemName: "person.2.fill")
                Text("\(event.currentVolunteers)/\(event.maxVolunteers) volunteers")
            }
            .font(.subheadline)
            .foregroundColor(ThemeManager.Colors.secondaryText)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct EventsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EventsView()
                .environmentObject(AppState())
        }
    }
} 