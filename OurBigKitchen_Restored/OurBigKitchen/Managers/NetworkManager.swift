import Foundation
import Combine

// MARK: - Network Protocol
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
}

@MainActor
class NetworkManager: NetworkManaging {
    static let shared = NetworkManager()
    
    private let session: URLSession
    
    private init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: - Daily Stats
    
    func getDailyStats(date: Date) -> AnyPublisher<DailyStats, Error> {
        let dateString = ISO8601DateFormatter().string(from: date)
        return get(endpoint: "/stats/daily/\(dateString)")
    }
    
    func getDailyStats(from startDate: Date, to endDate: Date) -> AnyPublisher<[DailyStats], Error> {
        let formatter = ISO8601DateFormatter()
        let endpoint = "/stats/daily?from=\(formatter.string(from: startDate))&to=\(formatter.string(from: endDate))"
        return get(endpoint: endpoint)
    }
    
    func updateDailyStats(_ stats: DailyStats) -> AnyPublisher<DailyStats, Error> {
        return put(endpoint: "/stats/daily/\(stats.id)", body: stats)
    }
    
    // MARK: - Impact Metrics
    
    func getImpactMetrics() -> AnyPublisher<[ImpactMetric], Error> {
        return get(endpoint: "/stats/impact")
    }
    
    func updateImpactMetric(_ metric: ImpactMetric) -> AnyPublisher<ImpactMetric, Error> {
        return put(endpoint: "/stats/impact", body: metric)
    }
    
    // MARK: - Corporate Rankings
    
    func getCorporateRankings(category: RankingCategory) -> AnyPublisher<[CorporateRanking], Error> {
        return get(endpoint: "/stats/rankings/corporate/\(category.rawValue)")
    }
    
    // MARK: - Analytics
    
    func getAnalyticsReport(startDate: Date, endDate: Date) -> AnyPublisher<AppModels.AnalyticsReport, Error> {
        let formatter = ISO8601DateFormatter()
        let endpoint = "/stats/analytics?from=\(formatter.string(from: startDate))&to=\(formatter.string(from: endDate))"
        return get(endpoint: endpoint)
    }
    
    // MARK: - Generic Network Methods
    
    func get<T: Decodable>(endpoint: String) -> AnyPublisher<T, Error> {
        // For testing, return a mock response
        return Future<T, Error> { promise in
            // Simulate network delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if let mockResponse = self.createMockResponse(for: endpoint, as: T.self) {
                    promise(.success(mockResponse))
                } else {
                    promise(.failure(NetworkError.invalidResponse))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func post<T: Encodable, U: Decodable>(endpoint: String, body: T) -> AnyPublisher<U, Error> {
        // For testing, return a mock response
        return Future<U, Error> { promise in
            // Simulate network delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if let mockResponse = self.createMockResponse(for: endpoint, as: U.self) {
                    promise(.success(mockResponse))
                } else {
                    promise(.failure(NetworkError.invalidResponse))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func put<T: Encodable, U: Decodable>(endpoint: String, body: T) -> AnyPublisher<U, Error> {
        // For testing, return a mock response
        return Future<U, Error> { promise in
            // Simulate network delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if let mockResponse = self.createMockResponse(for: endpoint, as: U.self) {
                    promise(.success(mockResponse))
                } else {
                    promise(.failure(NetworkError.invalidResponse))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func delete(endpoint: String) -> AnyPublisher<Void, Error> {
        // For testing, return success
        return Future<Void, Error> { promise in
            // Simulate network delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Helper Methods
    
    private func createMockResponse<T>(for endpoint: String, as type: T.Type) -> T? {
        // Create appropriate mock responses based on the endpoint
        switch endpoint {
        case "/users/current":
            let mockUser = AppModels.User(
                id: UUID().uuidString,
                firstName: "Test",
                lastName: "User",
                email: "test@example.com",
                role: .volunteer
            )
            return mockUser as? T
            
        case "/users/achievements":
            let mockAchievements = [
                AppModels.UserAchievement(
                    title: "First Volunteer",
                    description: "Completed first volunteer session"
                )
            ]
            return mockAchievements as? T
            
        default:
            return nil
        }
    }
}

// MARK: - Network Error
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case requestFailed(Error)
    case encodingFailed(Error)
    case decodingFailed(Error)
}

// MARK: - URLRequest Extension
private extension URLRequest {
    mutating func addAuthenticationHeader() {
        if let token = UserDefaults.standard.string(forKey: APIConstants.authTokenKey) {
            setValue("\(APIConstants.bearerPrefix)\(token)", forHTTPHeaderField: APIConstants.authHeaderKey)
        }
    }
} 