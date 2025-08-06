//
//  ContactViewModel.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//

import Foundation
import Combine
import SwiftUI

class ContactViewModel: ObservableObject {
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
    private let userManager: UserManager
    private var cancellables = Set<AnyCancellable>()
    
    var categories: [ContactService.ContactCategory] {
        ContactService.ContactCategory.allCases
    }
    
    init(contactService: ContactService = .shared,
         userManager: UserManager = .shared) {
        self.contactService = contactService
        self.userManager = userManager
        
        // Try to prefill user information
        loadUserInfo()
    }
    
    // MARK: - Data Loading
    
    func loadUserInfo() {
        userManager.getCurrentUser()
            .sink { _ in
                // Handle error silently - we'll just have empty fields
            } receiveValue: { [weak self] user in
                DispatchQueue.main.async {
                    self?.name = user.fullName
                    self?.email = user.email
                }
            }
            .store(in: &cancellables)
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