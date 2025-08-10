//
//  LeaderboardViewModel.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//


import Foundation
import SwiftUI
import Combine

// We'll use the types from StatsManager and from UserManager directly

@MainActor
class LeaderboardViewModel: ObservableObject {
    @Published var individualRankings: [UserRanking] = []
    @Published var corporateRankings: [CorporateRanking] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var selectedUserCategory: UserRankingCategory = .impact
    @Published var selectedCorporateCategory: RankingCategory = .impact
    
    // Keeping our mappable types
    struct UserRankingUI: Identifiable {
        let id: String
        let user: AppModels.User
        let rank: Int
        let value: Double
        let category: UserRankingCategory
        
        init(from ranking: UserRanking) {
            self.id = ranking.user.id
            self.user = ranking.user
            self.rank = ranking.rank
            self.value = Double(ranking.score)
            self.category = .impact // Default
        }
    }
    
    struct CorporateRankingUI: Identifiable {
        let id: String
        let companyName: String
        let logoURL: String?
        let rank: Int
        let value: Double
        let category: RankingCategory
        let employeeCount: Int
        
        init(from ranking: CorporateRanking) {
            self.id = ranking.partnerId
            self.companyName = ranking.name // Match with the model in StatsManager
            self.logoURL = nil // Not provided in StatsManager model
            self.rank = ranking.rank
            self.value = Double(ranking.score) // Match with the model in StatsManager
            self.category = RankingCategory.impact // Default, use explicit type
            self.employeeCount = 0 // Default since not provided in StatsManager model
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    private let userManager: UserManager
    private let statsManager: StatsManager
    
    init(userManager: UserManager? = nil,
         statsManager: StatsManager? = nil) {
        self.userManager = userManager ?? UserManager.shared
        self.statsManager = statsManager ?? StatsManager.shared
        loadData()
    }
    
    func loadData() {
        isLoading = true
        
        // Load individual rankings
        userManager.getUserRankings(category: selectedUserCategory)
            .sink { [weak self] (completion: Subscribers.Completion<Error>) in
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] (rankings: [UserRanking]) in
                self?.individualRankings = rankings
            }
            .store(in: &cancellables)
        
        // Load corporate rankings
        statsManager.getCorporateRankings(category: selectedCorporateCategory)
            .sink { [weak self] (completion: Subscribers.Completion<Error>) in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] (rankings: [CorporateRanking]) in
                self?.corporateRankings = rankings
            }
            .store(in: &cancellables)
    }
    
    func refreshData() {
        loadData()
    }
    
    func setUserCategory(_ category: UserRankingCategory) {
        selectedUserCategory = category
        loadData()
    }
    
    func setCorporateCategory(_ category: RankingCategory) {
        selectedCorporateCategory = category
        loadData()
    }
    
    // Helper methods
    func getUserRanking(for userId: String) -> UserRanking? {
        individualRankings.first { $0.user.id == userId }
    }
    
    func getCorporateRanking(for companyId: String) -> CorporateRanking? {
        corporateRankings.first { $0.partnerId == companyId }
    }
}