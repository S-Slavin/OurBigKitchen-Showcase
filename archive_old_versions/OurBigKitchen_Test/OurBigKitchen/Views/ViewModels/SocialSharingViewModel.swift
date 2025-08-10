//
//  SocialSharingViewModel.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//

import Foundation
import Combine
import SwiftUI
import UIKit  // For UIActivityViewController

// MARK: - SocialSharingViewModel
@MainActor
class SocialSharingViewModel: ObservableObject {
    @Published var userImpact: Impact?
    @Published var selectedEvent: Event?
    @Published var customMessage: String = ""
    @Published var includePhoto: Bool = true
    @Published var includeStats: Bool = true
    @Published var selectedPlatforms: Set<SocialPlatform> = [.all]
    @Published var isSharing: Bool = false
    @Published var showShareSuccess: Bool = false
    @Published var error: Error?
    @Published var showingFilterSheet: Bool = false
    @Published var filteredImpactImage: UIImage?
    @Published var mealsMadeString: String = ""
    @Published var timeSpentString: String = ""
    @Published var canSaveContribution: Bool = false
    @Published var selectedPlatform: SocialPlatform?
    
    // Added computed property for platforms
    var platforms: [SocialPlatform] {
        return SocialPlatform.allCases
    }
    
    // New properties for the redesigned sharing view
    @Published var selectedCardStyle: Int = 0
    @Published var selectedStoryBackground: Int = 0
    
    // Social platforms
    enum SocialPlatform: String, CaseIterable, Identifiable {
        case all = "All Platforms"
        case facebook = "Facebook"
        case twitter = "Twitter"
        case instagram = "Instagram"
        case linkedin = "LinkedIn"
        
        var id: String { rawValue }
        
        var iconName: String {
            switch self {
            case .all: return "arrow.up.forward.app"
            case .facebook: return "f.square"
            case .twitter: return "t.square"
            case .instagram: return "camera"
            case .linkedin: return "l.square"
            }
        }
        
        var color: Color {
            switch self {
            case .all: return .blue
            case .facebook: return Color(red: 0.23, green: 0.35, blue: 0.6)
            case .twitter: return Color(red: 0.11, green: 0.63, blue: 0.95)
            case .instagram: return Color(red: 0.8, green: 0.22, blue: 0.4)
            case .linkedin: return Color(red: 0.0, green: 0.47, blue: 0.71)
            }
        }
    }
    
    // Preset message templates
    let messageTemplates = [
        "I just volunteered at Our Big Kitchen and helped make meals for those in need! #OurBigKitchen #Community",
        "Making a difference one meal at a time with Our Big Kitchen. So rewarding to give back to our community!",
        "Proud to be part of the OBK team today, helping to feed our community. Join us next time!",
        "Food brings everyone together. Loved my time at Our Big Kitchen today!"
    ]
    
    private let socialSharingService: SocialSharingService
    private let imageRenderingService: ImageRenderingService
    private var cancellables = Set<AnyCancellable>()
    
    init(
        socialSharingService: SocialSharingService,
        imageRenderingService: ImageRenderingService
    ) {
        // Fix for Swift 6 compatibility: use MainActor.run for isolated property access
        let _socialSharingService: SocialSharingService
        let _imageRenderingService: ImageRenderingService
        
        // Access shared instances on the main actor
        if #available(iOS 16.0, *) {
            _socialSharingService = MainActor.assumeIsolated { socialSharingService }
            _imageRenderingService = MainActor.assumeIsolated { imageRenderingService }
        } else {
            // For older iOS versions
            _socialSharingService = socialSharingService
            _imageRenderingService = imageRenderingService
        }
        
        self.socialSharingService = _socialSharingService
        self.imageRenderingService = _imageRenderingService
        
        loadUserImpact()
        setupObservers()
    }
    
    convenience init() {
        if #available(iOS 16.0, *) {
            let socialService = MainActor.assumeIsolated { SocialSharingService.shared }
            let imageService = MainActor.assumeIsolated { ImageRenderingService.shared }
            self.init(socialSharingService: socialService, imageRenderingService: imageService)
        } else {
            self.init(socialSharingService: SocialSharingService.shared, imageRenderingService: ImageRenderingService.shared)
        }
    }
    
    // MARK: - Data Loading
    
    func loadUserImpact() {
        // In a real app, this would fetch actual user impact data
        // For now, using mock data
        let mockImpact = Impact(
            mealsProvided: 125,
            hoursContributed: 12,
            peopleHelped: 200,
            eventsAttended: 3,
            mealsMade: 60,
            timeSpent: 12
        )
        self.userImpact = mockImpact
        self.mealsMadeString = String(mockImpact.mealsMade ?? 0)
        self.timeSpentString = String(mockImpact.timeSpent ?? 0)
    }
    
    // MARK: - Sharing Logic
    
    func selectTemplate(_ template: String) {
        customMessage = template
    }
    
    func togglePlatform(_ platform: SocialPlatform) {
        if platform == .all {
            selectedPlatforms = [.all]
        } else {
            // Remove .all if it exists
            selectedPlatforms.remove(.all)
            
            // Toggle the selected platform
            if selectedPlatforms.contains(platform) {
                selectedPlatforms.remove(platform)
            } else {
                selectedPlatforms.insert(platform)
            }
            
            // If empty, add .all
            if selectedPlatforms.isEmpty {
                selectedPlatforms = [.all]
            }
        }
    }
    
    func shareImpact() {
        guard userImpact != nil else { return }
        
        // Show the filter view before sharing
        showingFilterSheet = true
    }
    
    func shareToPlatforms() {
        guard let impact = userImpact else { return }
        isSharing = true
        
        // Use GCD to make it async
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // For each platform selected
            for platform in self.selectedPlatforms {
                if platform == .all { continue }
                
                // Use the appropriate sharing method from SocialSharingService
                self.socialSharingService.shareToPlatform(platform: platform, impact: impact)
            }
            
            // Show success message
            self.isSharing = false
            self.showShareSuccess = true
            
            // Hide success message after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.showShareSuccess = false
            }
        }
    }
    
    func shareFilteredImpact(with image: UIImage?) {
        guard let _ = userImpact else { return }
        
        isSharing = true
        
        // Store the filtered image
        self.filteredImpactImage = image
        
        Task {
            if let filteredImage = filteredImpactImage {
                // Share both text and image
                socialSharingService.shareImpactWithImage(userImpact!, image: filteredImage)
            } else {
                // Fall back to text-only sharing
                socialSharingService.shareImpact(userImpact!)
            }
            
            // Track analytics
            // analyticsManager.trackEvent("impact_shared")
            
            // Simulate sharing process
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            self.isSharing = false
            self.showShareSuccess = true
            
            // Auto hide success message
            try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
            self.showShareSuccess = false
        }
    }
    
    func shareEvent() {
        guard let event = selectedEvent else { return }
        
        isSharing = true
        
        Task {
            socialSharingService.shareEvent(event)
            
            // Track analytics
            // analyticsManager.trackEvent("event_shared")
            
            // Simulate sharing process
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            self.isSharing = false
            self.showShareSuccess = true
            
            // Auto hide success message
            try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
            self.showShareSuccess = false
        }
    }
    
    func shareCustom() {
        isSharing = true
        
        let messageToShare = customMessage.isEmpty 
            ? "I'm making a difference with Our Big Kitchen! #OurBigKitchen #Community" 
            : customMessage
        
        Task {
            // Determine which specific platforms to share to
            let platformsToShare = selectedPlatforms.contains(.all) 
                ? SocialPlatform.allCases.filter { $0 != .all }
                : Array(selectedPlatforms)
            
            // Include filtered image if available
            if includePhoto, let filteredImage = filteredImpactImage {
                // For each selected platform, attempt platform-specific sharing
                for platform in platformsToShare {
                    shareToSpecificPlatform(platform: platform, message: messageToShare, image: filteredImage)
                }
            } else {
                // Text-only sharing
                for platform in platformsToShare {
                    shareToSpecificPlatform(platform: platform, message: messageToShare, image: nil)
                }
            }
            
            // Simulate sharing process
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            self.isSharing = false
            self.showShareSuccess = true
            
            // Auto hide success message
            try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
            self.showShareSuccess = false
        }
    }
    
    private func shareToSpecificPlatform(platform: SocialPlatform, message: String, image: UIImage?) {
        switch platform {
        case .linkedin:
            // Use LinkedIn-specific sharing if possible
            socialSharingService.shareToLinkedIn(message: message)
            
        case .facebook:
            // Use Facebook-specific sharing if possible
            socialSharingService.shareToFacebook(message: message)
            
        case .twitter:
            // Use Twitter-specific sharing if possible
            socialSharingService.shareToTwitter(message: message)
            
        case .instagram:
            // Instagram doesn't support direct URL sharing, so we'll use the default activity view
            fallbackToGenericSharing(message: message, image: image)
            
        case .all:
            // Should never happen as we filter this out
            fallbackToGenericSharing(message: message, image: image)
        }
    }
    
    private func fallbackToGenericSharing(message: String, image: UIImage?) {
        if let image = image {
            shareTextWithImage(message, image: image)
        } else {
            shareText(message)
        }
    }
    
    private func shareText(_ text: String) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootVC = window.rootViewController else {
            return
        }
        
        let activityVC = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        
        if let popoverController = activityVC.popoverPresentationController {
            popoverController.sourceView = window
            popoverController.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        rootVC.present(activityVC, animated: true)
    }
    
    private func shareTextWithImage(_ text: String, image: UIImage) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootVC = window.rootViewController else {
            return
        }
        
        let activityVC = UIActivityViewController(
            activityItems: [text, image],
            applicationActivities: nil
        )
        
        if let popoverController = activityVC.popoverPresentationController {
            popoverController.sourceView = window
            popoverController.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        rootVC.present(activityVC, animated: true)
    }
    
    // MARK: - User Contribution
    
    func saveUserContribution() {
        guard let mealsMade = Int(mealsMadeString),
              let timeSpent = Double(timeSpentString) else {
            return
        }
        
        // Update the impact model
        let impact = Impact(
            mealsProvided: userImpact?.mealsProvided ?? 0,
            hoursContributed: userImpact?.hoursContributed ?? 0,
            peopleHelped: userImpact?.peopleHelped ?? 0,
            eventsAttended: userImpact?.eventsAttended ?? 0,
            mealsMade: mealsMade,
            timeSpent: Int(timeSpent)
        )
        
        self.userImpact = impact
    }
    
    // MARK: - Validation
    
    private func validateContribution() {
        let isMealsMadeValid = Int(mealsMadeString) != nil
        let isTimeSpentValid = Double(timeSpentString) != nil
        canSaveContribution = isMealsMadeValid && isTimeSpentValid
    }
    
    // MARK: - Observers
    
    private func setupObservers() {
        socialSharingService.$isSharing
            .receive(on: RunLoop.main)
            .sink { [weak self] isSharing in
                self?.isSharing = isSharing
            }
            .store(in: &cancellables)
        
        // Observe changes to input fields for validation
        $mealsMadeString
            .sink { [weak self] _ in
                self?.validateContribution()
            }
            .store(in: &cancellables)
        
        $timeSpentString
            .sink { [weak self] _ in
                self?.validateContribution()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Helper Methods
    
    func getShareButtonText() -> String {
        if isSharing {
            return "Sharing..."
        } else {
            return "Share Now"
        }
    }
} 