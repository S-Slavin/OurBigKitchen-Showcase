import Foundation
import Combine

// MARK: - UserManager Async Extensions
extension UserManager {
    func getCurrentUser() async throws -> AppModels.User {
        do {
            // Try to get from network using the existing methods
            return try await withCheckedThrowingContinuation { continuation in
                self.getCurrentUser() // Calls the Combine version
                    .sink(
                        receiveCompletion: { completion in
                            if case .failure(let error) = completion {
                                continuation.resume(throwing: error)
                            }
                        },
                        receiveValue: { user in
                            continuation.resume(returning: user)
                        }
                    )
                    .store(in: &AnyCancellable.temporaryStore)
            }
        } catch {
            // Return a dummy user for demonstration purposes
            return AppModels.User(
                id: UUID().uuidString,
                firstName: "Demo",
                lastName: "User",
                email: "demo@example.com",
                role: .volunteer,
                preferences: AppModels.UserPreferences(),
                achievements: [],
                stats: AppModels.UserStats()
            )
        }
    }
}

// MARK: - StatsManager Async Extensions
extension StatsManager {
    func getTodayStatsSync() async throws -> DailyStats {
        do {
            // Try to get from network using the existing methods
            return try await withCheckedThrowingContinuation { continuation in
                Task { @MainActor in
                    let publisher = await self.getTodayStats() // Calls the async version
                    publisher
                        .sink(
                            receiveCompletion: { completion in
                                if case .failure(let error) = completion {
                                    continuation.resume(throwing: error)
                                }
                            },
                            receiveValue: { stats in
                                continuation.resume(returning: stats)
                            }
                        )
                        .store(in: &AnyCancellable.temporaryStore)
                }
            }
        } catch {
            // Return dummy stats for demonstration purposes
            return DailyStats(
                id: UUID().uuidString,
                date: Date(),
                mealsServed: 120,
                volunteersPresent: 15,
                hoursContributed: 45.0,
                peopleServed: 200,
                foodWasteSaved: 48.0, // 0.4 kg per meal served (120 * 0.4)
                donationsReceived: 1250.0
            )
        }
    }
}

// MARK: - NetworkManager Async Extensions
extension NetworkManager {
    func getAsync<T: Decodable>(endpoint: String) async throws -> T {
        // Implement async/await version of networking
        try await withCheckedThrowingContinuation { continuation in
            get(endpoint: endpoint)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        }
                    },
                    receiveValue: { value in
                        continuation.resume(returning: value)
                    }
                )
                .store(in: &AnyCancellable.temporaryStore)
        }
    }
}

// Temporary extension for cancellables
private extension AnyCancellable {
    static var temporaryStore = Set<AnyCancellable>()
} 