//
//  ContactService.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//

import Foundation
import SwiftUI
import Combine // Added for AnyPublisher

@MainActor
class ContactService {
    
    // MARK: - Shared Instance
    static let shared = ContactService()
    
    // MARK: - Contact Categories
    
    enum ContactCategory: String, CaseIterable, Identifiable {
        case general = "General"
        case volunteering = "Volunteering"
        case donations = "Donations"
        case feedback = "Feedback"
        case events = "Events"
        
        var id: String { rawValue }
        
        var description: String {
            switch self {
            case .general:
                return "For general questions about Our Big Kitchen and its services."
            case .volunteering:
                return "Interested in volunteering? Get in touch to learn about opportunities to help in the kitchen, delivery, or administration."
            case .donations:
                return "For inquiries related to donations, fundraising, or supporting Our Big Kitchen financially."
            case .feedback:
                return "Share your feedback or suggestions to help us improve our services and community impact."
            case .events:
                return "Questions about upcoming events, bookings, or hosting your own event at Our Big Kitchen."
            }
        }
        
        var iconName: String {
            switch self {
            case .general:
                return "info.circle"
            case .volunteering:
                return "person.3"
            case .donations:
                return "heart"
            case .feedback:
                return "star"
            case .events:
                return "calendar"
            }
        }
    }
    
    // MARK: - Properties
    
    private let baseContactURL = "https://www.ourbigkitchen.org/contact-us/"
    
    // MARK: - Public Methods
    
    func createContactURL(category: ContactCategory, name: String, email: String, subject: String) -> URL? {
        var urlComponents = URLComponents(string: baseContactURL)
        
        // Add query parameters to pre-fill the contact form
        var queryItems = [URLQueryItem]()
        
        // Add category as a subject prefix
        let formattedSubject = "\(category.rawValue) Inquiry: \(subject)"
        
        if !name.isEmpty {
            queryItems.append(URLQueryItem(name: "name", value: name))
        }
        
        if !email.isEmpty {
            queryItems.append(URLQueryItem(name: "email", value: email))
        }
        
        if !formattedSubject.isEmpty {
            queryItems.append(URLQueryItem(name: "subject", value: formattedSubject))
        }
        
        // Add category as a hidden field if the form supports it
        queryItems.append(URLQueryItem(name: "category", value: category.rawValue))
        
        urlComponents?.queryItems = queryItems
        
        return urlComponents?.url
    }
    
    func openContactForm(url: URL?) {
        guard let url = url else { return }
        UIApplication.shared.open(url)
    }
    
    // Maintain backward compatibility with existing code
    func getContactURL(category: ContactCategory, name: String, email: String, subject: String) -> URL? {
        return createContactURL(category: category, name: name, email: email, subject: subject)
    }
    
    func getCategoryColor(_ category: ContactCategory) -> Color {
        switch category {
        case .general:
            return .blue
        case .volunteering:
            return .green
        case .donations:
            return .red
        case .feedback:
            return .orange
        case .events:
            return .purple
        }
    }
    
    // MARK: - Message Sending
    
    func sendMessage(_ message: ContactMessage) -> AnyPublisher<Void, Error> {
        // In a real app, this would send the message to a backend service
        // For now, we'll simulate a successful send
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
} 