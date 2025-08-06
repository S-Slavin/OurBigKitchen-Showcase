//
//  ContactViewModel.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class ContactViewModel: ObservableObject, @unchecked Sendable {
    // Selected contact category
    @Published var selectedCategory: ContactService.ContactCategory = .general
    
    // User information
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var subject: String = ""
    
    // UI state
    @Published var isLoading: Bool = false
    @Published var showInAppWebView: Bool = false
    @Published var contactURL: URL?
    
    // Service
    private let contactService: ContactService
    private var cancellables = Set<AnyCancellable>()
    
    var categories: [ContactService.ContactCategory] {
        ContactService.ContactCategory.allCases
    }
    
    init(contactService: ContactService = .shared) {
        self.contactService = contactService
        
        // Try to prefill user information from UserDefaults
        loadUserInfo()
    }
    
    // MARK: - Data Loading
    
    func loadUserInfo() {
        // Load user info from UserDefaults since UserManager.getCurrentUser doesn't exist
        if let firstName = UserDefaults.standard.string(forKey: "firstName"),
           let lastName = UserDefaults.standard.string(forKey: "lastName"),
           let email = UserDefaults.standard.string(forKey: "email") {
            self.name = "\(firstName) \(lastName)"
            self.email = email
        }
    }
    
    // MARK: - Actions
    
    func selectCategory(_ category: ContactService.ContactCategory) {
        selectedCategory = category
    }
    
    func contactViaWeb() {
        isLoading = true
        
        // Create URL with user info
        contactURL = contactService.createContactURL(
            category: selectedCategory,
            name: name,
            email: email,
            subject: subject
        )
        
        // Simulate delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isLoading = false
            self?.showInAppWebView = true
        }
    }
    
    func openInBrowser() {
        let url = contactService.createContactURL(
            category: selectedCategory,
            name: name,
            email: email,
            subject: subject
        )
        
        contactService.openContactForm(url: url)
    }
    
    // MARK: - Helper Methods
    
    var isFormValid: Bool {
        return !email.isEmpty && email.contains("@") && !name.isEmpty && !subject.isEmpty
    }
    
    func getCategoryColor(_ category: ContactService.ContactCategory) -> Color {
        switch category {
        case .general:
            return .blue
        case .donations:
            return .red
        case .volunteering:
            return .green
        case .feedback:
            return .orange
        case .events:
            return .purple
        }
    }
    
    func getButtonText() -> String {
        return isLoading ? "Preparing Form..." : "Contact Us"
    }
} 