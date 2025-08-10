import Foundation
import Combine

// MARK: - Salesforce Configuration
struct SalesforceConfig {
    static let baseURL = "https://your-instance.salesforce.com"
    static let apiVersion = "v58.0"
    static let clientId = "your-client-id"
    static let clientSecret = "your-client-secret"
    static let username = "your-username"
    static let password = "your-password"
    static let securityToken = "your-security-token"
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

struct SalesforceVolunteerEvent: Codable {
    let id: String?
    let name: String
    let eventDate: String?
    let startTime: String?
    let endTime: String?
    let location: String?
    let description: String?
    let maxVolunteers: Int?
    let currentVolunteers: Int?
    let status: String?
    let eventType: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case eventDate = "Event_Date__c"
        case startTime = "Start_Time__c"
        case endTime = "End_Time__c"
        case location = "Location__c"
        case description = "Description__c"
        case maxVolunteers = "Max_Volunteers__c"
        case currentVolunteers = "Current_Volunteers__c"
        case status = "Status__c"
        case eventType = "Event_Type__c"
    }
}

// MARK: - Salesforce Service Protocol
protocol SalesforceServiceProtocol {
    func authenticate() -> AnyPublisher<SalesforceAuthResponse, Error>
    func createContact(_ contact: SalesforceContact) -> AnyPublisher<String, Error>
    func createAccount(_ account: SalesforceAccount) -> AnyPublisher<String, Error>
    func createVolunteerEvent(_ event: SalesforceVolunteerEvent) -> AnyPublisher<String, Error>
    func updateContact(_ contact: SalesforceContact) -> AnyPublisher<Bool, Error>
    func updateAccount(_ account: SalesforceAccount) -> AnyPublisher<Bool, Error>
    func updateVolunteerEvent(_ event: SalesforceVolunteerEvent) -> AnyPublisher<Bool, Error>
    func queryContacts(query: String) -> AnyPublisher<[SalesforceContact], Error>
    func queryAccounts(query: String) -> AnyPublisher<[SalesforceAccount], Error>
    func queryVolunteerEvents(query: String) -> AnyPublisher<[SalesforceVolunteerEvent], Error>
    func deleteRecord(objectType: String, recordId: String) -> AnyPublisher<Bool, Error>
}

// MARK: - Salesforce Service Implementation
class SalesforceService: SalesforceServiceProtocol, ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private var accessToken: String?
    private var instanceURL: String?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Authentication
    func authenticate() -> AnyPublisher<SalesforceAuthResponse, Error> {
        isLoading = true
        
        let url = URL(string: "\(SalesforceConfig.baseURL)/services/oauth2/token")!
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
        
        request.httpBody = body.percentEncoded()
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: SalesforceAuthResponse.self, decoder: JSONDecoder())
            .handleEvents(
                receiveOutput: { [weak self] response in
                    self?.accessToken = response.accessToken
                    self?.instanceURL = response.instanceURL
                    self?.isAuthenticated = true
                    self?.isLoading = false
                },
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        self?.isLoading = false
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    // MARK: - CRUD Operations
    func createContact(_ contact: SalesforceContact) -> AnyPublisher<String, Error> {
        guard let accessToken = accessToken, let instanceURL = instanceURL else {
            return Fail(error: SalesforceError.notAuthenticated)
                .eraseToAnyPublisher()
        }
        
        let url = URL(string: "\(instanceURL)/services/data/\(SalesforceConfig.apiVersion)/sobjects/Contact")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(contact)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: SalesforceCreateResponse.self, decoder: JSONDecoder())
            .map(\.id)
            .eraseToAnyPublisher()
    }
    
    func createAccount(_ account: SalesforceAccount) -> AnyPublisher<String, Error> {
        guard let accessToken = accessToken, let instanceURL = instanceURL else {
            return Fail(error: SalesforceError.notAuthenticated)
                .eraseToAnyPublisher()
        }
        
        let url = URL(string: "\(instanceURL)/services/data/\(SalesforceConfig.apiVersion)/sobjects/Account")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(account)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: SalesforceCreateResponse.self, decoder: JSONDecoder())
            .map(\.id)
            .eraseToAnyPublisher()
    }
    
    func createVolunteerEvent(_ event: SalesforceVolunteerEvent) -> AnyPublisher<String, Error> {
        guard let accessToken = accessToken, let instanceURL = instanceURL else {
            return Fail(error: SalesforceError.notAuthenticated)
                .eraseToAnyPublisher()
        }
        
        let url = URL(string: "\(instanceURL)/services/data/\(SalesforceConfig.apiVersion)/sobjects/Volunteer_Event__c")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(event)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: SalesforceCreateResponse.self, decoder: JSONDecoder())
            .map(\.id)
            .eraseToAnyPublisher()
    }
    
    func updateContact(_ contact: SalesforceContact) -> AnyPublisher<Bool, Error> {
        guard let accessToken = accessToken, let instanceURL = instanceURL, let id = contact.id else {
            return Fail(error: SalesforceError.notAuthenticated)
                .eraseToAnyPublisher()
        }
        
        let url = URL(string: "\(instanceURL)/services/data/\(SalesforceConfig.apiVersion)/sobjects/Contact/\(id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(contact)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { _ in true }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
    
    func updateAccount(_ account: SalesforceAccount) -> AnyPublisher<Bool, Error> {
        guard let accessToken = accessToken, let instanceURL = instanceURL, let id = account.id else {
            return Fail(error: SalesforceError.notAuthenticated)
                .eraseToAnyPublisher()
        }
        
        let url = URL(string: "\(instanceURL)/services/data/\(SalesforceConfig.apiVersion)/sobjects/Account/\(id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(account)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { _ in true }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
    
    func updateVolunteerEvent(_ event: SalesforceVolunteerEvent) -> AnyPublisher<Bool, Error> {
        guard let accessToken = accessToken, let instanceURL = instanceURL, let id = event.id else {
            return Fail(error: SalesforceError.notAuthenticated)
                .eraseToAnyPublisher()
        }
        
        let url = URL(string: "\(instanceURL)/services/data/\(SalesforceConfig.apiVersion)/sobjects/Volunteer_Event__c/\(id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(event)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { _ in true }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Query Operations
    func queryContacts(query: String) -> AnyPublisher<[SalesforceContact], Error> {
        guard let accessToken = accessToken, let instanceURL = instanceURL else {
            return Fail(error: SalesforceError.notAuthenticated)
                .eraseToAnyPublisher()
        }
        
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let url = URL(string: "\(instanceURL)/services/data/\(SalesforceConfig.apiVersion)/query?q=\(encodedQuery)")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: SalesforceQueryResponse<SalesforceContact>.self, decoder: JSONDecoder())
            .map(\.records)
            .eraseToAnyPublisher()
    }
    
    func queryAccounts(query: String) -> AnyPublisher<[SalesforceAccount], Error> {
        guard let accessToken = accessToken, let instanceURL = instanceURL else {
            return Just(())
                .tryMap { _ in throw SalesforceError.notAuthenticated }
                .eraseToAnyPublisher()
        }
        
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let url = URL(string: "\(instanceURL)/services/data/\(SalesforceConfig.apiVersion)/query?q=\(encodedQuery)")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: SalesforceQueryResponse<SalesforceAccount>.self, decoder: JSONDecoder())
            .map(\.records)
            .eraseToAnyPublisher()
    }
    
    func queryVolunteerEvents(query: String) -> AnyPublisher<[SalesforceVolunteerEvent], Error> {
        guard let accessToken = accessToken, let instanceURL = instanceURL else {
            return Just(())
                .tryMap { _ in throw SalesforceError.notAuthenticated }
                .eraseToAnyPublisher()
        }
        
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let url = URL(string: "\(instanceURL)/services/data/\(SalesforceConfig.apiVersion)/query?q=\(encodedQuery)")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: SalesforceQueryResponse<SalesforceVolunteerEvent>.self, decoder: JSONDecoder())
            .map(\.records)
            .eraseToAnyPublisher()
    }
    
    func deleteRecord(objectType: String, recordId: String) -> AnyPublisher<Bool, Error> {
        guard let accessToken = accessToken, let instanceURL = instanceURL else {
            return Just(())
                .tryMap { _ in throw SalesforceError.notAuthenticated }
                .eraseToAnyPublisher()
        }
        
        let url = URL(string: "\(instanceURL)/services/data/\(SalesforceConfig.apiVersion)/sobjects/\(objectType)/\(recordId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { _ in true }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}

// MARK: - Response Models
struct SalesforceCreateResponse: Codable {
    let id: String
    let success: Bool
    let errors: [String]?
}

struct SalesforceQueryResponse<T: Codable>: Codable {
    let totalSize: Int
    let done: Bool
    let records: [T]
}

// MARK: - Errors
enum SalesforceError: Error, LocalizedError {
    case notAuthenticated
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Not authenticated with Salesforce"
        case .invalidResponse:
            return "Invalid response from Salesforce"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Extensions
extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}
