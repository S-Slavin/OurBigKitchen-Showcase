import Foundation
import Combine

// MARK: - Network Protocol

@preconcurrency
protocol NetworkManaging {
    func get<T: Decodable>(endpoint: String) -> AnyPublisher<T, Error>
    func post<T: Encodable, U: Decodable>(endpoint: String, body: T) -> AnyPublisher<U, Error>
    func put<T: Encodable, U: Decodable>(endpoint: String, body: T) -> AnyPublisher<U, Error>
    func delete(endpoint: String) -> AnyPublisher<Void, Error>
}

// MARK: - API Constants

private enum APIConstants {
    static let baseURL = "https://api.ourbigkitchen.com/v1"
    static let authTokenKey = "authToken"
    static let contentTypeJSON = "application/json"
    static let authHeaderKey = "Authorization"
    static let bearerPrefix = "Bearer "
    static let timeoutInterval: TimeInterval = 30.0
}

// MARK: - Network Manager

class NetworkManager: NetworkManaging {
    static let shared = NetworkManager()
    
    private let session: URLSession
    private let authToken: String?
    
    private init() {
        self.session = URLSession.shared
        self.authToken = UserDefaults.standard.string(forKey: APIConstants.authTokenKey)
    }
    
    // MARK: - Network Protocol Implementation
    
    func get<T: Decodable>(endpoint: String) -> AnyPublisher<T, Error> {
        guard let url = buildURL(for: endpoint) else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = APIConstants.timeoutInterval
        addHeaders(to: &request)
        
        return performRequest(request)
    }
    
    func post<T: Encodable, U: Decodable>(endpoint: String, body: T) -> AnyPublisher<U, Error> {
        guard let url = buildURL(for: endpoint) else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = APIConstants.timeoutInterval
        request.setValue(APIConstants.contentTypeJSON, forHTTPHeaderField: "Content-Type")
        addHeaders(to: &request)
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            return Fail(error: NetworkError.encodingError(error))
                .eraseToAnyPublisher()
        }
        
        return performRequest(request)
    }
    
    func put<T: Encodable, U: Decodable>(endpoint: String, body: T) -> AnyPublisher<U, Error> {
        guard let url = buildURL(for: endpoint) else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.timeoutInterval = APIConstants.timeoutInterval
        request.setValue(APIConstants.contentTypeJSON, forHTTPHeaderField: "Content-Type")
        addHeaders(to: &request)
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            return Fail(error: NetworkError.encodingError(error))
                .eraseToAnyPublisher()
        }
        
        return performRequest(request)
    }
    
    func delete(endpoint: String) -> AnyPublisher<Void, Error> {
        guard let url = buildURL(for: endpoint) else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.timeoutInterval = APIConstants.timeoutInterval
        addHeaders(to: &request)
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response in
                try self.validateResponse(response)
            }
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Private Methods
    
    private func buildURL(for endpoint: String) -> URL? {
        let fullURLString = APIConstants.baseURL + endpoint
        return URL(string: fullURLString)
    }
    
    private func performRequest<T: Decodable>(_ request: URLRequest) -> AnyPublisher<T, Error> {
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response in
                try self.validateResponse(response)
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                if let networkError = error as? NetworkError {
                    return networkError
                }
                return NetworkError.decodingError(error)
            }
            .eraseToAnyPublisher()
    }
    
    private func addHeaders(to request: inout URLRequest) {
        if let token = authToken {
            request.setValue(APIConstants.bearerPrefix + token, forHTTPHeaderField: APIConstants.authHeaderKey)
        }
    }
    
    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(httpResponse.statusCode)
        }
    }
}

// MARK: - Network Errors

enum NetworkError: LocalizedError {
    case invalidURL
    case encodingError(Error)
    case decodingError(Error)
    case invalidResponse
    case httpError(Int)
    case noData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .encodingError(let error):
            return "Encoding error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .noData:
            return "No data received"
        }
    }
} 