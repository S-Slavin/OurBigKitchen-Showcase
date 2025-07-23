import Foundation
import Combine
import SwiftUI

// This service manages impact posts, statistics, and sharing
class ImpactService: ObservableObject {
    static let shared = ImpactService()
    
    // Published properties for SwiftUI updates
    @Published private(set) var impactPosts: [ImpactPost] = []
    @Published private(set) var userStats: [String: UserImpactStats] = [:]
    @Published private(set) var totalMealsServed: Int = 0
    @Published private(set) var familiesHelped: Int = 0
    @Published private(set) var livesTouched: Int = 0
    @Published private(set) var foodSavedKg: Double = 0.0
    
    private init() {
        // Generate some sample data for demo purposes
        generateSampleData()
    }
    
    // MARK: - Public API
    
    func saveImpactPost(_ post: ImpactPost) -> AnyPublisher<Bool, Error> {
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
    
    func getRecentImpactPosts(userId: String, limit: Int) -> AnyPublisher<[ImpactPost], Error> {
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
    
    func getUserStats(userId: String) -> AnyPublisher<UserImpactStats, Error> {
        // Get user stats or create default
        let stats = userStats[userId] ?? UserImpactStats(totalImpacts: 0, totalShares: 0, totalViews: 0)
        
        return Just(stats)
            .setFailureType(to: Error.self)
            .delay(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func incrementShareCount(for postId: String) -> Void {
        if let index = impactPosts.firstIndex(where: { $0.id == postId }) {
            // Update the post
            var post = impactPosts[index]
            post.shares += 1
            impactPosts[index] = post
            
            // Also update user stats
            updateUserStats(for: post.userId)
        }
    }
    
    func incrementViewCount(for postId: String) -> Void {
        if let index = impactPosts.firstIndex(where: { $0.id == postId }) {
            // Update the post
            var post = impactPosts[index]
            post.views += 1
            impactPosts[index] = post
            
            // Also update user stats
            updateUserStats(for: post.userId)
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
            // We're not using real images in this sample
            // In a real implementation, images would be loaded from assets or a server
            
            let post = ImpactPost(
                id: "sample\(i)",
                userId: userIds[i % userIds.count],
                message: messages[i % messages.count],
                date: Calendar.current.date(byAdding: .day, value: -i, to: Date()) ?? Date(),
                tags: Array(sampleTags.prefix(2 + (i % 3))),
                views: Int.random(in: 5...20),
                shares: Int.random(in: 0...10),
                imageData: nil // No actual image data in samples
            )
            
            impactPosts.append(post)
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