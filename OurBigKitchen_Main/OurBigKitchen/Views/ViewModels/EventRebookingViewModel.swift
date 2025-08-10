//
//  EventRebookingViewModel.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class EventRebookingViewModel: ObservableObject {
    // Form Data
    @Published var selectedOption: EventRebookingService.BookingOption?
    @Published var groupSize: String = ""
    @Published var preferredDate: Date = Date().addingTimeInterval(86400 * 7) // One week from now
    @Published var notes: String = ""
    
    // UI State
    @Published var showWebView: Bool = false
    @Published var bookingURL: URL?
    @Published var showDatePicker: Bool = false
    @Published var isLoading: Bool = false
    @Published var validationError: String?
    
    // Service
    private let eventRebookingService: EventRebookingService
    
    var bookingOptions: [EventRebookingService.BookingOption] {
        eventRebookingService.bookingOptions
    }
    
    init(eventRebookingService: EventRebookingService = .shared) {
        self.eventRebookingService = eventRebookingService
    }
    
    // MARK: - Actions
    
    func selectOption(_ option: EventRebookingService.BookingOption) {
        selectedOption = option
    }
    
    func isOptionSelected(_ option: EventRebookingService.BookingOption) -> Bool {
        selectedOption?.id == option.id
    }
    
    func proceedToBooking() {
        guard validate() else { return }
        
        isLoading = true
        
        // Create URL with parameters
        if let option = selectedOption, let sizeInt = Int(groupSize) {
            bookingURL = eventRebookingService.createCustomBookingURL(
                type: option.title,
                groupSize: sizeInt,
                preferredDate: preferredDate
            )
            
            // Simulate network delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.isLoading = false
                self?.showWebView = true
            }
        }
    }
    
    func openDirectly() {
        guard let option = selectedOption else { return }
        eventRebookingService.openBookingURL(option.url)
    }
    
    // MARK: - Validation
    
    func validate() -> Bool {
        // Reset validation error
        validationError = nil
        
        // Check if option is selected
        if selectedOption == nil {
            validationError = "Please select an event type"
            return false
        }
        
        // Check if group size is valid
        if groupSize.isEmpty {
            validationError = "Please enter your group size"
            return false
        } else if let size = Int(groupSize), (size < 5 || size > 100) {
            validationError = "Group size must be between 5 and 100"
            return false
        } else if Int(groupSize) == nil {
            validationError = "Please enter a valid number for group size"
            return false
        }
        
        // Check if date is valid (must be at least 3 days in the future)
        let minDate = Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()
        if preferredDate < minDate {
            validationError = "Please select a date at least 3 days from now"
            return false
        }
        
        return true
    }
    
    // MARK: - Formatting
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
} 