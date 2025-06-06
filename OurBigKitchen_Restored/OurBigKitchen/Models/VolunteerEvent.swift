import Foundation

struct VolunteerEvent: Identifiable {
    let id: String
    let title: String
    let description: String
    let category: String
    let date: Date
    let duration: Double
    let location: String
    let spotsAvailable: Int
    var isRegistered: Bool
    
    init(id: String = UUID().uuidString,
         title: String,
         description: String,
         category: String,
         date: Date,
         duration: Double,
         location: String,
         spotsAvailable: Int,
         isRegistered: Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.date = date
        self.duration = duration
        self.location = location
        self.spotsAvailable = spotsAvailable
        self.isRegistered = isRegistered
    }
}

// MARK: - Preview Helper
extension VolunteerEvent {
    static let preview = VolunteerEvent(
        title: "Community Kitchen Volunteer Day",
        description: "Join us for a day of cooking and serving meals to those in need. We'll be preparing nutritious meals and distributing them to local shelters.",
        category: "Cooking",
        date: Date().addingTimeInterval(86400), // Tomorrow
        duration: 4.0,
        location: "123 Community Center, Sydney",
        spotsAvailable: 15
    )
} 