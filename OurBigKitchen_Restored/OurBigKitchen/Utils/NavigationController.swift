//
//  NavigationController.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//


import SwiftUI

class NavigationController: ObservableObject {
    static let shared = NavigationController()
    
    @Published var selectedTab: Tab = .home
    @Published var path = NavigationPath()
    
    private init() {}
    
    func navigateToRoot() {
        path = NavigationPath()
    }
    
    func navigateToTab(_ tab: Tab) {
        selectedTab = tab
    }
}

enum Tab: Hashable {
    case home
    case impact
    case profile
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .impact: return "Impact"
        case .profile: return "Profile"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .impact: return "chart.bar.fill"
        case .profile: return "person.fill"
        }
    }
}