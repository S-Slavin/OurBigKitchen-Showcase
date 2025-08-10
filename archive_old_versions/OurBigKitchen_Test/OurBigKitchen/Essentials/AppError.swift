//
//  AppError.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//


import Foundation

enum AppError: LocalizedError {
    case networkError(String)
    case authenticationError(String)
    case databaseError(String)
    case validationError(String)
    case unexpectedError(String)
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message): return "Network Error: \(message)"
        case .authenticationError(let message): return "Authentication Error: \(message)"
        case .databaseError(let message): return "Database Error: \(message)"
        case .validationError(let message): return "Validation Error: \(message)"
        case .unexpectedError(let message): return "Unexpected Error: \(message)"
        }
    }
}

class ErrorHandler {
    static func handle(_ error: Error) {
        #if DEBUG
        print("Error occurred: \(error.localizedDescription)")
        #endif
        
        // Log error to analytics
        AnalyticsService.shared.trackEvent(.errorOccurred, properties: [
            "error_type": String(describing: type(of: error)),
            "error_message": error.localizedDescription
        ])
    }
}