import Foundation

// This file provides extensions for the ImpactMetric defined in AppModels.swift
// The actual ImpactMetric struct is defined in AppModels.swift

// Extension to provide additional functionality for ImpactMetric
extension AppModels.ImpactMetric {
    // MARK: - Computed Properties
    
    var totalImpactScore: Int {
        // Calculate impact score based on weighted metrics
        let mealWeight = 1
        let peopleWeight = 2
        let foodWeight = 2
        
        return mealsServed * mealWeight +
               familiesHelped * peopleWeight +
               livesTouched * peopleWeight +
               Int(foodSavedKg * Double(foodWeight))
    }
    
    // MARK: - Formatting
    
    func formattedMealsServed() -> String {
        return NumberFormatter.localizedString(from: NSNumber(value: mealsServed), number: .decimal)
    }
    
    func formattedFamiliesHelped() -> String {
        return NumberFormatter.localizedString(from: NSNumber(value: familiesHelped), number: .decimal)
    }
    
    func formattedLivesTouched() -> String {
        return NumberFormatter.localizedString(from: NSNumber(value: livesTouched), number: .decimal)
    }
    
    func formattedFoodSaved() -> String {
        return String(format: "%.1f kg", foodSavedKg)
    }
} 