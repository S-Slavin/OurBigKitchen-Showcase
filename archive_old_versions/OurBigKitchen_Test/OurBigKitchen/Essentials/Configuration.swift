//
//  Configuration.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//


import Foundation

enum Configuration {
    enum Environment {
        case development
        case staging
        case production
        
        var baseURL: String {
            switch self {
            case .development: return "https://dev-api.ourbigkitchen.org"
            case .staging: return "https://staging-api.ourbigkitchen.org"
            case .production: return "https://api.ourbigkitchen.org"
            }
        }
    }
    
    static let current: Environment = {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }()
    
    static let apiKey: String = {
        guard let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String else {
            fatalError("API key not found in Info.plist")
        }
        return apiKey
    }()
}