import Foundation
import Combine

// MARK: - Types

struct ImpactSummary {
    let mealsServed: Int
    let peopleFed: Int
    let wasteReduced: Double
    let carbonFootprintReduced: Double
    let volunteerHours: Double
}

// MARK: - Storage Manager

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
        maxVolunteers: Int
    ) -> Event {
        let event = Event(
            title: title,
            description: description,
            startDate: startDate,
            endDate: endDate,
            location: location,
            maxVolunteers: maxVolunteers,
            type: .cooking,
            organizer: "System"
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
    
    // MARK: - Impact Metric Management
    
    func createImpactMetric(
        type: ImpactMetricType,
        value: Double,
        userId: String,
        eventId: String? = nil
    ) -> AppModels.ImpactMetric {
        return AppModels.ImpactMetric(
            type: .mealsServed, // Default type, will be mapped properly later
            value: value,
            unit: "units",
            date: Date()
        )
    }
    
    func getImpactMetrics(for userId: String) -> [AppModels.ImpactMetric] {
        // TODO: Implement when Core Data entities are defined
        return []
    }
    
    func getTotalImpact(for userId: String) -> ImpactSummary {
        let impactMetrics = getImpactMetrics(for: userId)
        
        let totalMeals = impactMetrics.reduce(0.0) { $0 + ($1.type == .mealsServed ? $1.value : 0) }
        let totalPeople = impactMetrics.reduce(0.0) { $0 + ($1.type == .peopleFed ? $1.value : 0) }
        let totalWaste = impactMetrics.reduce(0.0) { $0 + ($1.type == .wasteReduced ? $1.value : 0) }
        let totalCarbon = impactMetrics.reduce(0.0) { $0 + ($1.type == .carbonFootprintReduced ? $1.value : 0) }
        let totalHours = impactMetrics.reduce(0.0) { $0 + ($1.type == .volunteerHours ? $1.value : 0) }
        
        return ImpactSummary(
            mealsServed: Int(totalMeals),
            peopleFed: Int(totalPeople),
            wasteReduced: totalWaste,
            carbonFootprintReduced: totalCarbon,
            volunteerHours: totalHours
        )
    }
    
    // MARK: - Volunteer Session Operations
    
    func createVolunteerSession(
        userId: String,
        eventId: String,
        checkInTime: Date,
        notes: String? = nil
    ) -> VolunteerSession {
        let session = VolunteerSession(
            userId: userId,
            eventId: eventId,
            checkInTime: checkInTime,
            notes: notes
        )
        volunteerSessions.append(session)
        return session
    }
    
    func updateVolunteerSession(_ session: VolunteerSession) {
        if let index = volunteerSessions.firstIndex(where: { $0.id == session.id }) {
            volunteerSessions[index] = session
        }
    }
    
    func fetchVolunteerSessions(for userId: String? = nil, eventId: String? = nil, status: String? = nil) -> [VolunteerSession] {
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
    
    // MARK: - Activity Management
    
    func createActivity(
        title: String,
        description: String,
        category: AppModels.ActivityCategory,
        date: Date,
        duration: TimeInterval,
        userId: String,
        eventId: String? = nil
    ) -> AppModels.Activity {
        let impact = AppModels.ImpactMetric(type: .mealsServed, value: 0, unit: "units", date: date)
        
        let activity = AppModels.Activity(
            title: title,
            description: description,
            category: category,
            date: date,
            duration: duration,
            location: "",
            participants: [userId],
            impact: impact
        )
        
        return activity
    }
    
    func getActivities(for userId: String) -> [AppModels.Activity] {
        // TODO: Implement when Core Data entities are defined
        return []
    }
    
    func getUserStats(for userId: String) -> AppModels.UserStats {
        let userMetrics = getImpactMetrics(for: userId)
        
        let hoursVolunteered = Int(userMetrics.reduce(0.0) { $0 + ($1.type == .volunteerHours ? $1.value : 0) })
        let mealsPrepared = Int(userMetrics.reduce(0.0) { $0 + ($1.type == .mealsServed ? $1.value : 0) })
        let eventsAttended = Int(userMetrics.reduce(0.0) { $0 + ($1.type == .peopleFed ? $1.value : 0) })
        
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
