import Foundation
import Combine

// MARK: - Salesforce Configuration

struct SalesforceConfig {
    // TODO: Update with actual Salesforce instance details
    static let baseURL = "https://your-instance.salesforce.com"
    static let apiVersion = "v58.0"
    
    // Authentication credentials - will be configured during setup
    static let clientId = "your-client-id"
    static let clientSecret = "your-client-secret"
    static let username = "your-username"
    static let password = "your-password"
    static let securityToken = "your-security-token"
    
    // API endpoints
    static let authEndpoint = "/services/oauth2/token"
    static let queryEndpoint = "/services/data/v\(apiVersion)/query"
    static let sobjectEndpoint = "/services/data/v\(apiVersion)/sobjects"
    
    // Custom object names
    static let volunteerObject = "Volunteer__c"
    static let volunteerSessionObject = "Volunteer_Session__c"
    static let impactMetricObject = "Impact_Metric__c"
}

// MARK: - Salesforce Authentication

struct SalesforceAuthResponse: Codable {
    let accessToken: String
    let instanceURL: String
    let tokenType: String
    let issuedAt: String
    let signature: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case instanceURL = "instance_url"
        case tokenType = "token_type"
        case issuedAt = "issued_at"
        case signature
    }
}

// MARK: - Salesforce Objects

struct SalesforceContact: Codable {
    let id: String?
    let firstName: String
    let lastName: String
    let email: String
    let birthdate: String?
    let phone: String?
    let mailingStreet: String?
    let mailingCity: String?
    let mailingState: String?
    let mailingPostalCode: String?
    let mailingCountry: String?
    let volunteerType: String?
    let wwccNumber: String?
    let wwccExpiryDate: String?
    let volunteerStatus: String?
    let recordTypeId: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case firstName = "FirstName"
        case lastName = "LastName"
        case email = "Email"
        case birthdate = "Birthdate"
        case phone = "Phone"
        case mailingStreet = "MailingStreet"
        case mailingCity = "MailingCity"
        case mailingState = "MailingState"
        case mailingPostalCode = "MailingPostalCode"
        case mailingCountry = "MailingCountry"
        case volunteerType = "Volunteer_Type__c"
        case wwccNumber = "WWCC_Number__c"
        case wwccExpiryDate = "WWCC_Expiry_Date__c"
        case volunteerStatus = "Volunteer_Status__c"
        case recordTypeId = "RecordTypeId"
    }
}

struct SalesforceAccount: Codable {
    let id: String?
    let name: String
    let type: String?
    let industry: String?
    let phone: String?
    let billingStreet: String?
    let billingCity: String?
    let billingState: String?
    let billingPostalCode: String?
    let billingCountry: String?
    let volunteerGroupSize: Int?
    let volunteerGroupType: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case type = "Type"
        case industry = "Industry"
        case phone = "Phone"
        case billingStreet = "BillingStreet"
        case billingCity = "BillingCity"
        case billingState = "BillingState"
        case billingPostalCode = "BillingPostalCode"
        case billingCountry = "BillingCountry"
        case volunteerGroupSize = "Volunteer_Group_Size__c"
        case volunteerGroupType = "Volunteer_Group_Type__c"
    }
}

// MARK: - Salesforce Service

@MainActor
class SalesforceService: ObservableObject {
    static let shared = SalesforceService()
    
    @Published private(set) var isAuthenticated = false
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    private var authResponse: SalesforceAuthResponse?
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    // MARK: - Authentication
    
    func authenticate() -> AnyPublisher<SalesforceAuthResponse, Error> {
        isLoading = true
        
        let authURL = SalesforceConfig.baseURL + SalesforceConfig.authEndpoint
        
        guard let url = URL(string: authURL) else {
            return Fail(error: SalesforceError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let body = [
            "grant_type": "password",
            "client_id": SalesforceConfig.clientId,
            "client_secret": SalesforceConfig.clientSecret,
            "username": SalesforceConfig.username,
            "password": SalesforceConfig.password + SalesforceConfig.securityToken
        ]
        
        request.httpBody = body
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      200...299 ~= httpResponse.statusCode else {
                    throw SalesforceError.authenticationFailed
                }
                
                do {
                    let authResponse = try JSONDecoder().decode(SalesforceAuthResponse.self, from: data)
                    self.authResponse = authResponse
                    self.isAuthenticated = true
                    self.isLoading = false
                    return authResponse
                } catch {
                    throw SalesforceError.decodingError(error)
                }
            }
            .handleEvents(receiveCompletion: { [weak self] completion in
                if case .failure = completion {
                    self?.isLoading = false
                }
            })
            .eraseToAnyPublisher()
    }
    
    // MARK: - Data Operations
    
    func queryRecords(_ soql: String) -> AnyPublisher<[String: Any], Error> {
        guard let authResponse = authResponse else {
            return Fail(error: SalesforceError.notAuthenticated)
                .eraseToAnyPublisher()
        }
        
        let queryURL = authResponse.instanceURL + SalesforceConfig.queryEndpoint + "?q=" + soql.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        guard let url = URL(string: queryURL) else {
            return Fail(error: SalesforceError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authResponse.accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      200...299 ~= httpResponse.statusCode else {
                    throw SalesforceError.queryFailed
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    return json ?? [:]
                } catch {
                    throw SalesforceError.decodingError(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func createRecord(_ objectName: String, fields: [String: Any]) -> AnyPublisher<String, Error> {
        guard let authResponse = authResponse else {
            return Fail(error: SalesforceError.notAuthenticated)
                .eraseToAnyPublisher()
        }
        
        let createURL = authResponse.instanceURL + SalesforceConfig.sobjectEndpoint + "/" + objectName
        
        guard let url = URL(string: createURL) else {
            return Fail(error: SalesforceError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(authResponse.accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: fields)
        } catch {
            return Fail(error: SalesforceError.encodingError(error))
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      200...299 ~= httpResponse.statusCode else {
                    throw SalesforceError.createFailed
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    return json?["id"] as? String ?? ""
                } catch {
                    throw SalesforceError.decodingError(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func updateRecord(_ objectName: String, id: String, fields: [String: Any]) -> AnyPublisher<Void, Error> {
        guard let authResponse = authResponse else {
            return Fail(error: SalesforceError.notAuthenticated)
                .eraseToAnyPublisher()
        }
        
        let updateURL = authResponse.instanceURL + SalesforceConfig.sobjectEndpoint + "/" + objectName + "/" + id
        
        guard let url = URL(string: updateURL) else {
            return Fail(error: SalesforceError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(authResponse.accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: fields)
        } catch {
            return Fail(error: SalesforceError.encodingError(error))
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { _, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      200...299 ~= httpResponse.statusCode else {
                    throw SalesforceError.updateFailed
                }
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Helper Methods
    
    func logout() {
        authResponse = nil
        isAuthenticated = false
        error = nil
    }
    
    func clearError() {
        error = nil
    }
}

// MARK: - Salesforce Errors

enum SalesforceError: LocalizedError {
    case authenticationFailed
    case notAuthenticated
    case queryFailed
    case createFailed
    case updateFailed
    case encodingError(Error)
    case decodingError(Error)
    case networkError
    case invalidURL
    
    var errorDescription: String? {
        switch self {
        case .authenticationFailed:
            return "Salesforce authentication failed"
        case .notAuthenticated:
            return "Not authenticated with Salesforce"
        case .queryFailed:
            return "Failed to query Salesforce records"
        case .createFailed:
            return "Failed to create Salesforce record"
        case .updateFailed:
            return "Failed to update Salesforce record"
        case .encodingError(let error):
            return "Failed to encode data: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError:
            return "Network error occurred"
        case .invalidURL:
            return "Invalid URL generated for Salesforce query"
        }
    }
}
