//
//  AnalyticsViewModel.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//


import Foundation
import Combine
import SwiftUI

class AnalyticsViewModel: ObservableObject {
    @Published var analyticsData: AnalyticsData?
    @Published var socialMetrics: SocialMetrics?
    @Published var impactData: ImpactData?
    @Published var isLoading = false
    @Published var error: Error?
    @Published var selectedTimeRange: TimeRange = .week
    
    private let analyticsManager: AnalyticsManager
    private let networkManager: NetworkManager
    private var cancellables = Set<AnyCancellable>()
    
    init(analyticsManager: AnalyticsManager = .shared,
         networkManager: NetworkManager = .shared) {
        self.analyticsManager = analyticsManager
        self.networkManager = networkManager
        
        loadData()
        setupObservers()
    }
    
    // MARK: - Data Loading
    
    func loadData() {
        isLoading = true
        
        // Load dummy analytics data for now
        analyticsData = AnalyticsData(
            activeUsers: 125,
            sessions: 843,
            averageSessionDuration: 1200, // 20 minutes
            retentionRate: 0.76,
            topEvents: ["meal_prep": 56, "delivery": 38, "cleanup": 24]
        )
        
        // Load dummy social metrics for now
        socialMetrics = SocialMetrics(
            followers: 230,
            following: 120,
            shares: 78,
            likes: 342,
            comments: 98
        )
        
        // Load dummy impact data for now
        impactData = ImpactData(
            type: .mealsServed,
            value: 1250,
            unit: "meals",
            timestamp: Date()
        )
        
        isLoading = false
        
        // Track page visit
        analyticsManager.trackScreen("analytics_dashboard", properties: [
            "time_range": selectedTimeRange.rawValue
        ])
    }
    
    // MARK: - Social Actions
    
    func shareAchievement(_ achievement: UIAchievement) {
        analyticsManager.trackEvent(OBKAnalyticsEvent(
            name: "achievement_shared",
            properties: ["achievement_id": achievement.id.uuidString]
        ))
        
        // Implement social sharing logic here
    }
    
    func shareImpact(_ impact: ImpactData) {
        analyticsManager.trackEvent(OBKAnalyticsEvent(
            name: "impact_shared",
            properties: ["impact_type": impact.type.rawValue]
        ))
        
        // Implement social sharing logic here
    }
    
    // MARK: - Helper Methods
    
    private func setupObservers() {
        // Observe time range changes
        $selectedTimeRange
            .dropFirst()
            .sink { [weak self] _ in
                self?.loadData()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Supporting Types
    
    struct AnalyticsData: Codable {
        let activeUsers: Int
        let sessions: Int
        let averageSessionDuration: TimeInterval
        let retentionRate: Double
        let topEvents: [String: Int]
    }
    
    struct SocialMetrics: Codable {
        let followers: Int
        let following: Int
        let shares: Int
        let likes: Int
        let comments: Int
    }
    
    struct ImpactData: Codable {
        let type: ImpactType
        let value: Double
        let unit: String
        let timestamp: Date
    }
    
    enum TimeRange: String, Codable {
        case day
        case week
        case month
        case year
    }
    
    enum ImpactType: String, Codable {
        case mealsServed
        case volunteers
        case wasteReduced
        case donations
    }
}