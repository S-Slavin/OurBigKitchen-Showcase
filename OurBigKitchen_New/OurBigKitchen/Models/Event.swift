//
//  Event.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//


import Foundation
import SwiftUI

struct Event: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let description: String
    let startDate: Date
    let endDate: Date
    let location: String
    let maxVolunteers: Int
    var currentVolunteers: Int
    var status: EventStatus
    let type: EventType
    let organizer: String
    let requirements: [String]
    let imageURL: URL?
    var category: String? = nil
    var program: String? = nil
    
    enum EventType: String, Codable, CaseIterable, Hashable {
        case cooking = "cooking"
        case distribution = "distribution"
        case training = "training"
        case other = "other"
        
        var color: Color {
            switch self {
            case .cooking:
                return .blue
            case .distribution:
                return .green
            case .training:
                return .purple
            case .other:
                return .gray
            }
        }
    }
    
    enum EventStatus: String, Codable, Hashable {
        case upcoming = "upcoming"
        case inProgress = "in_progress"
        case completed = "completed"
        case cancelled = "cancelled"
    }
    
    // Computed properties
    var isFull: Bool {
        currentVolunteers >= maxVolunteers
    }
    
    var date: Date {
        // For compatibility with HomeView
        return startDate
    }
    
    var spotsRemaining: Int {
        max(0, maxVolunteers - currentVolunteers)
    }
    
    var formattedDateRange: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        let startString = formatter.string(from: startDate)
        let endString = formatter.string(from: endDate)
        
        return "\(startString) - \(endString)"
    }
    
    var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }
    
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    // Initializer
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        startDate: Date,
        endDate: Date,
        location: String,
        maxVolunteers: Int,
        currentVolunteers: Int = 0,
        status: EventStatus = .upcoming,
        type: EventType,
        organizer: String,
        requirements: [String] = [],
        imageURL: URL? = nil,
        category: String? = nil,
        program: String? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
        self.maxVolunteers = maxVolunteers
        self.currentVolunteers = currentVolunteers
        self.status = status
        self.type = type
        self.organizer = organizer
        self.requirements = requirements
        self.imageURL = imageURL
        self.category = category
        self.program = program
    }
}

// Sample data for previews
extension Event {
    static var sampleEvents: [Event] {
        [
        Event(
            title: "Community Kitchen Day",
            description: "Join us for a day of cooking and community service",
            startDate: Date().addingTimeInterval(86400), // Tomorrow
            endDate: Date().addingTimeInterval(93600), // 2 hours later
            location: "Main Kitchen",
            maxVolunteers: 10,
            type: .cooking,
            organizer: "John Smith"
        ),
        Event(
            title: "Food Distribution",
            description: "Help distribute meals to those in need",
            startDate: Date().addingTimeInterval(172800), // Day after tomorrow
            endDate: Date().addingTimeInterval(180000), // 2 hours later
            location: "Distribution Center",
            maxVolunteers: 15,
            type: .distribution,
            organizer: "Jane Doe"
        )
        ]
    }
}