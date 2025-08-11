//
//  HomeDashboardViewModel.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//


import Foundation
import Combine
import SwiftUI

// Helper class for converting AppModels.Activity to HomeActivityItem
extension AppModels.Activity {
    func toHomeActivityItem() -> HomeActivityItem {
        let activityType: HomeActivityItem.ActivityType
        
        switch self.category {
        case .cooking:
            activityType = .mealPrep
        case .serving, .cleaning, .organizing, .other:
            activityType = .volunteer
        case .delivery:
            activityType = .event
        }
        
        return HomeActivityItem(
            title: self.title,
            description: self.description,
            timestamp: self.date,
            type: activityType
        )
    }
}

@MainActor
class HomeDashboardViewModel: ObservableObject {
    @Published var user: AppModels.User?
    @Published var todayStats: DailyStats?
    @Published var upcomingEvents: [Event] = []
    @Published var recentActivities: [HomeActivityItem] = []
    @Published var upcomingSessions: [UpcomingSession] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var showMealTracking = false
    @Published var showVolunteerForm = false
    @Published var showFoodSafetyForm = false
    @Published var showSocialSharingForm = false
    @Published var showEventRebookingForm = false
    
    private var cancellables = Set<AnyCancellable>()
    private let userManager: UserManager
    private let statsManager: StatsManager
    private let eventManager: EventManager
    private let activityManager: ActivityManager
    
    init(userManager: UserManager? = nil,
         statsManager: StatsManager? = nil,
         eventManager: EventManager? = nil,
         activityManager: ActivityManager? = nil) {
        self.userManager = userManager ?? UserManager.shared
        self.statsManager = statsManager ?? StatsManager.shared
        self.eventManager = eventManager ?? EventManager.shared
        self.activityManager = activityManager ?? ActivityManager.shared
        
        loadData()
    }
    
    func loadData() {
        isLoading = true
        
        // Load user data
        userManager.fetchUserProfile()
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] (user: AppModels.User) in
                self?.user = user
            }
            .store(in: &cancellables)
        
        // Load today's stats with mock data for demo
        Task {
            // Create mock stats for demo purposes
            let mockStats = DailyStats(
                id: UUID().uuidString,
                date: Date(),
                mealsServed: 45,
                volunteersPresent: 12,
                hoursContributed: 8.5,
                peopleServed: 120,
                foodWasteSaved: 2.5,
                donationsReceived: 150.0
            )
            self.todayStats = mockStats
        }
        
        // Load upcoming events using the async method that has mock data
        Task {
            do {
                let events = try await eventManager.getUpcomingEvents()
                await MainActor.run {
                    self.upcomingEvents = events
                }
            } catch {
                print("Error loading upcoming events: \(error)")
            }
        }
        
        // Load recent activities
        activityManager.getRecentActivities()
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] (activities: [AppModels.Activity]) in
                self?.recentActivities = activities.map { $0.toHomeActivityItem() }
            }
            .store(in: &cancellables)
        
        isLoading = false
    }
    
    // Add a method to save user contributions directly from the home screen
    @MainActor
    func saveUserContribution(mealsMade: Int, hoursVolunteered: Double) {
        // Create an instance of the impact dashboard viewmodel
        Task {
            let impactViewModel = ImpactDashboardViewModel()
            
            // Set the values and save
            impactViewModel.mealsMadeString = "\(mealsMade)"
            impactViewModel.timeSpentString = "\(hoursVolunteered)"
            impactViewModel.saveUserContribution()
            
            // Refresh data to show any updated stats
            refreshData()
            
            // Post notification for any observers
            NotificationCenter.default.post(name: Notification.Name.didUpdateContribution, object: nil)
        }
    }
    
    func refreshData() {
        loadData()
    }
    
    private func loadUpcomingSessions() {
        // In a real app, you would fetch from a server or database
        // For now, just use sample data
        self.upcomingSessions = UpcomingSession.samples
    }
} 