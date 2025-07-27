//
//  ImpactViewModel.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//


import Foundation
import Combine
import SwiftUI

@MainActor
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
        impactService: ImpactService? = nil,
        userManager: UserManager? = nil
    ) {
        self.impactService = impactService ?? ImpactService.shared
        self.userManager = userManager ?? UserManager.shared
        
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
                userId: userManager?.currentUserId ?? "guest",
                message: "This is a test impact post",
                date: Date(),
                tags: ["Testing", "Demo"],
                views: 10,
                shares: 5,
                imageData: imageData
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
            userId: userManager?.currentUserId ?? "guest",
            message: customMessage,
            date: Date(),
            tags: Array(selectedTags),
            views: 0,
            shares: 0,
            imageData: imageData
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
        // For demo purposes, create some sample upcoming sessions
        upcomingSessions = [
            UpcomingSession(
                id: UUID(),
                title: "Morning Kitchen Shift",
                date: Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date(),
                location: "Main Kitchen",
                duration: 3600 * 3, // 3 hours
                type: .cooking
            ),
            UpcomingSession(
                id: UUID(),
                title: "Afternoon Delivery Run",
                date: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
                location: "Distribution Center",
                duration: 3600 * 2, // 2 hours
                type: .delivery
            )
        ]
    }
    
    private func showError(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
    
    private func createSharingImage(image: UIImage, tags: [String], message: String) -> some View {
        VStack(spacing: 16) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 300)
            
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            FlowLayout(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    Text("#\(tag)")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.1))
                        )
                }
            }
            .padding(.horizontal)
            
            Text("Shared via Our Big Kitchen")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
    }
    
    private func shareToFacebook(impact: ImpactPost) {
        // TODO: Implement Facebook sharing
        shareImpact()
    }
    
    private func shareToTwitter(impact: ImpactPost) {
        // TODO: Implement Twitter sharing
        shareImpact()
    }
    
    private func shareToInstagram(impact: ImpactPost) {
        // TODO: Implement Instagram sharing
        shareImpact()
    }
}

// MARK: - Supporting Types

struct ImpactShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
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