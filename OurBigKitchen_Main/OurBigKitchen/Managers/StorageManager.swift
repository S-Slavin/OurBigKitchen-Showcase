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
    
    // MARK: - Impact Metric Operations
    
    func createImpactMetric(
        mealsServed: Int = 0,
        peopleFed: Int = 0,
        wasteReduced: Double = 0.0,
        carbonFootprintReduced: Double = 0.0,
        volunteerHours: Double = 0.0
    ) -> ImpactMetric {
        let metric = ImpactMetric(
            mealsServed: mealsServed,
            peopleFed: peopleFed,
            wasteReduced: wasteReduced,
            carbonFootprintReduced: carbonFootprintReduced,
            volunteerHours: volunteerHours
        )
        impactMetrics.append(metric)
        return metric
    }
    
    func fetchImpactMetrics(for userId: String? = nil, eventId: String? = nil) -> [ImpactMetric] {
        // For now, return all metrics since ImpactMetric doesn't have userId or eventId
        // This will be properly implemented when Core Data is fully set up
        return impactMetrics
    }
    
    func getTotalImpact() -> TotalImpact {
        let totalMeals = impactMetrics.reduce(0) { $0 + $1.mealsServed }
        let totalPeople = impactMetrics.reduce(0) { $0 + $1.peopleFed }
        let totalWaste = impactMetrics.reduce(0.0) { $0 + $1.wasteReduced }
        let totalCarbon = impactMetrics.reduce(0.0) { $0 + $1.carbonFootprintReduced }
        let totalHours = impactMetrics.reduce(0.0) { $0 + $1.volunteerHours }
        
        return TotalImpact(
            totalMealsServed: totalMeals,
            totalPeopleFed: totalPeople,
            totalWasteReduced: totalWaste,
            totalCarbonFootprintReduced: totalCarbon,
            totalVolunteerHours: totalHours
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
    
    // MARK: - Activity Operations
    
    func createActivity(
        title: String,
        description: String,
        category: AppModels.ActivityCategory,
        userId: String,
        duration: TimeInterval,
        eventId: String? = nil
    ) -> AppModels.Activity {
        let impact = AppModels.ImpactMetric() // Default impact
        let activity = AppModels.Activity(
            userId: userId,
            eventId: eventId,
            title: title,
            description: description,
            category: category,
            duration: duration,
            impact: impact
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
        
        let hoursVolunteered = Int(userMetrics.reduce(0.0) { $0 + $1.volunteerHours })
        let mealsPrepared = Int(userMetrics.reduce(0) { $0 + $1.mealsServed })
        let eventsAttended = Int(userMetrics.reduce(0) { $0 + $1.peopleFed })
        
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
