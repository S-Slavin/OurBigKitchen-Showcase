import Foundation
import Combine
import SwiftUI

@MainActor
class RealEventService: ObservableObject {
    static let shared = RealEventService()
    
    @Published var events: [Event] = []
    @Published var userEvents: [Event] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private let coreDataManager = CoreDataManager.shared
    
    private init() {
        loadEvents()
    }
    
    // MARK: - Event Management
    
    func loadEvents() {
        isLoading = true
        errorMessage = ""
        
        let loadedEvents = coreDataManager.fetchEvents()
        self.events = loadedEvents
        self.isLoading = false
    }
    
    func createEvent(
        title: String,
        description: String,
        category: EventCategory,
        date: Date,
        location: String,
        maxVolunteers: Int
    ) {
        let newEvent = coreDataManager.createEvent(
            title: title,
            description: description,
            category: category,
            date: date,
            location: location,
            maxVolunteers: maxVolunteers
        )
        
        events.append(newEvent)
        loadEvents()
    }
    
    func updateEvent(_ event: Event) {
        coreDataManager.updateEvent(event)
        loadEvents()
    }
    
    func deleteEvent(_ event: Event) {
        coreDataManager.deleteEvent(event)
        loadEvents()
    }
    
    // MARK: - Volunteer Management
    
    func joinEvent(_ event: Event, userId: String) {
        guard let eventIndex = events.firstIndex(where: { $0.id == event.id }) else { return }
        
        var updatedEvent = event
        if updatedEvent.currentVolunteers < updatedEvent.maxVolunteers {
            updatedEvent.currentVolunteers += 1
            events[eventIndex] = updatedEvent
            coreDataManager.updateEvent(updatedEvent)
        }
    }
    
    func leaveEvent(_ event: Event, userId: String) {
        guard let eventIndex = events.firstIndex(where: { $0.id == event.id }) else { return }
        
        var updatedEvent = event
        if updatedEvent.currentVolunteers > 0 {
            updatedEvent.currentVolunteers -= 1
            events[eventIndex] = updatedEvent
            coreDataManager.updateEvent(updatedEvent)
        }
    }
    
    func isUserRegistered(for event: Event, userId: String) -> Bool {
        // Since Event doesn't have a volunteers array, we'll use a simple approach
        // In a real implementation, you'd track this separately
        return false
    }
    
    // MARK: - Event Filtering and Search
    
    func searchEvents(query: String) -> [Event] {
        guard !query.isEmpty else { return events }
        
        return events.filter { event in
            event.title.localizedCaseInsensitiveContains(query) ||
            event.description.localizedCaseInsensitiveContains(query) ||
            (event.category?.localizedCaseInsensitiveContains(query) ?? false) ||
            event.location.localizedCaseInsensitiveContains(query)
        }
    }
    
    func filterEvents(by category: EventCategory?) -> [Event] {
        guard let category = category else { return events }
        
        return events.filter { event in
            event.category == category.rawValue
        }
    }
    
    func filterEvents(by status: Event.EventStatus) -> [Event] {
        return events.filter { $0.status == status }
    }
    
    func filterEvents(by date: Date) -> [Event] {
        let calendar = Calendar.current
        return events.filter { event in
            calendar.isDate(event.startDate, inSameDayAs: date)
        }
    }
    
    // MARK: - User Events
    
    func loadUserEvents(for userId: String) {
        // In a real implementation, you'd filter events where the user is registered
        // For now, we'll return all events
        userEvents = events
    }
    
    // MARK: - Event Statistics
    
    func getEventStats() -> (total: Int, upcoming: Int, completed: Int) {
        let total = events.count
        let upcoming = events.filter { $0.status == .upcoming }.count
        let completed = events.filter { $0.status == .completed }.count
        
        return (total, upcoming, completed)
    }
}
