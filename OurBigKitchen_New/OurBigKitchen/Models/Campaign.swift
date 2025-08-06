import Foundation

struct Campaign: Identifiable, Codable, Hashable {
    let id: String
    var title: String
    var description: String
    var goal: Double
    var startDate: Date
    var endDate: Date
    var isActive: Bool
    var imageURL: String?
    
    // Computed properties
    var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }
    
    var formattedDateRange: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        let startString = formatter.string(from: startDate)
        let endString = formatter.string(from: endDate)
        
        return "\(startString) - \(endString)"
    }
    
    var formattedGoal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        
        return formatter.string(from: NSNumber(value: goal)) ?? "$0.00"
    }
    
    var daysRemaining: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let end = calendar.startOfDay(for: endDate)
        
        if today > end {
            return 0
        }
        
        return calendar.dateComponents([.day], from: today, to: end).day ?? 0
    }
    
    var statusText: String {
        if !isActive {
            return "Inactive"
        }
        
        let now = Date()
        if now < startDate {
            return "Upcoming"
        } else if now > endDate {
            return "Completed"
        } else {
            return "Active"
        }
    }
    
    // Initializer
    init(id: String = UUID().uuidString,
         title: String,
         description: String,
         goal: Double,
         startDate: Date,
         endDate: Date,
         isActive: Bool = true,
         imageURL: String? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.goal = goal
        self.startDate = startDate
        self.endDate = endDate
        self.isActive = isActive
        self.imageURL = imageURL
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Campaign, rhs: Campaign) -> Bool {
        lhs.id == rhs.id
    }
} 