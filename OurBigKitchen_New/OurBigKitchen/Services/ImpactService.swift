import Foundation
import Combine
import SwiftUI

// This service manages impact posts, statistics, and sharing
@Observable
public final class ImpactService: @unchecked Sendable {
    public static let shared = ImpactService()
    
    // Observable properties
    private(set) var impactPosts: [ImpactPost] = []
    private(set) var userStats: [String: UserImpactStats] = [:]
    private(set) var totalMealsServed: Int = 0
    private(set) var familiesHelped: Int = 0
    private(set) var livesTouched: Int = 0
    private(set) var foodSavedKg: Double = 0.0
    private(set) var impacts: [Impact] = []
    
    public init() {
        // Generate some sample data for demo purposes
        generateSampleData()
    }
    
    // MARK: - Public API
    
    public func saveImpactPost(_ post: ImpactPost) -> AnyPublisher<Bool, Error> {
        // Add or update the post
        if let index = impactPosts.firstIndex(where: { $0.id == post.id }) {
            impactPosts[index] = post
        } else {
            impactPosts.append(post)
            
            // Update user stats
            updateUserStats(for: post.userId)
        }
        
        // For demo, just return success
        return Just(true)
            .setFailureType(to: Error.self)
            .delay(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    public func getRecentImpactPosts(userId: String, limit: Int) -> AnyPublisher<[ImpactPost], Error> {
        // Get posts for user, sorted by most recent
        let filteredPosts = impactPosts
            .filter { $0.userId == userId }
            .sorted(by: { $0.date > $1.date })
            .prefix(limit)
        
        return Just(Array(filteredPosts))
            .setFailureType(to: Error.self)
            .delay(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    public func getUserStats(userId: String) -> AnyPublisher<UserImpactStats, Error> {
        // Get user stats or create default
        let stats = userStats[userId] ?? UserImpactStats(totalImpacts: 0, totalShares: 0, totalViews: 0)
        
        return Just(stats)
            .setFailureType(to: Error.self)
            .delay(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    public func incrementShareCount(for postId: String) -> Void {
        if let index = impactPosts.firstIndex(where: { $0.id == postId }) {
            // Update the post
            var post = impactPosts[index]
            post.shares += 1
            impactPosts[index] = post
            
            // Also update user stats
            updateUserStats(for: post.userId)
        }
    }
    
    public func incrementViewCount(for postId: String) -> Void {
        if let index = impactPosts.firstIndex(where: { $0.id == postId }) {
            // Update the post
            var post = impactPosts[index]
            post.views += 1
            impactPosts[index] = post
            
            // Also update user stats
            updateUserStats(for: post.userId)
        }
    }
    
    public func getImpacts() -> [Impact] {
        return impacts
    }
    
    // MARK: - Public API Methods
    
    // Change internal types to public
    func submitImpactData(_ data: AppModels.ImpactMetric) async throws -> AppModels.ImpactMetric {
        return try await withCheckedThrowingContinuation { continuation in
            // Simulate network delay
            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1.0) {
                // In a real app, this would make an API call
                continuation.resume(returning: data)
            }
        }
    }
    
    func getImpactHistory() async throws -> [AppModels.ImpactMetric] {
        return try await withCheckedThrowingContinuation { continuation in
            // Simulate fetching impact history
            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1.0) {
                let mockHistory = [
                    AppModels.ImpactMetric(),
                    AppModels.ImpactMetric()
                ]
                continuation.resume(returning: mockHistory)
            }
        }
    }
    
    func getTotalImpact() async throws -> AppModels.ImpactMetric {
        return try await withCheckedThrowingContinuation { continuation in
            // Simulate fetching total impact
            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1.0) {
                continuation.resume(returning: AppModels.ImpactMetric())
            }
        }
    }
    
    func getLeaderboardData() async throws -> [AppModels.LeaderboardEntry] {
        return try await withCheckedThrowingContinuation { continuation in
            // Simulate fetching leaderboard data
            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1.0) {
                let mockLeaderboard = [
                    AppModels.LeaderboardEntry(rank: 1, user: AppModels.User(firstName: "Top", lastName: "User", email: "top@example.com"), totalImpact: 1000),
                    AppModels.LeaderboardEntry(rank: 2, user: AppModels.User(firstName: "Second", lastName: "User", email: "second@example.com"), totalImpact: 800)
                ]
                continuation.resume(returning: mockLeaderboard)
            }
        }
    }
    
    // MARK: - Private Helpers
    
    private func updateUserStats(for userId: String) {
        // Calculate stats based on user's posts
        let userPosts = impactPosts.filter { $0.userId == userId }
        let totalImpacts = userPosts.count
        let totalShares = userPosts.reduce(0) { $0 + $1.shares }
        let totalViews = userPosts.reduce(0) { $0 + $1.views }
        
        userStats[userId] = UserImpactStats(
            totalImpacts: totalImpacts,
            totalShares: totalShares,
            totalViews: totalViews
        )
    }
    
    private func generateSampleData() {
        // This method creates sample data for demo purposes
        let sampleTags = ["Cooking", "Volunteering", "Community", "Helping Others"]
        let messages = [
            "Helping serve meals at OBK today!",
            "Proud to be making a difference with OBK",
            "Community cooking session was amazing!",
            "Volunteering with an amazing team"
        ]
        
        // Sample user IDs
        let userIds = ["user1", "user2", "guest"]
        
        // Generate some sample posts
        for i in 0..<3 {
            let post = ImpactPost(
                id: "sample\(i)",
                userId: userIds[i % userIds.count],
                date: Calendar.current.date(byAdding: .day, value: -i, to: Date()) ?? Date(),
                tags: Array(sampleTags.prefix(2 + (i % 3))),
                message: messages[i % messages.count],
                imageData: nil,
                views: Int.random(in: 5...20),
                shares: Int.random(in: 0...10)
            )
            
            impactPosts.append(post)
            
            // Create corresponding impact
            let impact = Impact(
                id: post.id,
                userId: post.userId,
                timeSpent: Int.random(in: 1...5),
                mealsMade: Int.random(in: 10...50)
            )
            impacts.append(impact)
        }
        
        // Generate user stats based on these posts
        for userId in userIds {
            updateUserStats(for: userId)
        }
        
        // Set sample values for impact metrics
        totalMealsServed = 1250
        familiesHelped = 450
        livesTouched = 1800
        foodSavedKg = 750.5
    }
} 