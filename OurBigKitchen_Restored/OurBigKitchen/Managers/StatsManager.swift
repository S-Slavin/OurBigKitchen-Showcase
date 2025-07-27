//
//  StatsManager.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//


import Foundation
import Combine

// MARK: - Models
enum RankingCategory: String, Codable {
    case meals
    case volunteers
    case donations
    case impact
}

// New Enum for time range selection
enum StatsTimeframe {
    case day
    case week
    case month
    case year
    case allTime
    
    var startDate: Date {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .day:
            return calendar.startOfDay(for: now)
        case .week:
            return calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            return calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case .year:
            return calendar.date(byAdding: .year, value: -1, to: now) ?? now
        case .allTime:
            return calendar.date(byAdding: .year, value: -5, to: now) ?? now // Limit to 5 years
        }
    }
    
    var endDate: Date {
        return Date()
    }
}

struct CorporateRanking: Codable {
    let partnerId: String
    let name: String
    let score: Int
    let rank: Int
}

// DailyStats model is imported from Models/DailyStats.swift

@MainActor
class StatsManager {
    static let shared = StatsManager()
    
    private let networkManager: NetworkManager
    private let persistenceManager: PersistenceManager
    private let statsKey = "today_stats"
    private let dateFormatter: ISO8601DateFormatter
    
    init(networkManager: NetworkManager? = nil,
                persistenceManager: PersistenceManager? = nil) {
        self.networkManager = networkManager ?? NetworkManager.shared
        self.persistenceManager = persistenceManager ?? PersistenceManager.shared
        self.dateFormatter = ISO8601DateFormatter()
    }
    
    // MARK: - Daily Stats Operations
    
    func getTodayStats() async -> AnyPublisher<DailyStats, Error> {
        // First try to get from persistence
        if let cachedStats = try? persistenceManager.getObject(forKey: statsKey, as: DailyStats.self) {
            return Just(cachedStats)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        // If not in persistence, fetch from network
        return networkManager.get(endpoint: "/stats/daily/\(dateFormatter.string(from: Date()))")
            .handleEvents(receiveOutput: { [weak self] stats in
                Task {
                    try? self?.persistenceManager.save(stats, forKey: self?.statsKey ?? "")
                }
            })
            .eraseToAnyPublisher()
    }
    
    func getDailyStats(from startDate: Date, to endDate: Date) -> AnyPublisher<[DailyStats], Error> {
        return networkManager.get(endpoint: "/stats/daily?from=\(dateFormatter.string(from: startDate))&to=\(dateFormatter.string(from: endDate))")
    }
    
    func getDailyStats(for timeframe: StatsTimeframe) -> AnyPublisher<[DailyStats], Error> {
        return getDailyStats(from: timeframe.startDate, to: timeframe.endDate)
    }
    
    func updateDailyStats(_ stats: DailyStats) -> AnyPublisher<DailyStats, Error> {
        return networkManager.put(endpoint: "/stats/daily/\(stats.id)", body: stats)
            .handleEvents(receiveOutput: { [weak self] updatedStats in
                Task {
                    if Calendar.current.isDateInToday(updatedStats.date) {
                        try? self?.persistenceManager.save(updatedStats, forKey: self?.statsKey ?? "")
                    }
                }
            })
            .eraseToAnyPublisher()
    }
    
    // MARK: - Impact Metrics Operations
    
    func getImpactMetrics() -> AnyPublisher<[AppModels.ImpactMetric], Error> {
        return networkManager.get(endpoint: "/stats/impact")
    }
    
    func updateImpactMetric(_ metric: AppModels.ImpactMetric) -> AnyPublisher<AppModels.ImpactMetric, Error> {
        return networkManager.put(endpoint: "/stats/impact", body: metric)
    }
    
    // MARK: - User Impact Operations
    
    func getUserImpact() async -> AnyPublisher<Impact, Error> {
        guard let userId = UserManager.shared.currentUserId else {
            // Return a default impact if no user is logged in
            let impact = Impact(id: UUID().uuidString, userId: "", timeSpent: 0, mealsMade: 0)
            return Just(impact)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        // In a real implementation, this would fetch from the network
        // For mock purposes, we'll generate a random impact
        let lastDigit = Int(userId.suffix(1)) ?? 0
        
        let impact = Impact(
            id: UUID().uuidString,
            userId: userId,
            timeSpent: 5 + lastDigit,
            mealsMade: 50 + (lastDigit * 10)
        )
        
        return Just(impact)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Corporate Rankings Operations
    
    func getCorporateRankings(category: RankingCategory) -> AnyPublisher<[CorporateRanking], Error> {
        return networkManager.get(endpoint: "/stats/rankings/corporate/\(category.rawValue)")
    }
    
    // MARK: - Analytics Operations
    
    func getAnalyticsReport(startDate: Date, endDate: Date) -> AnyPublisher<AppModels.AnalyticsReport, Error> {
        return networkManager.get(endpoint: "/stats/analytics?from=\(dateFormatter.string(from: startDate))&to=\(dateFormatter.string(from: endDate))")
    }
    
    // MARK: - Meal Tracking Operations

    func addMealEntry(_ entry: MealEntry) async -> AnyPublisher<DailyStats, Error> {
        // First get the current daily stats
        let statsPublisher = await getTodayStats()
        return statsPublisher
            .flatMap { [weak self] currentStats -> AnyPublisher<DailyStats, Error> in
                guard let self = self else {
                    return Fail(error: NSError(domain: "StatsManager", code: 500, userInfo: [NSLocalizedDescriptionKey: "Self is nil"]))
                        .eraseToAnyPublisher()
                }
                
                // If entry date is today, update today's stats
                if Calendar.current.isDate(entry.date, inSameDayAs: Date()) {
                    // Create a new stats object with updated meal count
                    // In a real implementation, we'd modify the existing object properly
                    let newStats = DailyStats(
                        id: currentStats.id,
                        date: currentStats.date,
                        mealsServed: currentStats.mealsServed + entry.mealCount,
                        volunteersPresent: currentStats.volunteersPresent,
                        hoursContributed: currentStats.hoursContributed,
                        peopleServed: currentStats.peopleServed,
                        foodWasteSaved: currentStats.foodWasteSaved,
                        donationsReceived: currentStats.donationsReceived
                    )
                    
                    return self.updateDailyStats(newStats)
                } else {
                    // For historical entries, we'd need to get the stats for that date and update them
                    // For simplicity in this implementation, we'll just return the current stats
                    return Just(currentStats)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Volunteer Operations

    func addVolunteerRegistration(_ registration: VolunteerRegistration) async -> AnyPublisher<DailyStats, Error> {
        // First get the current daily stats
        let statsPublisher = await getTodayStats()
        return statsPublisher
            .flatMap { [weak self] currentStats -> AnyPublisher<DailyStats, Error> in
                guard let self = self else {
                    return Fail(error: NSError(domain: "StatsManager", code: 500, userInfo: [NSLocalizedDescriptionKey: "Self is nil"]))
                        .eraseToAnyPublisher()
                }
                
                // Update volunteer count and hours
                let updatedVolunteers = currentStats.volunteersPresent + 1
                let hoursContributed = currentStats.hoursContributed + (registration.duration / 3600.0)
                
                // Create a new stats object with updated volunteer data
                let newStats = DailyStats(
                    id: currentStats.id,
                    date: currentStats.date,
                    mealsServed: currentStats.mealsServed,
                    volunteersPresent: updatedVolunteers,
                    hoursContributed: hoursContributed,
                    peopleServed: currentStats.peopleServed,
                    foodWasteSaved: currentStats.foodWasteSaved,
                    donationsReceived: currentStats.donationsReceived
                )
                
                return self.updateDailyStats(newStats)
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Helper Methods
    
    func clearStatsCache() async {
        persistenceManager.remove(forKey: statsKey)
    }
} 