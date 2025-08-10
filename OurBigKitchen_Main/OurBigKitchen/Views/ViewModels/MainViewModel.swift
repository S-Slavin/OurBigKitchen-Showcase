//
//  MainViewModel.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//


import Foundation
import SwiftUI
import Combine

@MainActor
final class MainViewModel: ObservableObject {
    @Published var selectedTab = 0
    @Published var isAuthenticated = false
    @Published var showingOnboarding = true
    @Published var error: Error?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        // Add authentication state observation
        AuthManager.shared.$isAuthenticated
            .assign(to: \.isAuthenticated, on: self)
            .store(in: &cancellables)
    }
    
    func signOut() {
        AuthManager.shared.logout()
    }
}