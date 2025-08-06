import Foundation
import SwiftUI
import Combine

@MainActor
@Observable
class MainViewModel: @unchecked Sendable {
    // Tab selection
    var selectedTab: Int = 0
    
    // User data
    var currentUser: AppModels.User?
    var isLoading = false
    var errorMessage: String?
    
    // Quick stats for dashboard
    var todayMealsServed: Int = 0
    var thisWeekVolunteers: Int = 0
    var totalImpact: Double = 0.0
    
    // Dependencies
    private let userManager: UserManager
    
    init(userManager: UserManager = .shared) {
        self.userManager = userManager
        loadUserData()
        loadQuickStats()
    }
    
    // MARK: - Navigation
    
    func selectTab(_ index: Int) {
        selectedTab = index
    }
    
    // MARK: - Data Loading
    
    func loadUserData() {
        currentUser = userManager.currentUser
    }
    
    func loadQuickStats() {
        // Mock data for quick dashboard stats
        todayMealsServed = 47
        thisWeekVolunteers = 12
        totalImpact = 234.5
    }
    
    func refreshData() async {
        isLoading = true
        
        // Simulate loading
        try? await Task.sleep(for: .milliseconds(500))
        
        loadUserData()
        loadQuickStats()
        
        isLoading = false
    }
} 