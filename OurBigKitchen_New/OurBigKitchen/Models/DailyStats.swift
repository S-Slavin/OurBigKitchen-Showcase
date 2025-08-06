//
//  DailyStats.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//


import Foundation

struct DailyStats: Codable, Identifiable {
    let id: String
    let date: Date
    let mealsServed: Int
    let volunteersPresent: Int
    let hoursContributed: Double
    let peopleServed: Int
    let foodWasteSaved: Double
    let donationsReceived: Double
    
    enum CodingKeys: String, CodingKey {
        case id
        case date
        case mealsServed = "meals_served"
        case volunteersPresent = "volunteers_present"
        case hoursContributed = "hours_contributed"
        case peopleServed = "people_served"
        case foodWasteSaved = "food_waste_saved"
        case donationsReceived = "donations_received"
    }
    
    // Computed properties
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    // UI convenience properties for HomeView
    var meals: Int { mealsServed }
    var volunteers: Int { volunteersPresent }
    var hours: Int { Int(hoursContributed) }
    
    var totalImpact: Double {
        // Calculate total impact score based on various metrics
        let mealsImpact = Double(mealsServed) * 0.3
        let volunteerImpact = Double(volunteersPresent) * 0.2
        let donationImpact = donationsReceived * 0.2
        let wasteImpact = foodWasteSaved * 0.3
        
        return mealsImpact + volunteerImpact + donationImpact + wasteImpact
    }
    
    // Initializer
    init(id: String = UUID().uuidString,
         date: Date = Date(),
         mealsServed: Int = 0,
         volunteersPresent: Int = 0,
         hoursContributed: Double = 0.0,
         peopleServed: Int = 0,
         foodWasteSaved: Double = 0.0,
         donationsReceived: Double = 0.0) {
        self.id = id
        self.date = date
        self.mealsServed = mealsServed
        self.volunteersPresent = volunteersPresent
        self.hoursContributed = hoursContributed
        self.peopleServed = peopleServed
        self.foodWasteSaved = foodWasteSaved
        self.donationsReceived = donationsReceived
    }
}