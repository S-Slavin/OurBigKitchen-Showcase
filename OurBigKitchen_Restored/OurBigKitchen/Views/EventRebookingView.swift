//
//  EventRebookingView.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//

import SwiftUI

struct EventRebookingView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    @State private var showingBookingForm = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Tab Bar
            HStack(spacing: 0) {
                TabButton(title: "Available", isSelected: selectedTab == 0) {
                    withAnimation {
                        selectedTab = 0
                    }
                }
                
                TabButton(title: "My Events", isSelected: selectedTab == 1) {
                    withAnimation {
                        selectedTab = 1
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Content
            TabView(selection: $selectedTab) {
                AvailableCorporateEventsView()
                    .tag(0)
                
                MyCorporateEventsView()
                    .tag(1)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .navigationTitle("Corporate Events")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingBookingForm = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingBookingForm) {
            CorporateEventBookingForm()
        }
    }
}

struct AvailableCorporateEventsView: View {
    @State private var events: [CorporateEvent] = []
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
                        Image(systemName: "building.2")
                            .font(.system(size: 40))
                            .foregroundColor(ThemeManager.Colors.secondaryText)
                        
                        Text("No corporate events available")
                            .font(.headline)
                            .foregroundColor(ThemeManager.Colors.secondaryText)
                        
                        Text("Check back soon for new corporate event opportunities")
                            .font(.subheadline)
                            .foregroundColor(ThemeManager.Colors.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    ForEach(events) { event in
                        CorporateEventCard(event: event)
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
        let workItem = DispatchWorkItem {
            events = [
                CorporateEvent(
                    title: "Team Building Cooking Class",
                    description: "A fun and interactive cooking class for your team. Learn new skills while building team spirit.",
                    date: Date().addingTimeInterval(86400),
                    duration: 180,
                    location: "Corporate Kitchen",
                    maxParticipants: 20,
                    price: 1500,
                    includes: ["Ingredients", "Equipment", "Professional Chef", "Recipes"]
                ),
                CorporateEvent(
                    title: "Corporate Social Responsibility Day",
                    description: "Give back to the community while strengthening your team bonds.",
                    date: Date().addingTimeInterval(172800),
                    duration: 240,
                    location: "Community Center",
                    maxParticipants: 30,
                    price: 2000,
                    includes: ["Materials", "Supervision", "Certification", "Photos"]
                )
            ]
            isLoading = false
        }
        DispatchQueue.main.async(execute: workItem)
    }
}

struct MyCorporateEventsView: View {
    @State private var events: [CorporateEvent] = []
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
                        Image(systemName: "calendar")
                            .font(.system(size: 40))
                            .foregroundColor(ThemeManager.Colors.secondaryText)
                        
                        Text("No upcoming corporate events")
                            .font(.headline)
                            .foregroundColor(ThemeManager.Colors.secondaryText)
                        
                        Text("Book a corporate event to see it here")
                            .font(.subheadline)
                            .foregroundColor(ThemeManager.Colors.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    ForEach(events) { event in
                        CorporateEventCard(event: event)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            loadMyEvents()
        }
    }
    
    private func loadMyEvents() {
        isLoading = true
        
        // TODO: Replace with actual API call
        let workItem = DispatchWorkItem {
            events = [] // Empty for now
            isLoading = false
        }
        DispatchQueue.main.async(execute: workItem)
    }
}

struct CorporateEventCard: View {
    let event: CorporateEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
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
                // Date and Time
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.formattedDateTime)
                        .font(.subheadline)
                        .foregroundColor(ThemeManager.Colors.secondaryText)
                    
                    Text("Duration: \(event.formattedDuration)")
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
            
            // Price
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                Text("$\(event.price)")
                    .font(.headline)
            }
            .foregroundColor(ThemeManager.Colors.primary)
            
            // Includes
            VStack(alignment: .leading, spacing: 4) {
                Text("Includes:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(ThemeManager.Colors.primaryText)
                
                ForEach(event.includes, id: \.self) { item in
                    HStack(alignment: .top) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(ThemeManager.Colors.primary)
                        Text(item)
                            .font(.subheadline)
                            .foregroundColor(ThemeManager.Colors.secondaryText)
                    }
                }
            }
            
            // Book Button
            Button(action: {
                // TODO: Implement booking functionality
            }) {
                Text("Book Now")
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

struct CorporateEvent: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let date: Date
    let duration: Int // in minutes
    let location: String
    let maxParticipants: Int
    let price: Int
    let includes: [String]
    
    var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var formattedDuration: String {
        let hours = duration / 60
        let minutes = duration % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct CorporateEventBookingForm: View {
    @Environment(\.dismiss) var dismiss
    @State private var eventTitle = ""
    @State private var eventDate = Date()
    @State private var eventDuration = 120
    @State private var numberOfParticipants = 10
    @State private var specialRequirements = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Event Details")) {
                    TextField("Event Title", text: $eventTitle)
                    DatePicker("Date", selection: $eventDate, displayedComponents: [.date, .hourAndMinute])
                    Stepper("Duration: \(eventDuration) minutes", value: $eventDuration, in: 60...480, step: 30)
                    Stepper("Participants: \(numberOfParticipants)", value: $numberOfParticipants, in: 5...50)
                }
                
                Section(header: Text("Additional Information")) {
                    TextEditor(text: $specialRequirements)
                        .frame(height: 100)
                }
                
                Section {
                    Button(action: {
                        // TODO: Implement booking submission
                        dismiss()
                    }) {
                        Text("Submit Booking Request")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(ThemeManager.Colors.primary)
                }
            }
            .navigationTitle("Book Corporate Event")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
}

#Preview {
    NavigationView {
        EventRebookingView()
            .environmentObject(AppState())
    }
} 