import Foundation
import Combine
import SwiftUI

// MARK: - Terms Manager

@MainActor
class TermsManager: ObservableObject {
    @Published var hasAcceptedTerms = false
    
    private let mainTermsKey = "hasAcceptedTerms"
    private let legacyKeys = [
        "hasAcceptedTerms",
        "termsAccepted",
        "acceptedTerms"
    ]
    
    private var cancellables = Set<AnyCancellable>()
    private var notificationDebouncer: AnyCancellable?
    
    init() {
        loadTermsStatus()
        
        // Register for UserDefaults changes
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.loadTermsStatus()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    func acceptTerms() {
        hasAcceptedTerms = true
        
        // Update UserDefaults asynchronously
        Task.detached {
            await self.synchronizeKeys(true)
            
            await MainActor.run {
                self.notificationDebouncer?.cancel()
                
                self.notificationDebouncer = Just(())
                    .delay(for: .milliseconds(100), scheduler: RunLoop.main)
                    .sink { _ in
                        NotificationCenter.default.post(name: .didUpdateTerms, object: nil)
                    }
            }
        }
    }
    
    func declineTerms() {
        hasAcceptedTerms = false
        
        Task.detached {
            await self.synchronizeKeys(false)
            
            await MainActor.run {
                NotificationCenter.default.post(name: .didUpdateTerms, object: nil)
            }
        }
    }
    
    func checkTermsStatus() -> Bool {
        loadTermsStatus()
        return hasAcceptedTerms
    }
    
    func resetTerms() {
        hasAcceptedTerms = false
        synchronizeKeys(false)
        NotificationCenter.default.post(name: .didUpdateTerms, object: nil)
    }
    
    // MARK: - Private Methods
    
    private func loadTermsStatus() {
        var accepted = UserDefaults.standard.bool(forKey: mainTermsKey)
        
        // Check legacy keys as fallback
        if !accepted {
            for key in legacyKeys {
                if UserDefaults.standard.bool(forKey: key) {
                    accepted = true
                    break
                }
            }
        }
        
        // Update published property if different
        if accepted != hasAcceptedTerms {
            hasAcceptedTerms = accepted
            
            // Synchronize keys if accepted from legacy key
            if accepted {
                Task.detached {
                    await self.synchronizeKeys(accepted)
                }
            }
        }
    }
    
    private func synchronizeKeys(_ value: Bool) {
        let defaults = UserDefaults.standard
        
        // Update main key
        defaults.set(value, forKey: mainTermsKey)
        
        // Update all legacy keys
        for key in legacyKeys {
            defaults.set(value, forKey: key)
        }
    }
}

// MARK: - Notification Names

// didUpdateTerms is defined in AppState.swift to avoid duplication 