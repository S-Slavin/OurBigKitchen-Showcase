import Foundation

// MARK: - Volunteer Session Models
struct VolunteerSession: Identifiable, Codable {
    let id: String
    let userId: String
    let eventId: String
    let checkInTime: Date
    var checkOutTime: Date?
    let notes: String?
    let status: VolunteerSessionStatus
    let impact: ImpactMetric
    
    init(id: String = UUID().uuidString,
         userId: String,
         eventId: String,
         checkInTime: Date = Date(),
         checkOutTime: Date? = nil,
         notes: String? = nil,
         status: VolunteerSessionStatus = .active,
         impact: ImpactMetric = ImpactMetric()) {
        self.id = id
        self.userId = userId
        self.eventId = eventId
        self.checkInTime = checkInTime
        self.checkOutTime = checkOutTime
        self.notes = notes
        self.status = status
        self.impact = impact
    }
    
    var duration: TimeInterval {
        let endTime = checkOutTime ?? Date()
        return endTime.timeIntervalSince(checkInTime)
    }
    
    var isActive: Bool {
        status == .active
    }
}

enum VolunteerSessionStatus: String, Codable, CaseIterable {
    case active
    case completed
    case cancelled
    case noShow
}
