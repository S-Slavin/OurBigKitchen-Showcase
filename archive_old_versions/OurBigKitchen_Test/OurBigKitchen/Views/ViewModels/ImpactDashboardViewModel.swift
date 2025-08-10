import Foundation
import Combine
import SwiftUI
import UIKit

@MainActor
class ImpactDashboardViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var impactMetrics: [AppModels.ImpactMetric] = []
    @Published var dailyStats: [DailyStats] = []
    @Published var userImpact: Impact?
    @Published var isLoading = false
    @Published var error: Error?
    @Published var showError = false
    @Published var selectedTimeRange: TimeRange = .week
    @Published var showingFilterSheet = false
    @Published var showShareSheet = false
    @Published var shareItem: UIActivityViewController?
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    @Published var showAlert = false
    @Published var hasSelectedImage = false
    @Published var selectedTags: [String] = []
    @Published var customMessage: String = ""
    
    // User authentication and input
    @Published var isUserSignedIn = false
    @Published var userName = "Guest"
    
    // Input fields for impact calculation
    @Published var mealsMadeString: String = ""
    @Published var timeSpentString: String = ""
    
    // Available tags for impact photos
    var availableTags = [
        "Meal Prep", "Volunteer", "Community", "Food Rescue", "Donation", 
        "Charity", "Team Building", "Kitchen", "Food Bank", "Outreach"
    ]
    
    // MARK: - Time Range
    
    enum TimeRange: String, CaseIterable {
        case week = "This Week"
        case month = "This Month"
        case year = "This Year"
        case all = "All Time"
    }
    
    // MARK: - Dependencies
    
    private var cancellables = Set<AnyCancellable>()
    private let statsManager: StatsManager
    private let userManager: UserManager
    private let socialSharingService: SocialSharingService
    
    // MARK: - Computed Properties
    
    var totalMealsServed: Int {
        dailyStats.reduce(0) { $0 + $1.mealsServed }
    }
    
    var totalVolunteers: Int {
        dailyStats.reduce(0) { $0 + $1.volunteersPresent }
    }
    
    var totalHoursVolunteered: Double {
        dailyStats.reduce(0.0) { $0 + $1.hoursContributed }
    }
    
    var totalPeopleServed: Int {
        dailyStats.reduce(0) { $0 + $1.peopleServed }
    }
    
    var totalFoodWasteSaved: Double {
        dailyStats.reduce(0.0) { $0 + $1.foodWasteSaved }
    }
    
    var canSaveContribution: Bool {
        isUserSignedIn && 
        UserDefaults.standard.bool(forKey: "hasAcceptedTerms") && 
        (Int(mealsMadeString) != nil || Int(timeSpentString) != nil)
    }
    
    // MARK: - Initialization
    
    init(
        statsManager: StatsManager = .shared,
        userManager: UserManager = .shared,
        socialSharingService: SocialSharingService
    ) {
        self.statsManager = statsManager
        self.userManager = userManager
        self.socialSharingService = socialSharingService
        
        // Initialize with empty values
        loadData()
        setupObservers()
        checkAuthenticationStatus()
    }
    
    @MainActor
    convenience init() {
        if #available(iOS 16.0, *) {
            let socialService = MainActor.assumeIsolated { SocialSharingService.shared }
            self.init(socialSharingService: socialService)
        } else {
            self.init(socialSharingService: SocialSharingService.shared)
        }
    }
    
    // MARK: - Data Loading
    
    func loadData() {
        isLoading = true
        error = nil
        
        // Load impact metrics
        loadImpactMetrics()
        
        // Load daily stats based on selected time range
        loadDailyStats()
        
        // Load user impact data
        loadUserImpact()
    }
    
    private func loadImpactMetrics() {
        statsManager.getImpactMetrics()
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.handleError(error)
                }
            } receiveValue: { [weak self] metrics in
                self?.impactMetrics = metrics
            }
            .store(in: &cancellables)
    }
    
    private func loadDailyStats() {
        let timeFrame: StatsTimeframe
        
        switch selectedTimeRange {
        case .week:
            timeFrame = .week
        case .month:
            timeFrame = .month
        case .year:
            timeFrame = .year
        case .all:
            timeFrame = .allTime
        }
        
        statsManager.getDailyStats(for: timeFrame)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.handleError(error)
                }
            } receiveValue: { [weak self] stats in
                self?.dailyStats = stats
                self?.isLoading = false
            }
            .store(in: &cancellables)
    }
    
    private func loadUserImpact() {
        if isUserSignedIn {
            statsManager.getUserImpact()
                .receive(on: RunLoop.main)
                .sink { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                } receiveValue: { [weak self] impact in
                    self?.userImpact = impact
                }
                .store(in: &cancellables)
        } else {
            // Create a default, empty impact for users not signed in
            userImpact = Impact(id: UUID().uuidString, userId: "", timeSpent: 0, mealsMade: 0)
        }
    }
    
    private func handleError(_ error: Error) {
        self.error = error
        self.showError = true
        self.isLoading = false
    }
    
    func refreshData() {
        loadData()
    }
    
    // Using async/await for pull-to-refresh
    func refreshDataAsync() async {
        isLoading = true
        loadData()
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000)
        isLoading = false
    }
    
    // MARK: - Social Media Sharing
    
    func shareImpact() {
        guard let impact = userImpact else { return }
        socialSharingService.prepareStandardImpactShare(impact: impact)
    }
    
    func shareFilteredImpact(with image: UIImage?) {
        guard let impact = userImpact else { return }
        socialSharingService.prepareFilteredImpactShare(impact: impact, image: image)
    }
    
    func shareToSocialMedia(_ platform: SocialSharingViewModel.SocialPlatform) {
        guard let impact = userImpact else { return }
        socialSharingService.shareToPlatform(platform: platform, impact: impact)
    }
    
    // MARK: - Authentication
    
    private func setupObservers() {
        // In a real app, this would observe authentication state changes
        NotificationCenter.default.publisher(for: .didUpdateUser)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.checkAuthenticationStatus()
                self?.loadUserImpact()
            }
            .store(in: &cancellables)
    }
    
    private func checkAuthenticationStatus() {
        // In a real app, this would check the user's authentication state
        // Mock implementation for now
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isUserLoggedIn")
        if isLoggedIn {
            isUserSignedIn = true
            userName = UserDefaults.standard.string(forKey: "userName") ?? "User"
        }
    }
    
    func signOut() {
        isUserSignedIn = false
        userName = "Guest"
        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
        UserDefaults.standard.removeObject(forKey: "userName")
    }
    
    // MARK: - User Input Processing
    
    func updateMealsMade(_ newValue: String) {
        mealsMadeString = newValue
        
        // Update impact with new value
        if let mealsMade = Int(newValue), var updatedImpact = userImpact {
            updatedImpact.mealsMade = mealsMade
            userImpact = updatedImpact
        }
    }
    
    func updateTimeSpent(_ newValue: String) {
        timeSpentString = newValue
        
        // Update impact with new value
        if let timeSpent = Int(newValue), var updatedImpact = userImpact {
            updatedImpact.timeSpent = timeSpent
            userImpact = updatedImpact
        }
    }
    
    func saveUserContribution() {
        guard canSaveContribution else { return }
        
        // In a real app, this would save to a database
        // For now, just show a success message
        
        // Clear the input fields
        mealsMadeString = ""
        timeSpentString = ""
        
        // Refresh data to show updated stats
        refreshData()
    }
    
    // MARK: - Helper Methods
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    // MARK: - Image Handling
    
    // Process a new image taken or selected for impact sharing
    func processNewImpactImage(_ image: UIImage) {
        // Create a new impact record with the image
        let newImpact = createImpactWithImage(image)
        
        // Update the state
        self.userImpact = newImpact
        self.hasSelectedImage = true
        
        // Reset tags and message
        self.selectedTags = []
        self.customMessage = ""
        
        // Show success alert
        self.alertTitle = "Image Captured"
        self.alertMessage = "Your impact photo has been captured. Add tags and share it with the community!"
        self.showAlert = true
    }
    
    private func createImpactWithImage(_ image: UIImage) -> Impact {
        // Resize the image to reduce memory usage
        let resizedImage = resizeImage(image, targetSize: CGSize(width: 1200, height: 1200))
        
        // Convert to data
        guard let imageData = resizedImage.jpegData(compressionQuality: 0.7) else {
            // If conversion fails, return existing impact or create a new one
            return userImpact ?? Impact(id: UUID().uuidString, userId: "", timeSpent: 0, mealsMade: 0)
        }
        
        // Create a new impact or update existing one
        var impact = userImpact ?? Impact(id: UUID().uuidString, userId: "", timeSpent: 0, mealsMade: 0)
        impact.imageData = imageData
        
        return impact
    }
    
    private func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? image
    }
    
    // Toggle a tag selection
    func toggleTag(_ tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.removeAll { $0 == tag }
        } else {
            selectedTags.append(tag)
        }
    }
} 