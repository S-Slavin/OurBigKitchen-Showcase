import Foundation
import Combine
import SwiftUI

class TermsManager: ObservableObject, @unchecked Sendable {
    static let shared = TermsManager()
    
    // Support multiple keys for terms acceptance
    private let mainTermsKey = "OBK_termsAccepted"
    private let legacyKeys = ["hasAcceptedTerms", "termsAccepted"]
    
    @Published var hasAcceptedTerms: Bool = false
    
    // Add debouncer for notifications
    private var notificationDebouncer: AnyCancellable?
    
    private init() {
        // Load terms acceptance status from UserDefaults during initialization
        loadTermsStatus()
        
        print("DEBUG: TermsManager initialized. hasAcceptedTerms: \(hasAcceptedTerms)")
        
        // Register for UserDefaults changes - use the Combine publisher pattern
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.loadTermsStatus()
            }
            .store(in: &cancellables)
    }
    
    // Store cancellables
    private var cancellables = Set<AnyCancellable>()
    
    // Centralized function to load terms status from UserDefaults
    private func loadTermsStatus() {
        // Get terms acceptance status from main key
        var accepted = UserDefaults.standard.bool(forKey: mainTermsKey)
        
        // If not accepted via main key, check legacy keys as fallback
        if !accepted {
            for key in legacyKeys {
                if UserDefaults.standard.bool(forKey: key) {
                    accepted = true
                    break
                }
            }
        }
        
        // Only update property if value is different
        if accepted != hasAcceptedTerms {
            print("DEBUG: Updating hasAcceptedTerms from \(hasAcceptedTerms) to \(accepted)")
            hasAcceptedTerms = accepted
            
            // If accepted from legacy key, synchronize to main key
            if accepted {
                // Use asynchronous write to avoid blocking the main thread
                Task { @MainActor in
                    self.synchronizeKeys(accepted)
                }
            }
        }
    }
    
    // Make sure all UserDefaults keys have the same value
    private func synchronizeKeys(_ value: Bool) {
        let defaults = UserDefaults.standard
        
        // Update main key
        defaults.set(value, forKey: mainTermsKey)
        
        // Update all legacy keys
        for key in legacyKeys {
            defaults.set(value, forKey: key)
        }
        
        // No need to call synchronize - it's deprecated and can cause freezing
    }
    
    func acceptTerms() {
        print("DEBUG: Accepting terms, current value: \(hasAcceptedTerms)")
        
        // Update local property immediately
        hasAcceptedTerms = true
        
        // Perform UserDefaults operations asynchronously
        Task { @MainActor in
            // Update UserDefaults keys
            self.synchronizeKeys(true)
            
            // Cancel any pending notifications
            self.notificationDebouncer?.cancel()
            
            // Send notification with debouncing to prevent rapid consecutive calls
            self.notificationDebouncer = Just(())
                .delay(for: .milliseconds(50), scheduler: RunLoop.main)
                .sink { _ in
                    NotificationCenter.default.post(name: .didUpdateTerms, object: nil)
                }
        }
    }
    
    func checkTermsStatus() -> Bool {
        // Load latest status
        loadTermsStatus()
        return hasAcceptedTerms
    }
    
    func resetTerms() {
        print("DEBUG: Resetting terms acceptance")
        
        // Update local property immediately
        hasAcceptedTerms = false
        
        // Perform UserDefaults operations asynchronously
        Task { @MainActor in
            // Update UserDefaults keys
            self.synchronizeKeys(false)
            
            // Cancel any pending notifications
            self.notificationDebouncer?.cancel()
            
            // Send notification with debouncing
            self.notificationDebouncer = Just(())
                .delay(for: .milliseconds(50), scheduler: RunLoop.main)
                .sink { _ in
                    NotificationCenter.default.post(name: .didUpdateTerms, object: nil)
                }
        }
    }
    
    // For testing: Reset all terms-related values in UserDefaults
    func resetAllTermsSettings() {
        print("DEBUG: Resetting all terms-related settings")
        
        // Update instance state immediately
        hasAcceptedTerms = false
        
        // Perform UserDefaults operations asynchronously
        Task { @MainActor in
            let defaults = UserDefaults.standard
            
            // Clear main key
            defaults.removeObject(forKey: self.mainTermsKey)
            
            // Clear all legacy keys
            for key in self.legacyKeys {
                defaults.removeObject(forKey: key)
            }
            
            // Also clear completion key
            defaults.removeObject(forKey: "com.ourbigkitchen.hasCompletedOnboarding")
            
            // Cancel any pending notifications
            self.notificationDebouncer?.cancel()
            
            // Send notification with debouncing
            self.notificationDebouncer = Just(())
                .delay(for: .milliseconds(50), scheduler: RunLoop.main)
                .sink { _ in
                    NotificationCenter.default.post(name: .didUpdateTerms, object: nil)
                }
        }
    }
} 