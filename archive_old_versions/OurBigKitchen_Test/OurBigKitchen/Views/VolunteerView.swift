import SwiftUI

struct VolunteerView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Tab Bar
            HStack(spacing: 0) {
                TabButton(title: "Available", isSelected: selectedTab == 0) {
                    withAnimation {
                        selectedTab = 0
                    }
                }
                
                TabButton(title: "My Shifts", isSelected: selectedTab == 1) {
                    withAnimation {
                        selectedTab = 1
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Content
            TabView(selection: $selectedTab) {
                AvailableShiftsView()
                    .tag(0)
                
                MyShiftsView()
                    .tag(1)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .navigationTitle("Volunteer")
    }
}

struct AvailableShiftsView: View {
    @State private var shifts: [VolunteerShift] = []
    @State private var isLoading = false
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                } else if shifts.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 40))
                            .foregroundColor(ThemeManager.Colors.secondaryText)
                        
                        Text("No shifts available")
                            .font(.headline)
                            .foregroundColor(ThemeManager.Colors.secondaryText)
                        
                        Text("Check back soon for new volunteer opportunities")
                            .font(.subheadline)
                            .foregroundColor(ThemeManager.Colors.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    ForEach(shifts) { shift in
                        ShiftCard(shift: shift)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            loadShifts()
        }
    }
    
    private func loadShifts() {
        isLoading = true
        
        // TODO: Replace with actual API call
        let workItem = DispatchWorkItem {
            shifts = [
                VolunteerShift(
                    title: "Morning Kitchen Prep",
                    description: "Help prepare ingredients and set up the kitchen for the day's cooking",
                    startTime: Date().addingTimeInterval(3600),
                    endTime: Date().addingTimeInterval(7200),
                    location: "Main Kitchen",
                    requiredSkills: ["Basic kitchen knowledge"],
                    spotsAvailable: 5
                ),
                VolunteerShift(
                    title: "Food Distribution",
                    description: "Help package and distribute meals to community members",
                    startTime: Date().addingTimeInterval(14400),
                    endTime: Date().addingTimeInterval(18000),
                    location: "Distribution Center",
                    requiredSkills: ["None"],
                    spotsAvailable: 8
                )
            ]
            isLoading = false
        }
        DispatchQueue.main.async(execute: workItem)
    }
}

struct MyShiftsView: View {
    @State private var shifts: [VolunteerShift] = []
    @State private var isLoading = false
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                } else if shifts.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "calendar")
                            .font(.system(size: 40))
                            .foregroundColor(ThemeManager.Colors.secondaryText)
                        
                        Text("No upcoming shifts")
                            .font(.headline)
                            .foregroundColor(ThemeManager.Colors.secondaryText)
                        
                        Text("Sign up for volunteer shifts in the Available tab")
                            .font(.subheadline)
                            .foregroundColor(ThemeManager.Colors.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    ForEach(shifts) { shift in
                        ShiftCard(shift: shift)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            loadMyShifts()
        }
    }
    
    private func loadMyShifts() {
        isLoading = true
        
        // TODO: Replace with actual API call
        let workItem = DispatchWorkItem {
            shifts = [] // Empty for now
            isLoading = false
        }
        DispatchQueue.main.async(execute: workItem)
    }
}

struct ShiftCard: View {
    let shift: VolunteerShift
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Shift Title
            Text(shift.title)
                .font(.headline)
                .foregroundColor(ThemeManager.Colors.primaryText)
            
            // Shift Description
            Text(shift.description)
                .font(.subheadline)
                .foregroundColor(ThemeManager.Colors.secondaryText)
                .lineLimit(2)
            
            HStack {
                // Time
                VStack(alignment: .leading, spacing: 4) {
                    Text(shift.formattedTimeRange)
                        .font(.subheadline)
                        .foregroundColor(ThemeManager.Colors.secondaryText)
                }
                
                Spacer()
                
                // Location
                HStack {
                    Image(systemName: "location.fill")
                    Text(shift.location)
                }
                .font(.subheadline)
                .foregroundColor(ThemeManager.Colors.secondaryText)
            }
            
            // Required Skills
            if !shift.requiredSkills.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Required Skills:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(ThemeManager.Colors.primaryText)
                    
                    ForEach(shift.requiredSkills, id: \.self) { skill in
                        HStack(alignment: .top) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(ThemeManager.Colors.primary)
                            Text(skill)
                                .font(.subheadline)
                                .foregroundColor(ThemeManager.Colors.secondaryText)
                        }
                    }
                }
            }
            
            // Spots Available
            HStack {
                Image(systemName: "person.2.fill")
                Text("\(shift.spotsAvailable) spots available")
            }
            .font(.subheadline)
            .foregroundColor(ThemeManager.Colors.secondaryText)
            
            // Sign Up Button
            Button(action: {
                // TODO: Implement sign up functionality
            }) {
                Text("Sign Up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(ThemeManager.Colors.primary)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct VolunteerShift: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let startTime: Date
    let endTime: Date
    let location: String
    let requiredSkills: [String]
    let spotsAvailable: Int
    
    var formattedTimeRange: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        let startString = formatter.string(from: startTime)
        let endString = formatter.string(from: endTime)
        
        return "\(startString) - \(endString)"
    }
}

#Preview {
    NavigationView {
        VolunteerView()
            .environmentObject(AppState())
    }
} 