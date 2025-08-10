import Foundation
import Combine
import SwiftUI

@MainActor
class RealEventService: ObservableObject {
    static let shared = RealEventService()
    
    @Published var upcomingEvents: [Event] = []
    @Published var pastEvents: [Event] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private let coreDataManager = CoreDataManager.shared
    
    private init() {
        loadEvents()
    }
    
    // MARK: - Event Management
    
    func createEvent(
        name: String,
        description: String,
        date: Date,
        location: String,
        type: String,
        maxVolunteers: Int32
    ) async throws -> Event {
        isLoading = true
        defer { isLoading = false }
        
        // Validate input
        try validateEventInput(
            name: name,
            description: description,
            date: date,
            location: location,
            maxVolunteers: maxVolunteers
        )
        
        // Create event in Core Data
        let event = coreDataManager.createEvent(
            name: name,
            description: description,
            date: date,
            location: location,
            type: type,
            maxVolunteers: maxVolunteers
        )
        
        // Refresh events list
        loadEvents()
        
        return event
    }
    
    func updateEvent(_ event: Event) async throws {
        isLoading = true
        defer { isLoading = false }
        
        coreDataManager.updateEvent(event)
        loadEvents()
    }
    
    func deleteEvent(_ event: Event) async throws {
        isLoading = true
        defer { isLoading = false }
        
        coreDataManager.deleteEvent(event)
        loadEvents()
    }
    
    func joinEvent(_ event: Event, userId: String) async throws {
        guard let user = coreDataManager.fetchUser(by: userId) else {
            throw EventError.userNotFound
        }
        
        // Check if user is already registered
        if let volunteers = event.volunteers?.allObjects as? [User],
           volunteers.contains(where: { $0.id == userId }) {
            throw EventError.alreadyRegistered
        }
        
        // Check if event is full
        if let volunteers = event.volunteers?.allObjects as? [User],
           volunteers.count >= event.maxVolunteers {
            throw EventError.eventFull
        }
        
        // Add user to event
        event.addToVolunteers(user)
        coreDataManager.updateEvent(event)
        
        // Refresh events list
        loadEvents()
    }
    
    func leaveEvent(_ event: Event, userId: String) async throws {
        guard let user = coreDataManager.fetchUser(by: userId) else {
            throw EventError.userNotFound
        }
        
        // Remove user from event
        event.removeFromVolunteers(user)
        coreDataManager.updateEvent(event)
        
        // Refresh events list
        loadEvents()
    }
    
    func getEventDetails(_ eventId: String) -> Event? {
        return coreDataManager.fetchEvents().first { $0.id == eventId }
    }
    
    func getEventsForUser(_ userId: String) -> [Event] {
        return coreDataManager.fetchEvents().filter { event in
            guard let volunteers = event.volunteers?.allObjects as? [User] else { return false }
            return volunteers.contains { $0.id == userId }
        }
    }
    
    func searchEvents(query: String) -> [Event] {
        let allEvents = coreDataManager.fetchEvents()
        
        if query.isEmpty {
            return allEvents
        }
        
        return allEvents.filter { event in
            event.name?.localizedCaseInsensitiveContains(query) == true ||
            event.description?.localizedCaseInsensitiveContains(query) == true ||
            event.location?.localizedCaseInsensitiveContains(query) == true ||
            event.type?.localizedCaseInsensitiveContains(query) == true
        }
    }
    
    func filterEvents(
        by type: String? = nil,
        by location: String? = nil,
        by dateRange: DateInterval? = nil
    ) -> [Event] {
        let allEvents = coreDataManager.fetchEvents()
        
        return allEvents.filter { event in
            var matches = true
            
            if let type = type, event.type != type {
                matches = false
            }
            
            if let location = location, event.location != location {
                matches = false
            }
            
            if let dateRange = dateRange, let eventDate = event.date {
                if !dateRange.contains(eventDate) {
                    matches = false
                }
            }
            
            return matches
        }
    }
    
    // MARK: - Volunteer Session Management
    
    func checkInToEvent(_ event: Event, userId: String, notes: String? = nil) async throws -> VolunteerSession {
        guard let user = coreDataManager.fetchUser(by: userId) else {
            throw EventError.userNotFound
        }
        
        // Check if user is registered for the event
        guard let volunteers = event.volunteers?.allObjects as? [User],
              volunteers.contains(where: { $0.id == userId }) else {
            throw EventError.notRegistered
        }
        
        // Check if user already has an active session
        let activeSessions = coreDataManager.fetchVolunteerSessions(
            for: userId,
            eventId: event.id,
            status: "active"
        )
        
        if !activeSessions.isEmpty {
            throw EventError.alreadyCheckedIn
        }
        
        // Create volunteer session
        let session = coreDataManager.createVolunteerSession(
            userId: userId,
            eventId: event.id,
            checkInTime: Date(),
            notes: notes
        )
        
        return session
    }
    
    func checkOutFromEvent(_ event: Event, userId: String) async throws {
        // Find active session for this user and event
        let activeSessions = coreDataManager.fetchVolunteerSessions(
            for: userId,
            eventId: event.id,
            status: "active"
        )
        
        guard let session = activeSessions.first else {
            throw EventError.noActiveSession
        }
        
        // Check out the session
        coreDataManager.checkOutVolunteerSession(session)
        
        // Update user stats
        if let user = coreDataManager.fetchUser(by: userId),
           let stats = user.stats {
            let hoursToAdd = session.duration / 3600
            stats.hoursVolunteered += Int32(hoursToAdd)
            coreDataManager.updateUser(user)
        }
    }
    
    func getVolunteerSessions(for eventId: String) -> [VolunteerSession] {
        return coreDataManager.fetchVolunteerSessions(eventId: eventId)
    }
    
    func getVolunteerSessions(for userId: String) -> [VolunteerSession] {
        return coreDataManager.fetchVolunteerSessions(for: userId)
    }
    
    // MARK: - Impact Tracking
    
    func recordImpact(
        eventId: String,
        userId: String,
        mealsPrepared: Int32,
        peopleServed: Int32,
        notes: String? = nil
    ) async throws -> ImpactMetric {
        // Create impact metric
        let impactMetric = coreDataManager.createImpactMetric(
            userId: userId,
            eventId: eventId,
            activityId: nil,
            type: "meal_preparation",
            value: Double(mealsPrepared),
            mealsPrepared: mealsPrepared,
            peopleServed: peopleServed
        )
        
        // Update user stats
        if let user = coreDataManager.fetchUser(by: userId),
           let stats = user.stats {
            stats.mealsPrepared += mealsPrepared
            coreDataManager.updateUser(user)
        }
        
        return impactMetric
    }
    
    func getEventImpact(_ eventId: String) -> (meals: Int32, people: Int32) {
        let metrics = coreDataManager.fetchImpactMetrics(eventId: eventId)
        
        let totalMeals = metrics.reduce(0) { $0 + $1.mealsPrepared }
        let totalPeople = metrics.reduce(0) { $0 + $1.peopleServed }
        
        return (meals: totalMeals, people: totalPeople)
    }
    
    func getTotalImpact() -> (meals: Int32, people: Int32) {
        return coreDataManager.getTotalImpact()
    }
    
    // MARK: - Helper Methods
    
    private func loadEvents() {
        let allEvents = coreDataManager.fetchEvents()
        let now = Date()
        
        upcomingEvents = allEvents.filter { event in
            guard let eventDate = event.date else { return false }
            return eventDate > now
        }.sorted { event1, event2 in
            guard let date1 = event1.date, let date2 = event2.date else { return false }
            return date1 < date2
        }
        
        pastEvents = allEvents.filter { event in
            guard let eventDate = event.date else { return false }
            return eventDate <= now
        }.sorted { event1, event2 in
            guard let date1 = event1.date, let date2 = event2.date else { return false }
            return date1 > date2
        }
    }
    
    private func validateEventInput(
        name: String,
        description: String,
        date: Date,
        location: String,
        maxVolunteers: Int32
    ) throws {
        guard !name.isEmpty else {
            throw EventError.invalidName
        }
        
        guard !description.isEmpty else {
            throw EventError.invalidDescription
        }
        
        guard !location.isEmpty else {
            throw EventError.invalidLocation
        }
        
        guard date > Date() else {
            throw EventError.invalidDate
        }
        
        guard maxVolunteers > 0 else {
            throw EventError.invalidMaxVolunteers
        }
    }
}

// MARK: - Event Errors

enum EventError: LocalizedError {
    case userNotFound
    case alreadyRegistered
    case notRegistered
    case eventFull
    case alreadyCheckedIn
    case noActiveSession
    case invalidName
    case invalidDescription
    case invalidLocation
    case invalidDate
    case invalidMaxVolunteers
    
    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "User not found"
        case .alreadyRegistered:
            return "You are already registered for this event"
        case .notRegistered:
            return "You are not registered for this event"
        case .eventFull:
            return "This event is full"
        case .alreadyCheckedIn:
            return "You are already checked in to this event"
        case .noActiveSession:
            return "No active session found"
        case .invalidName:
            return "Event name is required"
        case .invalidDescription:
            return "Event description is required"
        case .invalidLocation:
            return "Event location is required"
        case .invalidDate:
            return "Event date must be in the future"
        case .invalidMaxVolunteers:
            return "Maximum volunteers must be greater than 0"
        }
    }
}
