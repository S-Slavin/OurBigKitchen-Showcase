import Foundation

struct Donation: Identifiable, Codable, Hashable {
    let id: String
    let donorId: String?
    let donorName: String
    let donorEmail: String?
    let amount: Double
    let type: DonationType
    let date: Date
    let isAnonymous: Bool
    let campaignId: String?
    let notes: String?
    let taxReceiptIssued: Bool
    let inKindDetails: InKindDetails?
    
    enum DonationType: String, Codable, CaseIterable, Hashable {
        case monetary
        case food
        case equipment
        case volunteering
        case other
    }
    
    struct InKindDetails: Codable, Hashable {
        let itemName: String
        let quantity: Int
        let estimatedValue: Double
        let condition: String?
        let expiryDate: Date?
        
        init(itemName: String, 
             quantity: Int, 
             estimatedValue: Double, 
             condition: String? = nil, 
             expiryDate: Date? = nil) {
            self.itemName = itemName
            self.quantity = quantity
            self.estimatedValue = estimatedValue
            self.condition = condition
            self.expiryDate = expiryDate
        }
    }
    
    // Computed property to determine the actual value of the donation
    var value: Double {
        switch type {
        case .monetary:
            return amount
        case .food, .equipment, .other:
            return inKindDetails?.estimatedValue ?? 0
        case .volunteering:
            // Volunteer time is valued at a standard rate
            return amount * 25.0 // $25 per hour as default value
        }
    }
    
    var formattedValue: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        return formatter.string(from: date)
    }
    
    init(id: String = UUID().uuidString,
         donorId: String? = nil,
         donorName: String,
         donorEmail: String? = nil,
         amount: Double,
         type: DonationType,
         date: Date = Date(),
         isAnonymous: Bool = false,
         campaignId: String? = nil,
         notes: String? = nil,
         taxReceiptIssued: Bool = false,
         inKindDetails: InKindDetails? = nil) {
        self.id = id
        self.donorId = donorId
        self.donorName = donorName
        self.donorEmail = donorEmail
        self.amount = amount
        self.type = type
        self.date = date
        self.isAnonymous = isAnonymous
        self.campaignId = campaignId
        self.notes = notes
        self.taxReceiptIssued = taxReceiptIssued
        self.inKindDetails = inKindDetails
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Donation, rhs: Donation) -> Bool {
        lhs.id == rhs.id
    }
} 