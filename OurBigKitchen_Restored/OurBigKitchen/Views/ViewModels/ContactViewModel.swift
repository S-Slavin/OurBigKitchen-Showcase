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
    @Published var isLoading = false
    @Published var error: Error?
    @Published var showSuccess = false
    
    private let userManager: UserManager
    private let contactService: ContactService
    private var cancellables = Set<AnyCancellable>()
    
    init(userManager: UserManager = .shared, contactService: ContactService = .shared) {
        self.userManager = userManager
        self.contactService = contactService
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
        
        let contact = AppModels.ContactMessage(
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
} 