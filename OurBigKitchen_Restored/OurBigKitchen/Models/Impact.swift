//
//  Impact.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//

import Foundation

// Make sure Impact is only declared once in the codebase
struct Impact: Codable, Equatable, Hashable {
    let id: String
    let userId: String
    var mealsProvided: Int
    var hoursContributed: Int
    var peopleHelped: Int
    var eventsAttended: Int
    var mealsMade: Int? // User input for meals made
    var timeSpent: Int? // User input for time spent (hours)
    var imageData: Data? // For storing captured impact photos
    
    // Computed properties
    var totalImpact: Int {
        // Simple weighting for impact score
        let mealWeight = 1
        let hoursWeight = 3
        let peopleWeight = 2
        
        return mealsProvided * mealWeight + 
               hoursContributed * hoursWeight + 
               peopleHelped * peopleWeight
    }
    
    var carbonSaved: Double {
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
    
    var foodWasteSaved: Double {
        if let _ = timeSpent {
            let participants = Double(timeSpent ?? 0) / 3.0
            return participants * 3.3
        }
        return 0.0
    }
    
    var formattedImpactSummary: String {
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
    init(id: String, userId: String, timeSpent: Int, mealsMade: Int) {
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
    init(mealsProvided: Int, hoursContributed: Int, peopleHelped: Int, eventsAttended: Int, mealsMade: Int?, timeSpent: Int?) {
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
    static var empty: Impact {
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
    static func fromImpactMetric(_ metric: AppModels.ImpactMetric) -> Impact {
        Impact(
            mealsProvided: metric.mealsServed,
            hoursContributed: Int(metric.volunteerHours),
            peopleHelped: metric.peopleFed,
            eventsAttended: 1, // Default to 1 event, would be updated in real app
            mealsMade: nil,
            timeSpent: nil
        )
    }
}

struct ImpactPost: Identifiable, Codable {
    let id: String
    let userId: String
    let message: String
    let date: Date
    let tags: [String]
    var views: Int
    var shares: Int
    let imageData: Data?
    
    init(id: String = UUID().uuidString,
         userId: String,
         message: String,
         date: Date = Date(),
         tags: [String] = [],
         views: Int = 0,
         shares: Int = 0,
         imageData: Data? = nil) {
        self.id = id
        self.userId = userId
        self.message = message
        self.date = date
        self.tags = tags
        self.views = views
        self.shares = shares
        self.imageData = imageData
    }
}

struct UserImpactStats: Codable {
    let totalImpacts: Int
    let totalShares: Int
    let totalViews: Int
    
    init(totalImpacts: Int = 0,
         totalShares: Int = 0,
         totalViews: Int = 0) {
        self.totalImpacts = totalImpacts
        self.totalShares = totalShares
        self.totalViews = totalViews
    }
} 