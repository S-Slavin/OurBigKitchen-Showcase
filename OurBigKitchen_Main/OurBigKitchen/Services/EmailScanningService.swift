import Foundation
import Combine

class EmailScanningService {
    static let shared = EmailScanningService()
    
    private init() {}
    
    // MARK: - Email Connection
    
    func connectEmail(email: String, password: String, provider: EmailProvider) -> AnyPublisher<Bool, Error> {
        // In a real app, this would use OAuth or other secure authentication methods to connect to email
        // For demo purposes, we'll simulate success
        return Future<Bool, Error> { promise in
            // Simulate network delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                // Simulate success
                promise(.success(true))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func disconnectEmail(email: String) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { promise in
            // Simulate network delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Simulate success
                promise(.success(true))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Email Scanning
    
    func scanEmails(connectedAccount: FinePrintModels.ConnectedAccount) -> AnyPublisher<[FinePrintModels.DigitalService], Error> {
        return Future<[FinePrintModels.DigitalService], Error> { promise in
            // Simulate network delay and processing time
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                // For demo purposes, return sample discovered services
                let discoveredServices = self.generateSampleDiscoveredServices()
                promise(.success(discoveredServices))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Helper Methods
    
    private func generateSampleDiscoveredServices() -> [FinePrintModels.DigitalService] {
        let services: [FinePrintModels.DigitalService] = [
            FinePrintModels.DigitalService(
                name: "Twitter",
                domain: "twitter.com",
                category: .social,
                riskLevel: .medium,
                discoverySource: .email,
                discoveryDate: Date().addingTimeInterval(-86400 * 45), // 45 days ago
                lastActivityDate: Date().addingTimeInterval(-86400 * 3), // 3 days ago
                logoURL: "https://example.com/twitter.png",
                privacyPolicyURL: "https://twitter.com/privacy",
                termsURL: "https://twitter.com/terms",
                dataSharing: [
                    FinePrintModels.DataSharingPartner(
                        companyName: "Advertising Partners",
                        domain: "various",
                        purpose: "Targeted advertising"
                    )
                ],
                breachStatus: .noBreachDetected,
                deletionStatus: .notRequested
            ),
            FinePrintModels.DigitalService(
                name: "Spotify",
                domain: "spotify.com",
                category: .entertainment,
                riskLevel: .low,
                discoverySource: .email,
                discoveryDate: Date().addingTimeInterval(-86400 * 120), // 120 days ago
                lastActivityDate: Date().addingTimeInterval(-86400 * 7), // 7 days ago
                logoURL: "https://example.com/spotify.png",
                privacyPolicyURL: "https://spotify.com/privacy",
                termsURL: "https://spotify.com/terms",
                dataSharing: [],
                breachStatus: .noBreachDetected,
                deletionStatus: .notRequested
            ),
            FinePrintModels.DigitalService(
                name: "Dropbox",
                domain: "dropbox.com",
                category: .productivity,
                riskLevel: .medium,
                discoverySource: .email,
                discoveryDate: Date().addingTimeInterval(-86400 * 180), // 180 days ago
                lastActivityDate: Date().addingTimeInterval(-86400 * 14), // 14 days ago
                logoURL: "https://example.com/dropbox.png",
                privacyPolicyURL: "https://dropbox.com/privacy",
                termsURL: "https://dropbox.com/terms",
                dataSharing: [
                    FinePrintModels.DataSharingPartner(
                        companyName: "Third-party Analytics",
                        domain: "analytics.company",
                        purpose: "Usage analytics"
                    )
                ],
                breachStatus: .potentialBreach,
                deletionStatus: .notRequested
            )
        ]
        
        return services
    }
}

// Email providers supported by the app
enum EmailProvider: String, CaseIterable {
    case gmail = "Gmail"
    case outlook = "Outlook"
    case yahoo = "Yahoo"
    case icloud = "iCloud"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .gmail: return "envelope.circle.fill"
        case .outlook: return "envelope.badge.fill"
        case .yahoo: return "envelope.fill"
        case .icloud: return "cloud.fill"
        case .other: return "envelope"
        }
    }
}

// Email scan result
struct EmailScanResult {
    let newServices: [FinePrintModels.DigitalService]
    let updatedServices: [FinePrintModels.DigitalService]
    let scannedEmails: Int
    let dateScanned: Date
    
    init(newServices: [FinePrintModels.DigitalService] = [],
         updatedServices: [FinePrintModels.DigitalService] = [],
         scannedEmails: Int = 0,
         dateScanned: Date = Date()) {
        self.newServices = newServices
        self.updatedServices = updatedServices
        self.scannedEmails = scannedEmails
        self.dateScanned = dateScanned
    }
} 