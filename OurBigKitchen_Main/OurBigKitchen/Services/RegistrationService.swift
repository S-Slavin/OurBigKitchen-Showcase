import Foundation
import Combine

struct RegistrationData: Codable {
    let userType: String
    let firstName: String
    let lastName: String
    let email: String
    let mobile: String
    let dateOfBirth: Date
    let address: String
    let emergencyContactName: String
    let emergencyContactPhone: String
    let companyName: String?
    let wwccNumber: String?
    let wwccExpiry: Date?
    let isDukeOfEd: Bool
    let referralSource: String
    let hasAcceptedFoodSafety: Bool
    let hasAcceptedTerms: Bool
}

enum RegistrationError: Error {
    case invalidData
    case networkError(Error)
    case serverError(String)
    case unknown
}

class RegistrationService {
    private let baseURL = "https://api.ourbigkitchen.org" // Replace with your actual API endpoint
    
    func submitRegistration(_ data: RegistrationData) -> AnyPublisher<Void, RegistrationError> {
        guard let url = URL(string: "\(baseURL)/api/volunteer/register") else {
            return Fail(error: RegistrationError.invalidData).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(data)
            request.httpBody = jsonData
            
            return URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { data, response in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw RegistrationError.unknown
                    }
                    
                    switch httpResponse.statusCode {
                    case 200...299:
                        return data
                    case 400:
                        throw RegistrationError.invalidData
                    case 500:
                        throw RegistrationError.serverError("Internal server error")
                    default:
                        throw RegistrationError.unknown
                    }
                }
                .map { _ in () }
                .mapError { error in
                    if let registrationError = error as? RegistrationError {
                        return registrationError
                    }
                    return RegistrationError.networkError(error)
                }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: RegistrationError.invalidData).eraseToAnyPublisher()
        }
    }
} 