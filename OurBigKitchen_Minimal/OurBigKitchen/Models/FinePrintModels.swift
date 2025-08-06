import Foundation
import SwiftUI
import Combine

// Models for FinePrint - no longer need to be public
struct FinePrintModels {
    // MARK: - User Models
    struct User: Identifiable, Codable {
        var id: String
        var name: String
        var email: String
        var profileImageURL: String?
        var isParent: Bool
        var linkedChildAccounts: [String]
        var twoFactorEnabled: Bool
        var connectedAccounts: [ConnectedAccount]
        var privacyScore: Int
        
        init(id: String, name: String, email: String, profileImageURL: String? = nil, isParent: Bool = false, linkedChildAccounts: [String] = [], twoFactorEnabled: Bool = false, connectedAccounts: [ConnectedAccount] = [], privacyScore: Int = 50) {
            self.id = id
            self.name = name
            self.email = email
            self.profileImageURL = profileImageURL
            self.isParent = isParent
            self.linkedChildAccounts = linkedChildAccounts
            self.twoFactorEnabled = twoFactorEnabled
            self.connectedAccounts = connectedAccounts
            self.privacyScore = privacyScore
        }
        
        func isValid() -> Bool {
            return !id.isEmpty && !name.isEmpty && !email.isEmpty
        }
    }
    
    // MARK: - Connected Account Models
    struct ConnectedAccount: Identifiable, Codable {
        let id: String
        let type: AccountType
        let name: String
        let email: String
        let lastScanned: Date?
        let status: ConnectionStatus
        
        enum AccountType: String, Codable, CaseIterable {
            case email
            case browser
            case social
        }
        
        enum ConnectionStatus: String, Codable, CaseIterable {
            case active
            case pending
            case failed
            case disconnected
        }
        
        init(id: String = UUID().uuidString,
             type: AccountType,
             name: String,
             email: String,
             lastScanned: Date? = nil,
             status: ConnectionStatus = .active) {
            self.id = id
            self.type = type
            self.name = name
            self.email = email
            self.lastScanned = lastScanned
            self.status = status
        }
    }
    
    // MARK: - Digital Footprint Models
    struct DigitalService: Identifiable, Codable {
        let id: String
        let name: String
        let domain: String
        let category: ServiceCategory
        let riskLevel: RiskLevel
        let discoverySource: DiscoverySource
        let discoveryDate: Date
        let lastActivityDate: Date?
        let logoURL: String?
        let privacyPolicyURL: String?
        let termsURL: String?
        let dataSharing: [DataSharingPartner]
        let breachStatus: BreachStatus
        let deletionStatus: DeletionStatus
        
        enum ServiceCategory: String, Codable, CaseIterable {
            case social
            case shopping
            case finance
            case health
            case education
            case entertainment
            case productivity
            case travel
            case food
            case other
        }
        
        enum RiskLevel: String, Codable, CaseIterable {
            case low
            case medium
            case high
            
            var color: Color {
                switch self {
                case .low: return Color.green
                case .medium: return Color.yellow
                case .high: return Color.red
                }
            }
        }
        
        enum DiscoverySource: String, Codable, CaseIterable {
            case email
            case browser
            case manual
            case breachDatabase
        }
        
        enum BreachStatus: String, Codable, CaseIterable {
            case noBreachDetected
            case breachDetected
            case potentialBreach
            
            var color: Color {
                switch self {
                case .noBreachDetected: return Color.green
                case .breachDetected: return Color.red
                case .potentialBreach: return Color.yellow
                }
            }
        }
        
        enum DeletionStatus: String, Codable, CaseIterable {
            case notRequested
            case pending
            case completed
            case failed
            
            var color: Color {
                switch self {
                case .notRequested: return Color.gray
                case .pending: return Color.yellow
                case .completed: return Color.green
                case .failed: return Color.red
                }
            }
        }
        
        init(id: String = UUID().uuidString,
             name: String,
             domain: String,
             category: ServiceCategory,
             riskLevel: RiskLevel,
             discoverySource: DiscoverySource,
             discoveryDate: Date = Date(),
             lastActivityDate: Date? = nil,
             logoURL: String? = nil,
             privacyPolicyURL: String? = nil,
             termsURL: String? = nil,
             dataSharing: [DataSharingPartner] = [],
             breachStatus: BreachStatus = .noBreachDetected,
             deletionStatus: DeletionStatus = .notRequested) {
            self.id = id
            self.name = name
            self.domain = domain
            self.category = category
            self.riskLevel = riskLevel
            self.discoverySource = discoverySource
            self.discoveryDate = discoveryDate
            self.lastActivityDate = lastActivityDate
            self.logoURL = logoURL
            self.privacyPolicyURL = privacyPolicyURL
            self.termsURL = termsURL
            self.dataSharing = dataSharing
            self.breachStatus = breachStatus
            self.deletionStatus = deletionStatus
        }
    }
    
    struct DataSharingPartner: Identifiable, Codable {
        let id: String
        let companyName: String
        let domain: String
        let purpose: String
        
        init(id: String = UUID().uuidString,
             companyName: String,
             domain: String,
             purpose: String) {
            self.id = id
            self.companyName = companyName
            self.domain = domain
            self.purpose = purpose
        }
    }
    
    // MARK: - Privacy Policy Analysis
    struct PolicyAnalysis: Identifiable, Codable {
        let id: String
        let serviceId: String
        let policyURL: String
        let lastUpdated: Date
        let policyText: String
        let summary: String
        let keyPoints: [KeyPoint]
        let dataCollectionPractices: [DataPractice]
        let dataSharingPractices: [DataPractice]
        let concernAreas: [ConcernArea]
        
        struct KeyPoint: Identifiable, Codable {
            let id: String
            let title: String
            let description: String
            let severity: ConcernSeverity
            
            init(id: String = UUID().uuidString,
                 title: String,
                 description: String,
                 severity: ConcernSeverity = .info) {
                self.id = id
                self.title = title
                self.description = description
                self.severity = severity
            }
        }
        
        struct DataPractice: Identifiable, Codable {
            let id: String
            let type: String
            let description: String
            let purpose: String
            
            init(id: String = UUID().uuidString,
                 type: String,
                 description: String,
                 purpose: String) {
                self.id = id
                self.type = type
                self.description = description
                self.purpose = purpose
            }
        }
        
        struct ConcernArea: Identifiable, Codable {
            let id: String
            let title: String
            let description: String
            let severity: ConcernSeverity
            let recommendation: String
            
            init(id: String = UUID().uuidString,
                 title: String,
                 description: String,
                 severity: ConcernSeverity,
                 recommendation: String) {
                self.id = id
                self.title = title
                self.description = description
                self.severity = severity
                self.recommendation = recommendation
            }
        }
        
        enum ConcernSeverity: String, Codable, CaseIterable {
            case info
            case low
            case medium
            case high
            
            var color: Color {
                switch self {
                case .info: return Color.blue
                case .low: return Color.green
                case .medium: return Color.yellow
                case .high: return Color.red
                }
            }
        }
        
        init(id: String = UUID().uuidString,
             serviceId: String,
             policyURL: String,
             lastUpdated: Date = Date(),
             policyText: String,
             summary: String,
             keyPoints: [KeyPoint] = [],
             dataCollectionPractices: [DataPractice] = [],
             dataSharingPractices: [DataPractice] = [],
             concernAreas: [ConcernArea] = []) {
            self.id = id
            self.serviceId = serviceId
            self.policyURL = policyURL
            self.lastUpdated = lastUpdated
            self.policyText = policyText
            self.summary = summary
            self.keyPoints = keyPoints
            self.dataCollectionPractices = dataCollectionPractices
            self.dataSharingPractices = dataSharingPractices
            self.concernAreas = concernAreas
        }
    }
    
    // MARK: - Timeline Events
    struct TimelineEvent: Identifiable, Codable {
        let id: String
        let userId: String
        let serviceId: String?
        let title: String
        let description: String
        let eventType: EventType
        let timestamp: Date
        let actionTaken: Bool
        
        enum EventType: String, Codable, CaseIterable {
            case accountCreation
            case accountActivity
            case dataBreach
            case privacyPolicyChange
            case deletionRequest
            case deletionConfirmation
            
            var icon: String {
                switch self {
                case .accountCreation: return "person.badge.plus"
                case .accountActivity: return "person.fill"
                case .dataBreach: return "exclamationmark.shield"
                case .privacyPolicyChange: return "doc.text"
                case .deletionRequest: return "trash"
                case .deletionConfirmation: return "checkmark.circle"
                }
            }
            
            var color: Color {
                switch self {
                case .accountCreation: return Color.blue
                case .accountActivity: return Color.green
                case .dataBreach: return Color.red
                case .privacyPolicyChange: return Color.yellow
                case .deletionRequest: return Color.orange
                case .deletionConfirmation: return Color.green
                }
            }
        }
        
        init(id: String = UUID().uuidString,
             userId: String,
             serviceId: String? = nil,
             title: String,
             description: String,
             eventType: EventType,
             timestamp: Date = Date(),
             actionTaken: Bool = false) {
            self.id = id
            self.userId = userId
            self.serviceId = serviceId
            self.title = title
            self.description = description
            self.eventType = eventType
            self.timestamp = timestamp
            self.actionTaken = actionTaken
        }
    }
} 