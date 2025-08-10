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
    
    init(userManager: UserManager = UserManager.shared,
         statsManager: StatsManager = StatsManager.shared,
         eventManager: EventManager = EventManager.shared,
         activityManager: ActivityManager = ActivityManager.shared) {
        self.userManager = userManager
        self.statsManager = statsManager
        self.eventManager = eventManager
        self.activityManager = activityManager
        
        loadData()
    }
    
    func loadData() {
        isLoading = true
        
        // Load user data
        userManager.getCurrentUser()
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] (user: AppModels.User) in
                self?.user = user
            }
            .store(in: &cancellables)
        
        // Load today's stats
        statsManager.getTodayStats()
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] (stats: DailyStats) in
                self?.todayStats = stats
            }
            .store(in: &cancellables)
        
        // Load upcoming events
        eventManager.getUpcomingEvents()
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] (events: [Event]) in
                self?.upcomingEvents = events
            }
            .store(in: &cancellables)
        
        // Load recent activities and convert to UI model
        activityManager.getRecentActivities()
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] (activities: [Activity]) in
                self?.recentActivities = activities.map { $0.toHomeActivityItem() }
            }
            .store(in: &cancellables)
            
        // Load upcoming sessions
        loadUpcomingSessions()
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