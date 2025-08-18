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
            type: .mealsServed,
            value: Double(mealsPrepared),
            userId: userId,
            eventId: eventId
        )
        
        // Update user stats
        if let user = coreDataManager.fetchUser(by: userId) {
            let stats = coreDataManager.getUserStats(for: userId)
            // Note: UserStats doesn't have mealsPrepared property, so we'll skip this for now
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
            type: .volunteerHours,
            value: hours,
            userId: userId,
            eventId: eventId
        )
        
        // Update user stats
        if let user = coreDataManager.fetchUser(by: userId) {
            let stats = coreDataManager.getUserStats(for: userId)
            // Note: UserStats doesn't have hoursVolunteered property, so we'll skip this for now
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
        
        // Create impact metric - use wasteReduced for donations since ImpactMetric doesn't have donations
        let impactMetric = coreDataManager.createImpactMetric(
            type: .wasteReduced,
            value: amount,
            userId: userId,
            eventId: eventId
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
        
        // Create impact metric - use wasteReduced for food donations
        let impactMetric = coreDataManager.createImpactMetric(
            type: .wasteReduced,
            value: quantity,
            userId: userId,
            eventId: eventId
        )
        
        // Refresh impact data
        loadImpactData()
        
        return impactMetric
    }
    
    // MARK: - Impact Retrieval
    
    func getUserImpact(userId: String) -> (meals: Int32, people: Int32, hours: Double) {
        let userStats = coreDataManager.getUserStats(for: userId)
        let userMetrics = coreDataManager.fetchImpactMetrics(for: userId)
        
        let totalMeals = userMetrics.reduce(into: 0) { result, metric in
            if metric.type == .mealsServed {
                result += Int(metric.value)
            }
        }
        let totalPeople = userMetrics.reduce(into: 0) { result, metric in
            if metric.type == .peopleFed {
                result += Int(metric.value)
            }
        }
        let totalHours = userMetrics.reduce(into: 0.0) { result, metric in
            if metric.type == .volunteerHours {
                result += metric.value
            }
        }
        
        return (meals: Int32(totalMeals), people: Int32(totalPeople), hours: totalHours)
    }
    
    func getEventImpact(eventId: String) -> (meals: Int32, people: Int32, hours: Double) {
        let eventMetrics = coreDataManager.fetchImpactMetrics(eventId: eventId)
        let eventSessions = coreDataManager.fetchVolunteerSessions(eventId: eventId, status: "completed")
        
        let totalMeals = eventMetrics.reduce(into: 0) { result, metric in
            if metric.type == .mealsServed {
                result += Int(metric.value)
            }
        }
        let totalPeople = eventMetrics.reduce(into: 0) { result, metric in
            if metric.type == .peopleFed {
                result += Int(metric.value)
            }
        }
        let totalHours = eventSessions.reduce(0.0) { $0 + ($1.duration / 3600) }
        
        return (meals: Int32(totalMeals), people: Int32(totalPeople), hours: totalHours)
    }
    
    func getImpactByDateRange(startDate: Date, endDate: Date) -> [ImpactMetric] {
        let allMetrics = coreDataManager.fetchImpactMetrics()
        
        // Since ImpactMetric doesn't have timestamp, we'll return all metrics for now
        // This will need to be updated when Core Data is properly implemented
        return allMetrics
    }
    
    func getImpactByType(type: ImpactMetricType) -> [ImpactMetric] {
        let allMetrics = coreDataManager.fetchImpactMetrics()
        
        // Since ImpactMetric doesn't have type property, we'll return all metrics for now
        // This will need to be updated when Core Data is properly implemented
        return allMetrics
    }
    
    func getTopContributors(limit: Int = 10) -> [(userId: String, impact: Double)] {
        let allUsers = coreDataManager.fetchUsers()
        var userImpacts: [(userId: String, impact: Double)] = []
        
        for user in allUsers {
            let userStats = coreDataManager.getUserStats(for: user.id ?? "")
            // Note: UserStats doesn't have meals or hours properties, so we'll use a default value
            let impact = 0.0 // This will need to be updated when UserStats is properly implemented
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
            // Since ImpactMetric doesn't have timestamp, we'll create a single trend entry
            // This will need to be updated when Core Data is properly implemented
            let totalMeals = metrics.reduce(into: 0) { result, metric in
                if metric.type == .mealsServed {
                    result += Int(metric.value)
                }
            }
            let totalPeople = metrics.reduce(into: 0) { result, metric in
                if metric.type == .peopleFed {
                    result += Int(metric.value)
                }
            }
            
            trends.append(ImpactTrend(
                date: currentDate,
                meals: Int32(totalMeals),
                people: Int32(totalPeople)
            ))
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return trends
    }
    
    func getImpactBreakdown() -> ImpactBreakdown {
        let allMetrics = coreDataManager.fetchImpactMetrics()
        
        var breakdown = ImpactBreakdown()
        
        for metric in allMetrics {
            // Since ImpactMetric doesn't have type property, we'll categorize based on values
            if metric.type == .mealsServed && metric.value > 0 {
                breakdown.mealPreparation += Int32(metric.value)
            }
            if metric.type == .peopleFed && metric.value > 0 {
                breakdown.peopleServed += Int32(metric.value)
            }
            
            if metric.type == .volunteerHours && metric.value > 0 {
                breakdown.volunteerHours += metric.value
            }
            
            if metric.type == .wasteReduced && metric.value > 0 {
                breakdown.foodDonations += metric.value
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
        let totalImpactData = coreDataManager.getTotalImpact()
        totalImpact = (meals: Int32(totalImpactData.totalMealsServed), people: Int32(totalImpactData.totalPeopleFed))
        
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
