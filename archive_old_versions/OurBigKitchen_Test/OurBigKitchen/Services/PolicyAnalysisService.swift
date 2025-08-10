import Foundation
import Combine

class PolicyAnalysisService {
    static let shared = PolicyAnalysisService()
    
    private init() {}
    
    // MARK: - Policy Analysis
    
    func analyzePolicyForService(_ service: FinePrintModels.DigitalService) -> AnyPublisher<FinePrintModels.PolicyAnalysis, Error> {
        return Future<FinePrintModels.PolicyAnalysis, Error> { promise in
            // In a real app, this would fetch and analyze the actual privacy policy
            // For demo purposes, we'll simulate this with a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                // Generate a sample policy analysis
                if let policyAnalysis = self.generateSamplePolicyAnalysis(for: service) {
                    promise(.success(policyAnalysis))
                } else {
                    promise(.failure(PolicyAnalysisError.analysisFailure))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Helper Methods
    
    private func generateSamplePolicyAnalysis(for service: FinePrintModels.DigitalService) -> FinePrintModels.PolicyAnalysis? {
        guard let policyURL = service.privacyPolicyURL else { return nil }
        
        // Create key points based on service risk level
        var keyPoints: [FinePrintModels.PolicyAnalysis.KeyPoint] = []
        var dataCollectionPractices: [FinePrintModels.PolicyAnalysis.DataPractice] = []
        var dataSharingPractices: [FinePrintModels.PolicyAnalysis.DataPractice] = []
        var concernAreas: [FinePrintModels.PolicyAnalysis.ConcernArea] = []
        
        // Add basic key points for all services
        keyPoints.append(
            FinePrintModels.PolicyAnalysis.KeyPoint(
                title: "Data Collection",
                description: "This service collects basic information such as your name, email, and device information.",
                severity: .info
            )
        )
        
        dataCollectionPractices.append(
            FinePrintModels.PolicyAnalysis.DataPractice(
                type: "Personal Information",
                description: "Name, email address, and contact details",
                purpose: "Account creation and service provision"
            )
        )
        
        dataCollectionPractices.append(
            FinePrintModels.PolicyAnalysis.DataPractice(
                type: "Device Information",
                description: "IP address, browser type, operating system",
                purpose: "Service improvement and debugging"
            )
        )
        
        // Add risk-specific items
        switch service.riskLevel {
        case .high:
            keyPoints.append(
                FinePrintModels.PolicyAnalysis.KeyPoint(
                    title: "Extensive Data Sharing",
                    description: "This service shares your data with numerous third parties for advertising and marketing purposes.",
                    severity: .high
                )
            )
            
            keyPoints.append(
                FinePrintModels.PolicyAnalysis.KeyPoint(
                    title: "Long Data Retention",
                    description: "This service may keep your data indefinitely, even after you delete your account.",
                    severity: .high
                )
            )
            
            dataSharingPractices.append(
                FinePrintModels.PolicyAnalysis.DataPractice(
                    type: "User Profile Data",
                    description: "All personal information and preferences",
                    purpose: "Shared with advertising partners"
                )
            )
            
            concernAreas.append(
                FinePrintModels.PolicyAnalysis.ConcernArea(
                    title: "Extensive Data Sharing",
                    description: "This service shares your personal data with multiple third parties without clear limitations.",
                    severity: .high,
                    recommendation: "Consider using alternative services with better privacy practices."
                )
            )
            
            concernAreas.append(
                FinePrintModels.PolicyAnalysis.ConcernArea(
                    title: "No Deletion Guarantee",
                    description: "The policy does not guarantee complete deletion of your data upon account termination.",
                    severity: .high,
                    recommendation: "Request explicit data deletion before closing your account."
                )
            )
            
        case .medium:
            keyPoints.append(
                FinePrintModels.PolicyAnalysis.KeyPoint(
                    title: "Limited Data Sharing",
                    description: "This service shares some of your data with select partners for specific purposes.",
                    severity: .medium
                )
            )
            
            dataSharingPractices.append(
                FinePrintModels.PolicyAnalysis.DataPractice(
                    type: "Usage Data",
                    description: "How you interact with the service",
                    purpose: "Shared with analytics partners"
                )
            )
            
            concernAreas.append(
                FinePrintModels.PolicyAnalysis.ConcernArea(
                    title: "Unclear Data Retention",
                    description: "The policy is not specific about how long they retain your data.",
                    severity: .medium,
                    recommendation: "Contact customer support to inquire about data retention policies."
                )
            )
            
        case .low:
            keyPoints.append(
                FinePrintModels.PolicyAnalysis.KeyPoint(
                    title: "Minimal Data Sharing",
                    description: "This service only shares your data when required by law or with your explicit consent.",
                    severity: .low
                )
            )
            
            keyPoints.append(
                FinePrintModels.PolicyAnalysis.KeyPoint(
                    title: "Clear Deletion Policy",
                    description: "This service allows you to request complete deletion of your data.",
                    severity: .info
                )
            )
            
            dataSharingPractices.append(
                FinePrintModels.PolicyAnalysis.DataPractice(
                    type: "Required Information",
                    description: "Only when legally required",
                    purpose: "Legal compliance"
                )
            )
        }
        
        // Create the policy summary based on the risk level
        let summarySections = [
            "This is an AI-generated summary of the privacy policy for \(service.name). This is not legal advice.",
            
            "Data Collection: \(service.name) collects personal information such as your name, email, and contact details for account creation and service delivery. They also collect device information such as IP address, browser type, and operating system for service improvement.",
            
            service.riskLevel == .high ? "Data Sharing: \(service.name) shares your personal information extensively with third-party partners for advertising, marketing, and analytics purposes. The policy does not clearly limit how these partners can use your data." : 
            service.riskLevel == .medium ? "Data Sharing: \(service.name) shares some user data with select partners for analytics and service improvement. The policy provides some limitations on how this data can be used." :
            "Data Sharing: \(service.name) has a restrictive data sharing policy, only sharing information when required by law or with your explicit consent.",
            
            service.riskLevel == .high ? "Data Retention: Your data may be retained indefinitely, even after account deletion. The policy does not guarantee complete removal of all data." :
            service.riskLevel == .medium ? "Data Retention: The policy is not specific about retention periods, but does outline a process for requesting data deletion." :
            "Data Retention: Your data will be retained only as long as necessary to provide services, and a clear process exists for requesting complete deletion.",
            
            "Last Updated: This privacy policy was last updated on \(dateFormatter.string(from: Date().addingTimeInterval(-86400 * 90)))"
        ]
        
        let summary = summarySections.joined(separator: "\n\n")
        
        return FinePrintModels.PolicyAnalysis(
            id: UUID().uuidString,
            serviceId: service.id,
            policyURL: policyURL,
            lastUpdated: Date().addingTimeInterval(-86400 * 90), // 90 days ago
            policyText: "This would contain the full policy text in a real implementation.",
            summary: summary,
            keyPoints: keyPoints,
            dataCollectionPractices: dataCollectionPractices,
            dataSharingPractices: dataSharingPractices,
            concernAreas: concernAreas
        )
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
}

enum PolicyAnalysisError: Error {
    case policyNotFound
    case analysisFailure
    case networkError
    
    var localizedDescription: String {
        switch self {
        case .policyNotFound:
            return "Privacy policy could not be found for this service."
        case .analysisFailure:
            return "An error occurred while analyzing the privacy policy."
        case .networkError:
            return "Network error. Please check your connection and try again."
        }
    }
} 