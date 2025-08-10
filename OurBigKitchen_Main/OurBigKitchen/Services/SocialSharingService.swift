//
//  SocialSharingService.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//


import Foundation
import UIKit

// MARK: - Models

enum SocialShare {
    case impact(Impact)
    case event(Event)
    case achievement(AppModels.UserAchievement)
    case impactWithImage(Impact, UIImage)
    
    var timestamp: Date {
        Date()
    }
}

@MainActor
class SocialSharingService: ObservableObject {
    static let shared = SocialSharingService()
    
    @Published var lastSharedItem: SocialShare?
    @Published var isSharing = false
    
    private init() {}
    
    // New methods to match what the ViewModel expects
    func prepareStandardImpactShare(impact: Impact) {
        shareImpact(impact)
    }
    
    func prepareFilteredImpactShare(impact: Impact, image: UIImage?) {
        if let image = image {
            shareImpactWithImage(impact, image: image)
        } else {
            shareImpact(impact)
        }
    }
    
    func shareToPlatform(platform: SocialSharingViewModel.SocialPlatform, impact: Impact) {
        let message = formatImpactMessage(impact)
        
        switch platform {
        case .linkedin:
            shareToLinkedIn(message: message)
        case .facebook:
            shareToFacebook(message: message)
        case .twitter:
            shareToTwitter(message: message)
        case .instagram:
            // Instagram doesn't support direct text sharing via URL scheme
            // Use the standard sharing mechanism instead
            shareImpact(impact)
        case .all:
            shareImpact(impact)
        }
    }
    
    func shareImpact(_ impact: Impact) {
        let message = formatImpactMessage(impact)
        share(message: message)
        lastSharedItem = .impact(impact)
    }
    
    func shareImpactWithImage(_ impact: Impact, image: UIImage) {
        let message = formatImpactMessage(impact)
        share(message: message, image: image)
        lastSharedItem = .impactWithImage(impact, image)
    }
    
    func shareEvent(_ event: Event) {
        let message = formatEventMessage(event)
        share(message: message)
        lastSharedItem = .event(event)
    }
    
    private func formatImpactMessage(_ impact: Impact) -> String {
        var message = """
        🌟 Let's Build a Kinder World Together! 🌟
        
        My Impact at Our Big Kitchen:
        🍽 \(impact.mealsProvided) meals provided
        ⏰ \(impact.hoursContributed) hours contributed
        💝 \(impact.peopleHelped) people helped
        """
        
        if let mealsMade = impact.mealsMade, let _ = impact.timeSpent {
            message += "\n👩‍🍳 \(mealsMade) meals made"
            message += "\n🌱 \(String(format: "%.1f", impact.foodWasteSaved)) kg food waste saved"
        }
        
        message += "\n♻️ \(String(format: "%.1f", impact.carbonSaved)) kg of CO2 saved"
        message += "\n\nJoin me in making a difference! Together we can create positive change in our community."
        message += "\n#OurBigKitchen #BuildingAKinderWorld #Community"
        
        return message
    }
    
    private func formatEventMessage(_ event: Event) -> String {
        """
        🌟 Let's Build a Kinder World Together! 🌟
        
        I'm joining \(event.title) at Our Big Kitchen!
        📍 \(event.location)
        📅 \(event.date.formatted())
        
        Every act of kindness matters. Come volunteer with me and be part of the change!
        #OurBigKitchen #BuildingAKinderWorld #Volunteering
        """
    }
    
    private func formatAchievementMessage(_ achievement: AppModels.UserAchievement) -> String {
        """
        🌟 Together, We Are Building a Kinder World! 🌟
        
        Proud to earn the \(achievement.title) badge at Our Big Kitchen!
        
        🏆 \(achievement.description)
        
        Every action creates ripples of kindness. Join this movement and be the change!
        #OurBigKitchen #BuildingAKinderWorld #BeTheChange
        """
    }
    
    func shareAchievement(_ achievement: AppModels.UserAchievement) {
        let message = formatAchievementMessage(achievement)
        share(message: message)
        lastSharedItem = .achievement(achievement)
    }
    
    private func share(message: String) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootVC = window.rootViewController else {
            return
        }
        
        let activityVC = UIActivityViewController(
            activityItems: [message],
            applicationActivities: nil
        )
        
        if let popoverController = activityVC.popoverPresentationController {
            popoverController.sourceView = window
            popoverController.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        rootVC.present(activityVC, animated: true)
    }
    
    private func share(message: String, image: UIImage) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootVC = window.rootViewController else {
            return
        }
        
        let activityVC = UIActivityViewController(
            activityItems: [message, image],
            applicationActivities: nil
        )
        
        if let popoverController = activityVC.popoverPresentationController {
            popoverController.sourceView = window
            popoverController.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        rootVC.present(activityVC, animated: true)
    }
    
    // MARK: - Platform-Specific Sharing
    
    func shareToLinkedIn(message: String, url: URL? = nil) {
        let defaultUrl = URL(string: "https://ourbigkitchen.org") ?? URL(string: "https://ourbigkitchen.org")!
        let targetUrl = url ?? defaultUrl
        
        guard let encodedText = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedUrl = targetUrl.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        
        let linkedInUrl = URL(string: "https://www.linkedin.com/sharing/share-offsite/?url=\(encodedUrl)&summary=\(encodedText)")
        
        if let url = linkedInUrl {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func shareToFacebook(message: String, url: URL? = nil) {
        let defaultUrl = URL(string: "https://ourbigkitchen.org") ?? URL(string: "https://ourbigkitchen.org")!
        let targetUrl = url ?? defaultUrl
        
        guard let encodedText = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedUrl = targetUrl.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        
        let facebookUrl = URL(string: "https://www.facebook.com/sharer/sharer.php?u=\(encodedUrl)&quote=\(encodedText)")
        
        if let url = facebookUrl {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func shareToTwitter(message: String, url: URL? = nil) {
        let defaultUrl = URL(string: "https://ourbigkitchen.org") ?? URL(string: "https://ourbigkitchen.org")!
        let targetUrl = url ?? defaultUrl
        
        guard let encodedText = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedUrl = targetUrl.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        
        let twitterUrl = URL(string: "https://twitter.com/intent/tweet?text=\(encodedText)&url=\(encodedUrl)")
        
        if let url = twitterUrl {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    // Platform detection helpers
    
    func isLinkedInInstalled() -> Bool {
        guard let linkedInUrl = URL(string: "linkedin://") else { return false }
        return UIApplication.shared.canOpenURL(linkedInUrl)
    }
    
    func isFacebookInstalled() -> Bool {
        guard let facebookUrl = URL(string: "fb://") else { return false }
        return UIApplication.shared.canOpenURL(facebookUrl)
    }
    
    func isTwitterInstalled() -> Bool {
        guard let twitterUrl = URL(string: "twitter://") else { return false }
        return UIApplication.shared.canOpenURL(twitterUrl)
    }
}