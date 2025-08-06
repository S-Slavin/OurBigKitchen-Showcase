import Foundation

struct AnalyticsReport: Codable {
    // User Summary
    struct UserSummary: Codable {
        let id: String
        let name: String
        let profileImageURL: String?
        let totalHours: Double
        let totalImpact: Int
        let totalUsers: Int
        let activeUsers: Int
        let newUsers: Int
        let volunteerHours: Double
        
        enum CodingKeys: String, CodingKey {
            case id, name
            case profileImageURL = "profile_image_url"
            case totalHours = "total_hours"
            case totalImpact = "total_impact"
            case totalUsers = "total_users"
            case activeUsers = "active_users"
            case newUsers = "new_users"
            case volunteerHours = "volunteer_hours"
        }
    }
    
    // Corporate Partner
    struct CorporatePartner: Codable {
        let id: String
        let name: String
        let logoURL: String?
        let totalContribution: Double
        let employeeParticipation: Int
        let totalDonations: Double
        let volunteerHours: Double
        let impactScore: Double
        
        enum CodingKeys: String, CodingKey {
            case id, name
            case logoURL = "logo_url"
            case totalContribution = "total_contribution"
            case employeeParticipation = "employee_participation"
            case totalDonations = "total_donations"
            case volunteerHours = "volunteer_hours"
            case impactScore = "impact_score"
        }
    }
    
    // Main properties
    let startDate: Date
    let endDate: Date
    let userSummary: UserSummary
    let topPartners: [CorporatePartner]
    let totalMealsServed: Int
    let totalPeopleServed: Int
    let totalFoodWasteSaved: Double
    let totalDonationsReceived: Double
    let totalVolunteers: Int
    let totalHoursVolunteered: Double
    let foodWasteReduced: Double
    let dailyBreakdown: [DailyStats]
    let impactMetrics: [AppModels.ImpactMetric]
    let topVolunteers: [UserSummary]
    let topCorporatePartners: [CorporatePartner]
    
    enum CodingKeys: String, CodingKey {
        case startDate = "start_date"
        case endDate = "end_date"
        case userSummary = "user_summary"
        case topPartners = "top_partners"
        case totalMealsServed = "total_meals_served"
        case totalPeopleServed = "total_people_served"
        case totalFoodWasteSaved = "total_food_waste_saved"
        case totalDonationsReceived = "total_donations_received"
        case totalVolunteers = "total_volunteers"
        case totalHoursVolunteered = "total_hours_volunteered"
        case foodWasteReduced = "food_waste_reduced"
        case dailyBreakdown = "daily_breakdown"
        case impactMetrics = "impact_metrics"
        case topVolunteers = "top_volunteers"
        case topCorporatePartners = "top_corporate_partners"
    }
} 