import Foundation
import Combine
import SwiftUI

@MainActor
class RealImpactService: ObservableObject {
    static let shared = RealImpactService()
    
    @Published var totalImpact: (meals: Int32, people: Int32) = (0, 0)
    @Published var userImpact: (meals: Int32, people: Int32, hours: Double) = (0, 0, 0.0)
    @Published var impactHistory: [ImpactMetric] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private let coreDataManager = CoreDataManager.shared
    
    private init() {
        loadImpactData()
    }
    
    // MARK: - Impact Tracking
    
    func recordMealPreparation(
        userId: String,
        eventId: String?,
        mealsPrepared: Int32,
        peopleServed: Int32,
        notes: String? = nil
    ) async throws -> ImpactMetric {
        isLoading = true
        defer { isLoading = false }
        
        // Validate input
        try validateImpactInput(mealsPrepared: mealsPrepared, peopleServed: peopleServed)
        
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
        
        // Refresh impact data
        loadImpactData()
        
        return impactMetric
    }
    
    func recordVolunteerHours(
        userId: String,
        eventId: String?,
        hours: Double,
        activity: String,
        notes: String? = nil
    ) async throws -> ImpactMetric {
        isLoading = true
        defer { isLoading = false }
        
        // Validate input
        try validateHoursInput(hours: hours, activity: activity)
        
        // Create impact metric
        let impactMetric = coreDataManager.createImpactMetric(
            userId: userId,
            eventId: eventId,
            activityId: nil,
            type: "volunteer_hours",
            value: hours,
            mealsPrepared: 0,
            peopleServed: 0
        )
        
        // Update user stats
        if let user = coreDataManager.fetchUser(by: userId),
           let stats = user.stats {
            stats.hoursVolunteered += Int32(hours)
            coreDataManager.updateUser(user)
        }
        
        // Refresh impact data
        loadImpactData()
        
        return impactMetric
    }
    
    func recordDonation(
        userId: String,
        eventId: String?,
        amount: Double,
        donationType: String,
        notes: String? = nil
    ) async throws -> ImpactMetric {
        isLoading = true
        defer { isLoading = false }
        
        // Validate input
        try validateDonationInput(amount: amount, donationType: donationType)
        
        // Create impact metric
        let impactMetric = coreDataManager.createImpactMetric(
            userId: userId,
            eventId: eventId,
            activityId: nil,
            type: "donation",
            value: amount,
            mealsPrepared: 0,
            peopleServed: 0
        )
        
        // Refresh impact data
        loadImpactData()
        
        return impactMetric
    }
    
    func recordFoodDonation(
        userId: String,
        eventId: String?,
        foodType: String,
        quantity: Double,
        unit: String,
        notes: String? = nil
    ) async throws -> ImpactMetric {
        isLoading = true
        defer { isLoading = false }
        
        // Validate input
        try validateFoodDonationInput(foodType: foodType, quantity: quantity, unit: unit)
        
        // Create impact metric
        let impactMetric = coreDataManager.createImpactMetric(
            userId: userId,
            eventId: eventId,
            activityId: nil,
            type: "food_donation",
            value: quantity,
            mealsPrepared: 0,
            peopleServed: 0
        )
        
        // Refresh impact data
        loadImpactData()
        
        return impactMetric
    }
    
    // MARK: - Impact Retrieval
    
    func getUserImpact(userId: String) -> (meals: Int32, people: Int32, hours: Double) {
        let userStats = coreDataManager.getUserStats(for: userId)
        let userMetrics = coreDataManager.fetchImpactMetrics(for: userId)
        
        let totalMeals = userMetrics.reduce(0) { $0 + $1.mealsPrepared }
        let totalPeople = userMetrics.reduce(0) { $0 + $1.peopleServed }
        let totalHours = userStats.hours
        
        return (meals: totalMeals, people: totalPeople, hours: totalHours)
    }
    
    func getEventImpact(eventId: String) -> (meals: Int32, people: Int32, hours: Double) {
        let eventMetrics = coreDataManager.fetchImpactMetrics(eventId: eventId)
        let eventSessions = coreDataManager.fetchVolunteerSessions(eventId: eventId, status: "completed")
        
        let totalMeals = eventMetrics.reduce(0) { $0 + $1.mealsPrepared }
        let totalPeople = eventMetrics.reduce(0) { $0 + $1.peopleServed }
        let totalHours = eventSessions.reduce(0.0) { $0 + ($1.duration / 3600) }
        
        return (meals: totalMeals, people: totalPeople, hours: totalHours)
    }
    
    func getImpactByDateRange(startDate: Date, endDate: Date) -> [ImpactMetric] {
        let allMetrics = coreDataManager.fetchImpactMetrics()
        
        return allMetrics.filter { metric in
            guard let timestamp = metric.timestamp else { return false }
            return timestamp >= startDate && timestamp <= endDate
        }.sorted { metric1, metric2 in
            guard let timestamp1 = metric1.timestamp, let timestamp2 = metric2.timestamp else { return false }
            return timestamp1 > timestamp2
        }
    }
    
    func getImpactByType(type: String) -> [ImpactMetric] {
        let allMetrics = coreDataManager.fetchImpactMetrics()
        
        return allMetrics.filter { metric in
            metric.type == type
        }.sorted { metric1, metric2 in
            guard let timestamp1 = metric1.timestamp, let timestamp2 = metric2.timestamp else { return false }
            return timestamp1 > timestamp2
        }
    }
    
    func getTopContributors(limit: Int = 10) -> [(userId: String, impact: Double)] {
        let allUsers = coreDataManager.fetchUsers()
        var userImpacts: [(userId: String, impact: Double)] = []
        
        for user in allUsers {
            let userStats = coreDataManager.getUserStats(for: user.id ?? "")
            let impact = Double(userStats.meals) * 2.0 + Double(userStats.hours) * 1.5
            userImpacts.append((userId: user.id ?? "", impact: impact))
        }
        
        return userImpacts.sorted { $0.impact > $1.impact }.prefix(limit).map { $0 }
    }
    
    // MARK: - Impact Analytics
    
    func getImpactTrends(days: Int = 30) -> [ImpactTrend] {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -days, to: endDate) ?? endDate
        
        let metrics = getImpactByDateRange(startDate: startDate, endDate: endDate)
        
        var trends: [ImpactTrend] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            let dayMetrics = metrics.filter { metric in
                guard let timestamp = metric.timestamp else { return false }
                return calendar.isDate(timestamp, inSameDayAs: currentDate)
            }
            
            let totalMeals = dayMetrics.reduce(0) { $0 + $1.mealsPrepared }
            let totalPeople = dayMetrics.reduce(0) { $0 + $1.peopleServed }
            
            trends.append(ImpactTrend(
                date: currentDate,
                meals: totalMeals,
                people: totalPeople
            ))
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return trends
    }
    
    func getImpactBreakdown() -> ImpactBreakdown {
        let allMetrics = coreDataManager.fetchImpactMetrics()
        
        var breakdown = ImpactBreakdown()
        
        for metric in allMetrics {
            switch metric.type {
            case "meal_preparation":
                breakdown.mealPreparation += metric.mealsPrepared
                breakdown.peopleServed += metric.peopleServed
            case "volunteer_hours":
                breakdown.volunteerHours += metric.value
            case "donation":
                breakdown.donations += metric.value
            case "food_donation":
                breakdown.foodDonations += metric.value
            default:
                breakdown.other += metric.value
            }
        }
        
        return breakdown
    }
    
    // MARK: - Impact Goals
    
    func setImpactGoal(goalType: ImpactGoalType, target: Double) {
        UserDefaults.standard.set(target, forKey: "impact_goal_\(goalType.rawValue)")
    }
    
    func getImpactGoal(goalType: ImpactGoalType) -> Double {
        return UserDefaults.standard.double(forKey: "impact_goal_\(goalType.rawValue)")
    }
    
    func getGoalProgress(goalType: ImpactGoalType) -> Double {
        let target = getImpactGoal(goalType: goalType)
        guard target > 0 else { return 0.0 }
        
        let current: Double
        switch goalType {
        case .meals:
            current = Double(totalImpact.meals)
        case .people:
            current = Double(totalImpact.people)
        case .hours:
            current = userImpact.hours
        case .donations:
            let breakdown = getImpactBreakdown()
            current = breakdown.donations
        }
        
        return min(current / target, 1.0)
    }
    
    // MARK: - Helper Methods
    
    private func loadImpactData() {
        totalImpact = coreDataManager.getTotalImpact()
        
        // Load user impact if user is authenticated
        if let currentUser = RealAuthService.shared.currentUser {
            userImpact = getUserImpact(userId: currentUser.id)
        }
        
        // Load recent impact history
        impactHistory = coreDataManager.fetchImpactMetrics().prefix(20).map { $0 }
    }
    
    private func validateImpactInput(mealsPrepared: Int32, peopleServed: Int32) throws {
        guard mealsPrepared > 0 else {
            throw ImpactError.invalidMealsCount
        }
        
        guard peopleServed > 0 else {
            throw ImpactError.invalidPeopleCount
        }
        
        guard mealsPrepared >= peopleServed else {
            throw ImpactError.mealsLessThanPeople
        }
    }
    
    private func validateHoursInput(hours: Double, activity: String) throws {
        guard hours > 0 else {
            throw ImpactError.invalidHours
        }
        
        guard hours <= 24 else {
            throw ImpactError.excessiveHours
        }
        
        guard !activity.isEmpty else {
            throw ImpactError.invalidActivity
        }
    }
    
    private func validateDonationInput(amount: Double, donationType: String) throws {
        guard amount > 0 else {
            throw ImpactError.invalidAmount
        }
        
        guard !donationType.isEmpty else {
            throw ImpactError.invalidDonationType
        }
    }
    
    private func validateFoodDonationInput(foodType: String, quantity: Double, unit: String) throws {
        guard !foodType.isEmpty else {
            throw ImpactError.invalidFoodType
        }
        
        guard quantity > 0 else {
            throw ImpactError.invalidQuantity
        }
        
        guard !unit.isEmpty else {
            throw ImpactError.invalidUnit
        }
    }
}

// MARK: - Impact Models

struct ImpactTrend {
    let date: Date
    let meals: Int32
    let people: Int32
}

struct ImpactBreakdown {
    var mealPreparation: Int32 = 0
    var peopleServed: Int32 = 0
    var volunteerHours: Double = 0.0
    var donations: Double = 0.0
    var foodDonations: Double = 0.0
    var other: Double = 0.0
}

enum ImpactGoalType: String, CaseIterable {
    case meals = "meals"
    case people = "people"
    case hours = "hours"
    case donations = "donations"
}

// MARK: - Impact Errors

enum ImpactError: LocalizedError {
    case invalidMealsCount
    case invalidPeopleCount
    case mealsLessThanPeople
    case invalidHours
    case excessiveHours
    case invalidActivity
    case invalidAmount
    case invalidDonationType
    case invalidFoodType
    case invalidQuantity
    case invalidUnit
    
    var errorDescription: String? {
        switch self {
        case .invalidMealsCount:
            return "Meals prepared must be greater than 0"
        case .invalidPeopleCount:
            return "People served must be greater than 0"
        case .mealsLessThanPeople:
            return "Meals prepared cannot be less than people served"
        case .invalidHours:
            return "Hours must be greater than 0"
        case .excessiveHours:
            return "Hours cannot exceed 24 per day"
        case .invalidActivity:
            return "Activity description is required"
        case .invalidAmount:
            return "Donation amount must be greater than 0"
        case .invalidDonationType:
            return "Donation type is required"
        case .invalidFoodType:
            return "Food type is required"
        case .invalidQuantity:
            return "Quantity must be greater than 0"
        case .invalidUnit:
            return "Unit of measurement is required"
        }
    }
}
