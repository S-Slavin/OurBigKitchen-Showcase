//
//  AnalyticsService.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//


import Foundation

class AnalyticsService: ObservableObject {
    static let shared = AnalyticsService()
    
    @Published private(set) var events: [AnalyticsEvent] = []
    
    private init() {}
    
    func trackEvent(_ name: EventName, properties: [String: Any] = [:]) {
        let event = AnalyticsEvent(name: name, properties: properties)
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
struct AnalyticsEvent {
    let name: EventName
    let properties: [String: Any]
    let timestamp: Date
    
    init(name: EventName, properties: [String: Any] = [:]) {
        self.name = name
        self.properties = properties
        self.timestamp = Date()
    }
}

enum EventName: String {
    case screenView = "screen_view"
    case buttonTap = "button_tap"
    case volunteerSignup = "volunteer_signup"
    case impactUpdated = "impact_updated"
    case shareCompleted = "share_completed"
    case errorOccurred = "error_occurred"
}