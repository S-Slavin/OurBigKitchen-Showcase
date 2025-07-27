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
class ContactViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var message = ""
    @Published var subject = ""
    @Published var selectedCategory: ContactService.ContactCategory = .general
    @Published var isLoading = false
    @Published var error: Error?
    @Published var showSuccess = false
    
    private let userManager: UserManager
    private let contactService: ContactService
    private var cancellables = Set<AnyCancellable>()
    
    init(userManager: UserManager? = nil, contactService: ContactService? = nil) {
        self.userManager = userManager ?? UserManager.shared
        self.contactService = contactService ?? ContactService.shared
        loadUserDetails()
    }
    
    private func loadUserDetails() {
        userManager.fetchUserProfile()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error
                }
            }, receiveValue: { [weak self] (user: AppModels.User) in
                self?.name = "\(user.firstName) \(user.lastName)"
                self?.email = user.email
            })
            .store(in: &cancellables)
    }
    
    func sendMessage() {
        guard !message.isEmpty else { return }
        
        isLoading = true
        
        let contact = ContactMessage(
            name: name,
            email: email,
            message: message,
            timestamp: Date()
        )
        
        contactService.sendMessage(contact)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                }
            }, receiveValue: { [weak self] _ in
                self?.showSuccess = true
                self?.message = ""
            })
            .store(in: &cancellables)
    }
    
    // MARK: - Contact Category Methods
    
    var contactURL: URL? {
        switch selectedCategory {
        case .general:
            return URL(string: "https://ourbigkitchen.org/contact")
        case .volunteering:
            return URL(string: "https://ourbigkitchen.org/volunteer")
        case .donations:
            return URL(string: "https://ourbigkitchen.org/donate")
        case .partnerships:
            return URL(string: "https://ourbigkitchen.org/partnerships")
        case .feedback:
            return URL(string: "https://ourbigkitchen.org/feedback")
        case .events:
            return URL(string: "https://ourbigkitchen.org/events")
        }
    }
    
    func contactViaWeb() {
        // This method can be used to track web contact attempts
        print("User attempting to contact via web for category: \(selectedCategory)")
    }
    
    func getCategoryColor(_ category: ContactService.ContactCategory) -> Color {
        switch category {
        case .general:
            return .blue
        case .volunteering:
            return .green
        case .donations:
            return .orange
        case .partnerships:
            return .purple
        case .feedback:
            return .red
        case .events:
            return .yellow
        }
    }
} 