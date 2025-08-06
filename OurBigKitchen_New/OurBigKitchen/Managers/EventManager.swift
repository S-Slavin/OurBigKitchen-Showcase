import Foundation
import Combine

struct EmptyResponse: Decodable {}

class EventManager {
    static let shared = EventManager()
    private let networkManager: NetworkManager
    private let persistenceManager: PersistenceManager
    private let upcomingEventsKey = "upcoming_events"
    
    private init(networkManager: NetworkManager = .shared,
                persistenceManager: PersistenceManager = .shared) {
        self.networkManager = networkManager
        self.persistenceManager = persistenceManager
    }
    
    // MARK: - Event Operations
    
    func getUpcomingEvents() -> AnyPublisher<[Event], Error> {
        return networkManager.get(endpoint: "/events/upcoming")
            .handleEvents(receiveOutput: { [weak self] events in
                try? self?.persistenceManager.save(events, forKey: self?.upcomingEventsKey ?? "")
            })
            .catch { [weak self] error -> AnyPublisher<[Event], Error> in
                guard let self = self else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
                
                do {
                    let cachedEvents = try self.persistenceManager.getObject(forKey: self.upcomingEventsKey, as: [Event].self)
                    return Just(cachedEvents)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                } catch {
                    // Return empty array in case of error
                    return Just([])
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func getEventDetails(eventId: String) -> AnyPublisher<Event, Error> {
        return networkManager.get(endpoint: "/events/\(eventId)")
    }
    
    func registerForEvent(eventId: String, userId: String) -> AnyPublisher<EmptyResponse, Error> {
        let registration = ["eventId": eventId, "userId": userId]
        return networkManager.post(endpoint: "/events/register", body: registration)
    }
    
    func unregisterFromEvent(eventId: String, userId: String) -> AnyPublisher<EmptyResponse, Error> {
        let unregistration = ["eventId": eventId, "userId": userId]
        return networkManager.post(endpoint: "/events/unregister", body: unregistration)
    }
    
    func getUserEvents(userId: String) -> AnyPublisher<[Event], Error> {
        return networkManager.get(endpoint: "/events/user/\(userId)")
    }
    
    // MARK: - Async Versions
    
    func getUpcomingEvents() async throws -> [Event] {
        do {
            // Try to get from network
            let events: [Event] = try await networkManager.getAsync(endpoint: "/events/upcoming")
            try persistenceManager.save(events, forKey: upcomingEventsKey)
            return events
        } catch {
            // Try to get from cache
            do {
                return try persistenceManager.getObject(forKey: upcomingEventsKey, as: [Event].self)
            } catch {
                // Create mock data for demo purposes
                return [
                    Event(
                        title: "Community Cooking Session",
                        description: "Join us for a collaborative cooking session preparing meals for local families in need.",
                        startDate: Date().addingTimeInterval(86400), // Tomorrow
                        endDate: Date().addingTimeInterval(86400 + 10800), // 3 hours later
                        location: "Main Kitchen",
                        maxVolunteers: 15,
                        currentVolunteers: 8,
                        type: .cooking,
                        organizer: "Chef Michael"
                    ),
                    Event(
                        title: "Meal Delivery Volunteers",
                        description: "Help deliver prepared meals to elderly community members and families.",
                        startDate: Date().addingTimeInterval(172800), // Day after tomorrow
                        endDate: Date().addingTimeInterval(172800 + 7200), // 2 hours later
                        location: "Distribution Center",
                        maxVolunteers: 10,
                        currentVolunteers: 4,
                        status: .upcoming,
                        type: .distribution,
                        organizer: "Volunteer Coordinator Sarah"
                    )
                ]
            }
        }
    }
    
    // MARK: - Cache Management
    
    func clearCache() {
        try? persistenceManager.remove(forKey: upcomingEventsKey)
    }
} 