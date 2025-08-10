//
//  VolunteerFeedView.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//


import Foundation
import SwiftUI
import Combine

@MainActor
class EventViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var categories: [String] = ["Cooking", "Delivery", "Fundraising", "Training", "Community"]
    
    var filteredEvents: [Event] {
        events
    }
    
    func loadEvents() {
        // Simulate loading events
        events = [
            Event(
                id: UUID(),
                title: "Community Cooking Session",
                description: "Join us for a collaborative cooking session preparing meals for local families in need.",
                startDate: Date().addingTimeInterval(86400), // Tomorrow
                endDate: Date().addingTimeInterval(86400 + 10800), // 3 hours later
                location: "Main Kitchen",
                maxVolunteers: 15,
                currentVolunteers: 8,
                status: .upcoming,
                type: .cooking,
                organizer: "Chef Michael",
                requirements: ["Food safety training", "Basic cooking skills"],
                imageURL: nil
            ),
            Event(
                id: UUID(),
                title: "Meal Delivery Volunteers",
                description: "Help deliver prepared meals to elderly community members and families.",
                startDate: Date().addingTimeInterval(172800), // Day after tomorrow
                endDate: Date().addingTimeInterval(172800 + 7200), // 2 hours later
                location: "Distribution Center",
                maxVolunteers: 10,
                currentVolunteers: 4,
                status: .upcoming,
                type: .distribution,
                organizer: "Volunteer Coordinator Sarah",
                requirements: ["Valid driver's license", "Vehicle"],
                imageURL: nil
            ),
            Event(
                id: UUID(),
                title: "Kids Giving Back: Junior Chefs",
                description: "A special program for children ages 8-16 to learn cooking skills while preparing meals for families in need. Parents welcome to join! This is a fun, educational experience teaching kids about nutrition, food preparation, and community service.",
                startDate: Date().addingTimeInterval(345600), // 4 days from now
                endDate: Date().addingTimeInterval(345600 + 9000), // 2.5 hours later
                location: "Main Kitchen - Kids Area",
                maxVolunteers: 12,
                currentVolunteers: 5,
                status: .upcoming,
                type: .cooking,
                organizer: "Chef Jennifer & Youth Coordinator Mike",
                requirements: ["No experience needed", "Ages 8-16", "Adult supervision for younger children"],
                imageURL: nil
            ),
            Event(
                id: UUID(),
                title: "Food Rescue Operation",
                description: "Join our team collecting surplus food from local markets and grocers that would otherwise go to waste. We'll sort, process, and prepare it for distribution to local food banks and shelters.",
                startDate: Date().addingTimeInterval(259200), // 3 days from now
                endDate: Date().addingTimeInterval(259200 + 10800), // 3 hours later
                location: "Community Hub",
                maxVolunteers: 8,
                currentVolunteers: 3,
                status: .upcoming,
                type: .distribution,
                organizer: "Sustainability Coordinator Alex",
                requirements: ["Ability to lift 10-15 lbs", "Food handling experience a plus"],
                imageURL: nil
            ),
            Event(
                id: UUID(),
                title: "Festive Meal Preparation",
                description: "Help prepare special holiday-themed meals for families experiencing food insecurity. We'll be cooking traditional dishes and packaging care packages with extra supplies.",
                startDate: Date().addingTimeInterval(432000), // 5 days from now
                endDate: Date().addingTimeInterval(432000 + 14400), // 4 hours later
                location: "Main Kitchen",
                maxVolunteers: 15,
                currentVolunteers: 6,
                status: .upcoming,
                type: .cooking,
                organizer: "Head Chef Daniel",
                requirements: ["Basic cooking skills helpful but not required"],
                imageURL: nil
            )
        ]
    }
}

struct VolunteerFeedView: View {
    @StateObject private var viewModel = EventViewModel()
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    
    var body: some View {
        NavigationStack {
            VStack {
                // Search and Filter
                HStack {
                    SearchBar(text: $searchText)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(["All"] + viewModel.categories, id: \.self) { category in
                            Text(category)
                        }
                    }
                    .pickerStyle(.menu)
                }
                .padding(.horizontal)
                
                // Events List
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.filteredEvents) { event in
                            NavigationLink(value: event) {
                                VolunteerEventCard(event: event)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Volunteer")
            .navigationDestination(for: Event.self) { event in
                VolunteerOpportunityDetailView(event: event)
            }
        }
        .onAppear {
            viewModel.loadEvents()
        }
    }
}

// MARK: - Supporting Views
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search events", text: $text)
                .textFieldStyle(.plain)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct VolunteerEventCard: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(event.title)
                .font(.headline)
            
            Text(event.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                Label("\(event.spotsRemaining) spots", systemImage: "person.fill")
                Spacer()
                Label(event.startDate.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}