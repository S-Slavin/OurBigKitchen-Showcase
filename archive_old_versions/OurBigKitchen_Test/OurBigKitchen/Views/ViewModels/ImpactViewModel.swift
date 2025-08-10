//
//  ImpactViewModel.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//


import Foundation
import Combine
import SwiftUI

class ImpactViewModel: ObservableObject {
    // MARK: - Published Properties
    
    // User inputs
    @Published var selectedTags: Set<String> = []
    @Published var customMessage: String = ""
    @Published var hasSelectedImage: Bool = false
    @Published var selectedImpact: ImpactPost?
    
    // UI state
    @Published var showShareSheet = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    @Published var showAlert = false
    
    // Dynamic data
    @Published var recentImpacts: [ImpactPost] = []
    @Published var userStats: UserImpactStats?
    @Published var upcomingSessions: [UpcomingSession] = []
    
    // Sharing
    @Published var shareItem: ImpactShareSheet?
    
    // Available tags
    let availableTags = [
        "Cooking", "Serving", "Volunteering", "Donations", 
        "Delivery", "Food Rescue", "Community", "Education",
        "Team Building", "Helping Others"
    ]
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    private let impactService: ImpactService
    private let userManager: UserManager
    
    // MARK: - Initialization
    
    init(
        impactService: ImpactService = .shared,
        userManager: UserManager = .shared
    ) {
        self.impactService = impactService
        self.userManager = userManager
        
        loadUserData()
        
        // DEBUG: Force UI to show full sharing interface
        self.hasSelectedImage = true
        
        // Create a test image (red square) for demo purposes
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 200, height: 200))
        let testImage = renderer.image { ctx in
            UIColor.red.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 200, height: 200))
        }
        
        // Create a test impact post with the test image
        if let imageData = testImage.jpegData(compressionQuality: 1.0) {
            let testImpact = ImpactPost(
                id: "test-impact",
                userId: userManager.currentUserId ?? "guest",
                date: Date(),
                tags: ["Testing", "Demo"],
                message: "This is a test impact post",
                imageData: imageData,
                views: 10,
                shares: 5
            )
            
            // Set as selected impact
            self.selectedImpact = testImpact
            self.selectedTags = Set(["Testing", "Demo"])
            self.customMessage = "This is a test impact post"
        }
    }
    
    // MARK: - Public Methods
    
    func toggleTag(_ tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }
    
    func processNewImpactImage(_ image: UIImage) {
        // Create a new impact post
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            showError(title: "Error", message: "Failed to process image")
            return
        }
        
        let newImpact = ImpactPost(
            id: UUID().uuidString,
            userId: userManager.currentUserId ?? "guest",
            date: Date(),
            tags: Array(selectedTags),
            message: customMessage,
            imageData: imageData,
            views: 0,
            shares: 0
        )
        
        // Save the impact post
        impactService.saveImpactPost(newImpact)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.showError(title: "Save Failed", message: error.localizedDescription)
                    }
                },
                receiveValue: { [weak self] success in
                    if success {
                        self?.loadRecentImpacts()
                        self?.selectedImpact = newImpact
                        self?.hasSelectedImage = true
                    } else {
                        self?.showError(title: "Save Failed", message: "Unknown error occurred")
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func selectImpact(_ impact: ImpactPost) {
        selectedImpact = impact
        hasSelectedImage = true
        
        // Update selected tags and message to match the selected impact
        selectedTags = Set(impact.tags)
        customMessage = impact.message
    }
    
    func shareImpact() {
        guard let impact = selectedImpact, let imageData = impact.imageData, let image = UIImage(data: imageData) else {
            showError(title: "Share Failed", message: "No image to share")
            return
        }
        
        // Create a combined image with tags and message
        let renderer = ImageRenderer(
            content: createSharingImage(image: image, tags: impact.tags, message: impact.message)
        )
        
        guard let renderedImage = renderer.uiImage else {
            showError(title: "Share Failed", message: "Could not render sharing image")
            return
        }
        
        // Create share sheet
        shareItem = ImpactShareSheet(items: [renderedImage])
        showShareSheet = true
        
        // Update share count
        impactService.incrementShareCount(for: impact.id)
    }
    
    func shareToSocialMedia(platform: String) {
        guard let impact = selectedImpact else { return }
        
        // Handle each platform differently
        switch platform.lowercased() {
        case "facebook":
            shareToFacebook(impact: impact)
        case "twitter":
            shareToTwitter(impact: impact)
        case "instagram":
            shareToInstagram(impact: impact)
        default:
            shareImpact() // Default to standard share
        }
    }
    
    // MARK: - Private Methods
    
    private func loadUserData() {
        // Load recent impacts
        loadRecentImpacts()
        
        // Load upcoming sessions
        loadUpcomingSessions()
        
        // Create sample user stats for debug
        self.userStats = UserImpactStats(
            totalImpacts: 125,
            totalShares: 45,
            totalViews: 230
        )
        
        // Original stats loading code (commented out for demo)
        /*
        if let userId = userManager.currentUserId {
            impactService.getUserStats(userId: userId)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { [weak self] completion in
                        if case .failure = completion {
                            self?.userStats = UserImpactStats(totalImpacts: 0, totalShares: 0, totalViews: 0)
                        }
                    },
                    receiveValue: { [weak self] stats in
                        self?.userStats = stats
                    }
                )
                .store(in: &cancellables)
        } else {
            // Default stats for guest users
            userStats = UserImpactStats(totalImpacts: 0, totalShares: 0, totalViews: 0)
        }
        */
    }
    
    private func loadRecentImpacts() {
        let userId = userManager.currentUserId ?? "guest"
        
        impactService.getRecentImpactPosts(userId: userId, limit: 10)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.showError(title: "Loading Error", message: error.localizedDescription)
                    }
                },
                receiveValue: { [weak self] impacts in
                    self?.recentImpacts = impacts
                    // If there are impacts and none selected, select the most recent
                    if let firstImpact = impacts.first, self?.selectedImpact == nil {
                        self?.selectImpact(firstImpact)
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    private func loadUpcomingSessions() {
        // In a real app, you would fetch from a server or database
        // For now, just use sample data
        self.upcomingSessions = UpcomingSession.samples
        
        // Example of how to load from network in a real app:
        /* 
        EventManager.shared.getUserEvents(userId: userManager.currentUserId ?? "guest")
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        print("Error loading upcoming sessions: \(error)")
                        // Fall back to sample data
                        self?.upcomingSessions = UpcomingSession.samples
                    }
                },
                receiveValue: { [weak self] events in
                    // Convert events to sessions
                    self?.upcomingSessions = events.map { event in
                        UpcomingSession(
                            id: event.id,
                            title: event.title,
                            date: event.date,
                            location: event.location,
                            duration: event.duration,
                            type: self?.mapEventTypeToSessionType(event.type) ?? .other
                        )
                    }
                }
            )
            .store(in: &cancellables)
        */
    }
    
    // Helper function to map event types to session types
    private func mapEventTypeToSessionType(_ eventType: Event.EventType) -> UpcomingSession.SessionType {
        switch eventType {
        case .cooking:
            return .cooking
        case .distribution:
            return .delivery
        case .training:
            return .volunteering
        case .other:
            return .other
        }
    }
    
    private func createSharingImage(image: UIImage, tags: [String], message: String) -> some View {
        VStack(spacing: 12) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .cornerRadius(12)
            
            if !tags.isEmpty {
                HStack {
                    ForEach(tags.prefix(3), id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                    }
                    if tags.count > 3 {
                        Text("+\(tags.count - 3) more")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            if !message.isEmpty {
                Text(message)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Text("Shared via Our Big Kitchen App")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 5)
    }
    
    private func showError(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
    
    private func shareToFacebook(impact: ImpactPost) {
        // For now, use the standard share sheet
        // A real implementation would use the Facebook SDK
        shareImpact()
    }
    
    private func shareToTwitter(impact: ImpactPost) {
        // For now, use the standard share sheet
        // A real implementation would use the Twitter SDK or API
        shareImpact()
    }
    
    private func shareToInstagram(impact: ImpactPost) {
        // For now, use the standard share sheet
        // A real implementation would use the Instagram SDK or API
        shareImpact()
    }
}

// MARK: - Supporting Types

struct ImpactPost: Identifiable, Equatable {
    let id: String
    let userId: String
    let date: Date
    let tags: [String]
    let message: String
    let imageData: Data?
    var views: Int
    var shares: Int
}

struct UserImpactStats {
    let totalImpacts: Int
    let totalShares: Int
    let totalViews: Int
}

// MARK: - Share Sheet

struct ImpactShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // Nothing to update
    }
}

// MARK: - Image Renderer for iOS 15+

struct ImageRenderer<Content: View> {
    let content: Content
    
    init(content: Content) {
        self.content = content
    }
    
    var uiImage: UIImage? {
        let controller = UIHostingController(rootView: content)
        let view = controller.view
        
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}