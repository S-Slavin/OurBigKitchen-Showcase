import Foundation

struct Session: Identifiable, Codable {
    let id: String
    let startTime: Date
    let endTime: Date
    let duration: TimeInterval
    
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
} 