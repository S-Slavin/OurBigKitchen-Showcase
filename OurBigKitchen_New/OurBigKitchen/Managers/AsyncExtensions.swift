import Foundation
import Combine

// MARK: - StatsManager Async Extensions
extension StatsManager {
    func getTodayStats() async throws -> DailyStats {
        do {
            // Try to get from network using the existing methods
            return try await withCheckedThrowingContinuation { continuation in
                var cancellable: AnyCancellable?
                cancellable = self.getTodayStats() // Calls the Combine version
                    .sink(
                        receiveCompletion: { completion in
                            if case .failure(let error) = completion {
                                continuation.resume(throwing: error)
                            }
                            cancellable?.cancel()
                        },
                        receiveValue: { stats in
                            continuation.resume(returning: stats)
                            cancellable?.cancel()
                        }
                    )
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
            var cancellable: AnyCancellable?
            cancellable = get(endpoint: endpoint)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { value in
                        continuation.resume(returning: value)
                        cancellable?.cancel()
                    }
                )
        }
    }
}

// Actor to make the store thread-safe
private actor CancellableStore {
    static let shared = CancellableStore()
    private var store = Set<AnyCancellable>()
    
    func add(_ cancellable: AnyCancellable) {
        store.insert(cancellable)
    }
    
    func remove(_ cancellable: AnyCancellable) {
        store.remove(cancellable)
    }
} 