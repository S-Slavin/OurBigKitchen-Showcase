//
//  AnalyticsService.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//


import Foundation
import SwiftUI

@Observable
public final class AnalyticsService: @unchecked Sendable {
    public static let shared = AnalyticsService()
    
    private(set) var events: [AnalyticsEvent] = []
    
    private init() {}
    
    func trackEvent(_ name: EventName, properties: [String: Any] = [:]) {
        // Convert [String: Any] to [String: String] by converting values to strings
        let stringProperties = properties.mapValues { "\($0)" }
        let event = AnalyticsEvent(name: name.rawValue, properties: stringProperties)
        events.append(event)
        
        // In a real app, you would send this to your analytics service
        print("📊 Analytics Event:", event)
    }
    
    func trackScreen(_ screenName: String) {
        trackEvent(.screenView, properties: ["screen_name": screenName])
    }
    
    func trackImpact(_ impact: Impact) {
        trackEvent(.impactUpdated, properties: [
            "meals_provided": impact.mealsProvided,
            "hours_contributed": impact.hoursContributed,
            "people_helped": impact.peopleHelped
        ])
    }
}

// MARK: - Supporting Types
struct AnalyticsEvent: Sendable {
    let name: String
    let timestamp: Date
    let properties: [String: String]
    
    init(name: String, properties: [String: String] = [:]) {
        self.name = name
        self.timestamp = Date()
        self.properties = properties
    }
}

enum EventName: String, Sendable {
    case screenView = "screen_view"
    case buttonTap = "button_tap"
    case volunteerSignup = "volunteer_signup"
    case impactUpdated = "impact_updated"
    case shareCompleted = "share_completed"
    case errorOccurred = "error_occurred"
}