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
    
    var totalImpactScore: Int {
        // Calculate impact score based on weighted metrics
        let mealWeight = 1
        let peopleWeight = 2
        let hoursWeight = 3
        let foodWeight = 2
        let carbonWeight = 2
        
        return mealsServed * mealWeight +
               peopleFed * peopleWeight +
               Int(volunteerHours * Double(hoursWeight)) +
               Int(wasteReduced * Double(foodWeight)) +
               Int(carbonFootprintReduced * Double(carbonWeight))
    }
    
    // MARK: - Combining Metrics
    
    static func + (lhs: ImpactMetric, rhs: ImpactMetric) -> ImpactMetric {
        return ImpactMetric(
            mealsServed: lhs.mealsServed + rhs.mealsServed,
            peopleFed: lhs.peopleFed + rhs.peopleFed,
            wasteReduced: lhs.wasteReduced + rhs.wasteReduced,
            carbonFootprintReduced: lhs.carbonFootprintReduced + rhs.carbonFootprintReduced,
            volunteerHours: lhs.volunteerHours + rhs.volunteerHours
        )
    }
    
    // MARK: - Formatting
    
    func formattedMealsServed() -> String {
        return NumberFormatter.localizedString(from: NSNumber(value: mealsServed), number: .decimal)
    }
    
    func formattedPeopleFed() -> String {
        return NumberFormatter.localizedString(from: NSNumber(value: peopleFed), number: .decimal)
    }
    
    func formattedVolunteerHours() -> String {
        return String(format: "%.1f", volunteerHours)
    }
    
    func formattedWasteReduced() -> String {
        return String(format: "%.1f kg", wasteReduced)
    }
    
    func formattedCarbonReduced() -> String {
        return String(format: "%.1f kg CO₂", carbonFootprintReduced)
    }
} 