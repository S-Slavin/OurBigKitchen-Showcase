import Foundation
import Combine

@MainActor
class StorageManager: ObservableObject {
    static let shared = StorageManager()
    
    @Published var users: [AppModels.User] = []
    @Published var events: [Event] = []
    @Published var impactMetrics: [ImpactMetric] = []
    @Published var volunteerSessions: [VolunteerSession] = []
    @Published var activities: [AppModels.Activity] = []
    
    private init() {}
    
    // MARK: - User Operations
    
    func createUser(
        firstName: String,
        lastName: String,
        email: String,
        role: AppModels.UserRole,
        dob: Date? = nil,
        wwcNumber: String? = nil,
        wwcExpiry: Date? = nil,
        companyName: String? = nil,
        companyPosition: String? = nil,
        companyEmail: String? = nil
    ) -> AppModels.User {
        let user = AppModels.User(
            firstName: firstName,
            lastName: lastName,
            email: email,
            role: role,
            dob: dob,
            wwcNumber: wwcNumber,
            wwcExpiry: wwcExpiry,
            companyName: companyName,
            companyPosition: companyPosition,
            companyEmail: companyEmail
        )
        users.append(user)
        return user
    }
    
    func fetchUser(by email: String) -> AppModels.User? {
        return users.first { $0.email == email }
    }
    
    func fetchUser(by id: String) -> AppModels.User? {
        return users.first { $0.id == id }
    }
    
    func updateUser(_ user: AppModels.User) {
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index] = user
        }
    }
    
    func fetchUsers() -> [AppModels.User] {
        return users
    }
    
    // MARK: - Event Operations
    
    func createEvent(
        title: String,
        description: String,
        startDate: Date,
        endDate: Date,
        location: String,
        maxVolunteers: Int,
        organizer: String,
        type: Event.EventType,
        status: Event.EventStatus = .upcoming,
        requirements: [String] = [],
        imageURL: URL? = nil
    ) -> Event {
        let event = Event(
            title: title,
            description: description,
            startDate: startDate,
            endDate: endDate,
            location: location,
            maxVolunteers: maxVolunteers,
            currentVolunteers: 0,
            status: status,
            type: type,
            organizer: organizer,
            requirements: requirements,
            imageURL: imageURL
        )
        events.append(event)
        return event
    }
    
    func updateEvent(_ event: Event) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = event
        }
    }
    
    func deleteEvent(_ event: Event) {
        events.removeAll { $0.id == event.id }
    }
    
    func fetchEvents() -> [Event] {
        return events
    }
    
    func fetchEvent(by id: String) -> Event? {
        guard let uuid = UUID(uuidString: id) else { return nil }
        return events.first { $0.id == uuid }
    }
    
    // MARK: - Impact Metric Operations
    
    func createImpactMetric(
        type: AppModels.ImpactMetricType,
        value: Double,
        description: String,
        userId: String,
        eventId: String? = nil,
        date: Date = Date()
    ) -> AppModels.ImpactMetric {
        let metric = AppModels.ImpactMetric(
            type: type,
            value: value,
            description: description,
            userId: userId,
            eventId: eventId,
            date: date
        )
        impactMetrics.append(metric)
        return metric
    }
    
    func fetchImpactMetrics(for userId: String? = nil, eventId: String? = nil) -> [AppModels.ImpactMetric] {
        var filtered = impactMetrics
        
        if let userId = userId {
            filtered = filtered.filter { $0.userId == userId }
        }
        
        if let eventId = eventId {
            filtered = filtered.filter { $0.eventId == eventId }
        }
        
        return filtered
    }
    
    func getTotalImpact() -> AppModels.TotalImpact {
        let totalMeals = impactMetrics.filter { $0.type == .mealsPrepared }.reduce(0) { $0 + $1.value }
        let totalHours = impactMetrics.filter { $0.type == .hoursVolunteered }.reduce(0) { $0 + $1.value }
        let totalEvents = impactMetrics.filter { $0.type == .eventsAttended }.reduce(0) { $0 + $1.value }
        
        return AppModels.TotalImpact(
            totalMeals: Int(totalMeals),
            totalHours: Int(totalHours),
            totalEvents: Int(totalEvents)
        )
    }
    
    // MARK: - Volunteer Session Operations
    
    func createVolunteerSession(
        userId: String,
        eventId: String,
        startTime: Date,
        endTime: Date? = nil,
        status: AppModels.VolunteerSessionStatus = .active
    ) -> AppModels.VolunteerSession {
        let session = AppModels.VolunteerSession(
            userId: userId,
            eventId: eventId,
            startTime: startTime,
            endTime: endTime,
            status: status
        )
        volunteerSessions.append(session)
        return session
    }
    
    func updateVolunteerSession(_ session: AppModels.VolunteerSession) {
        if let index = volunteerSessions.firstIndex(where: { $0.id == session.id }) {
            volunteerSessions[index] = session
        }
    }
    
    func fetchVolunteerSessions(for userId: String? = nil, eventId: String? = nil, status: String? = nil) -> [AppModels.VolunteerSession] {
        var filtered = volunteerSessions
        
        if let userId = userId {
            filtered = filtered.filter { $0.userId == userId }
        }
        
        if let eventId = eventId {
            filtered = filtered.filter { $0.eventId == eventId }
        }
        
        if let status = status {
            filtered = filtered.filter { $0.status.rawValue == status }
        }
        
        return filtered
    }
    
    // MARK: - Activity Operations
    
    func createActivity(
        type: AppModels.ActivityType,
        title: String,
        description: String,
        userId: String,
        date: Date = Date()
    ) -> AppModels.Activity {
        let activity = AppModels.Activity(
            type: type,
            title: title,
            description: description,
            userId: userId,
            date: date
        )
        activities.append(activity)
        return activity
    }
    
    func fetchActivities(for userId: String) -> [AppModels.Activity] {
        return activities.filter { $0.userId == userId }
    }
    
    // MARK: - User Stats Operations
    
    func getUserStats(for userId: String) -> AppModels.UserStats {
        let userMetrics = fetchImpactMetrics(for: userId)
        
        let hoursVolunteered = Int(userMetrics.filter { $0.type == .hoursVolunteered }.reduce(0) { $0 + $1.value })
        let mealsPrepared = Int(userMetrics.filter { $0.type == .mealsPrepared }.reduce(0) { $0 + $1.value })
        let eventsAttended = Int(userMetrics.filter { $0.type == .eventsAttended }.reduce(0) { $0 + $1.value })
        
        return AppModels.UserStats(
            hoursVolunteered: hoursVolunteered,
            mealsPrepared: mealsPrepared,
            eventsAttended: eventsAttended
        )
    }
    
    func updateUserStats(for userId: String) {
        // This will be handled automatically when impact metrics are updated
    }
}
