//
//  Impact.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//

import Foundation

// Make sure Impact is only declared once in the codebase
public struct Impact: Codable, Equatable, Hashable, Sendable {
    public let id: String
    public let userId: String
    public var mealsProvided: Int
    public var hoursContributed: Int
    public var peopleHelped: Int
    public var eventsAttended: Int
    public var mealsMade: Int? // User input for meals made
    public var timeSpent: Int? // User input for time spent (hours)
    public var imageData: Data? // For storing captured impact photos
    
    // Computed properties
    public var totalImpact: Int {
        // Simple weighting for impact score
        let mealWeight = 1
        let hoursWeight = 3
        let peopleWeight = 2
        
        return mealsProvided * mealWeight + 
               hoursContributed * hoursWeight + 
               peopleHelped * peopleWeight
    }
    
    public var carbonSaved: Double {
        if let _ = mealsMade, let _ = timeSpent {
            // New formula: 
            // 3 volunteer hours per participant
            // 3.3kg food waste saved per participant
            // 2.5kg CO2 saved per kg food waste
            let participants = Double(timeSpent ?? 0) / 3.0
            let foodWasteSaved = participants * 3.3
            return foodWasteSaved * 2.5
        } else {
            // Fallback to original calculation if no user inputs
            return Double(mealsProvided) * 2.5
        }
    }
    
    public var foodWasteSaved: Double {
        if let _ = timeSpent {
            let participants = Double(timeSpent ?? 0) / 3.0
            return participants * 3.3
        }
        return 0.0
    }
    
    public var formattedImpactSummary: String {
        var result = """
        My Impact at Our Big Kitchen:
        ✅ \(mealsProvided) meals provided
        ✅ \(hoursContributed) hours contributed
        ✅ \(peopleHelped) people helped
        ✅ \(eventsAttended) events attended
        """
        
        if let mealsMade = mealsMade, let _ = timeSpent {
            result += "\n✅ \(mealsMade) meals made"
            result += "\n✅ \(String(format: "%.1f", foodWasteSaved)) kg of food waste saved"
        }
        
        result += "\n✅ Approx. \(String(format: "%.1f", carbonSaved)) kg of CO2 saved"
        
        result += """
        
        Join me in making a difference! #OurBigKitchen
        """
        
        return result
    }
    
    // New constructor that takes id, userId, timeSpent, and mealsMade
    public init(id: String, userId: String, timeSpent: Int, mealsMade: Int) {
        self.id = id
        self.userId = userId
        self.mealsProvided = mealsMade * 2 // Simple calculation
        self.hoursContributed = timeSpent
        self.peopleHelped = mealsMade * 3 // Simple calculation
        self.eventsAttended = 1
        self.mealsMade = mealsMade
        self.timeSpent = timeSpent
    }
    
    // Legacy constructor for compatibility
    public init(mealsProvided: Int, hoursContributed: Int, peopleHelped: Int, eventsAttended: Int, mealsMade: Int?, timeSpent: Int?) {
        self.id = UUID().uuidString
        self.userId = UUID().uuidString
        self.mealsProvided = mealsProvided
        self.hoursContributed = hoursContributed
        self.peopleHelped = peopleHelped
        self.eventsAttended = eventsAttended
        self.mealsMade = mealsMade
        self.timeSpent = timeSpent
    }
    
    // Static empty value
    public static var empty: Impact {
        Impact(
            mealsProvided: 0,
            hoursContributed: 0,
            peopleHelped: 0,
            eventsAttended: 0,
            mealsMade: nil,
            timeSpent: nil
        )
    }
    
    // Factory method to create Impact from ImpactMetric
    public static func fromImpactMetric(_ metric: AppModels.ImpactMetric) -> Impact {
        Impact(
            mealsProvided: metric.mealsServed,
            hoursContributed: 0, // Default to 0 since volunteerHours doesn't exist in AppModels.ImpactMetric
            peopleHelped: metric.familiesHelped + metric.livesTouched, // Combine families and lives touched
            eventsAttended: 1, // Default to 1 event, would be updated in real app
            mealsMade: nil,
            timeSpent: nil
        )
    }
} 