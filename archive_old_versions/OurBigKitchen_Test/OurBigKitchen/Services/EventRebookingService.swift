//
//  EventRebookingService.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//

import Foundation
import SwiftUI

class EventRebookingService: ObservableObject {
    static let shared = EventRebookingService()
    
    // Base URLs for different booking types
    private let teamBuildingURL = "https://ourbigkitchen.com/corporate/team-building"
    private let privateEventURL = "https://ourbigkitchen.com/corporate/private-events"
    private let charityEventURL = "https://ourbigkitchen.com/corporate/charity-events"
    private let workshopURL = "https://ourbigkitchen.com/corporate/workshops"
    
    struct BookingOption: Identifiable {
        let id = UUID()
        let title: String
        let description: String
        let imageName: String
        let url: URL
        
        var urlString: String {
            return url.absoluteString
        }
    }
    
    // Available booking options
    lazy var bookingOptions: [BookingOption] = [
        BookingOption(
            title: "Team Building",
            description: "Cook and bond with your team while making a difference.",
            imageName: "person.3.fill",
            url: URL(string: teamBuildingURL)!
        ),
        BookingOption(
            title: "Private Events",
            description: "Host your next corporate event in our kitchen spaces.",
            imageName: "building.2.fill",
            url: URL(string: privateEventURL)!
        ),
        BookingOption(
            title: "Charity Events",
            description: "Make meals for a cause with your corporate group.",
            imageName: "heart.fill",
            url: URL(string: charityEventURL)!
        ),
        BookingOption(
            title: "Workshops",
            description: "Learn new culinary skills while giving back.",
            imageName: "book.fill",
            url: URL(string: workshopURL)!
        )
    ]
    
    // Open URL in Safari or in-app browser
    func openBookingURL(_ url: URL) {
        UIApplication.shared.open(url)
    }
    
    // Create custom URL with parameters
    func createCustomBookingURL(type: String, groupSize: Int, preferredDate: Date? = nil) -> URL? {
        var components = URLComponents(string: getBaseURL(for: type))
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "source", value: "app"),
            URLQueryItem(name: "group_size", value: "\(groupSize)")
        ]
        
        if let date = preferredDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            queryItems.append(URLQueryItem(name: "preferred_date", value: formatter.string(from: date)))
        }
        
        components?.queryItems = queryItems
        return components?.url
    }
    
    // Get base URL based on event type
    private func getBaseURL(for type: String) -> String {
        switch type.lowercased() {
        case "team", "team building", "teambuilding":
            return teamBuildingURL
        case "private", "private event", "private events":
            return privateEventURL
        case "charity", "charity event", "charity events":
            return charityEventURL
        case "workshop", "workshops":
            return workshopURL
        default:
            return teamBuildingURL
        }
    }
} 