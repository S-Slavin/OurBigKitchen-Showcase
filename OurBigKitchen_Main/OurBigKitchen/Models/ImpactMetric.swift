import Foundation

// MARK: - Impact Metric Types
enum ImpactMetricType: String, Codable, CaseIterable {
    case mealsServed
    case peopleFed
    case wasteReduced
    case carbonFootprintReduced
    case volunteerHours
    case donations
    case corporateParticipation
}

// MARK: - Total Impact Model
struct TotalImpact: Codable {
    let totalMealsServed: Int
    let totalPeopleFed: Int
    let totalWasteReduced: Double
    let totalCarbonFootprintReduced: Double
    let totalVolunteerHours: Double
    let totalDonations: Double
    let totalCorporateParticipation: Int
    
    init(totalMealsServed: Int = 0,
         totalPeopleFed: Int = 0,
         totalWasteReduced: Double = 0.0,
         totalCarbonFootprintReduced: Double = 0.0,
         totalVolunteerHours: Double = 0.0,
         totalDonations: Double = 0.0,
         totalCorporateParticipation: Int = 0) {
        self.totalMealsServed = totalMealsServed
        self.totalPeopleFed = totalPeopleFed
        self.totalWasteReduced = totalWasteReduced
        self.totalCarbonFootprintReduced = totalCarbonFootprintReduced
        self.totalVolunteerHours = totalVolunteerHours
        self.totalDonations = totalDonations
        self.totalCorporateParticipation = totalCorporateParticipation
    }
}

// Use the ImpactMetric defined in AppModels.swift
typealias ImpactMetric = AppModels.ImpactMetric

// Extension to provide additional functionality for ImpactMetric
extension ImpactMetric {
    // MARK: - Computed Properties
    
    var impactScore: Int {
        // Calculate impact score based on type and value
        switch type {
        case .mealsServed:
            return Int(value * 10) // 10 points per meal
        case .peopleFed:
            return Int(value * 8)  // 8 points per person
        case .volunteerHours:
            return Int(value * 15) // 15 points per hour
        case .volunteer:
            return Int(value * 15) // 15 points per hour
        case .foodWasteReduced:
            return Int(value * 5)  // 5 points per kg
        case .carbonFootprintReduced:
            return Int(value * 12) // 12 points per kg CO2
        case .donationsCollected:
            return Int(value * 20) // 20 points per dollar
        case .eventsOrganized:
            return Int(value * 25) // 25 points per event
        }
    }
    
    // MARK: - Arithmetic Operations
    
    static func + (lhs: ImpactMetric, rhs: ImpactMetric) -> ImpactMetric {
        // Only combine metrics of the same type
        guard lhs.type == rhs.type else {
            return lhs // Return the left operand if types don't match
        }
        
        return ImpactMetric(
            type: lhs.type,
            value: lhs.value + rhs.value,
            unit: lhs.unit,
            date: max(lhs.date, rhs.date)
        )
    }
    
    // MARK: - Formatted Values
    
    var formattedValue: String {
        switch type {
        case .mealsServed, .peopleFed, .donationsCollected, .eventsOrganized:
            return NumberFormatter.localizedString(from: NSNumber(value: Int(value)), number: .decimal)
        case .volunteerHours, .volunteer:
            return String(format: "%.1f", value)
        case .foodWasteReduced:
            return String(format: "%.1f kg", value)
        case .carbonFootprintReduced:
            return String(format: "%.1f kg CO₂", value)
        }
    }
} 