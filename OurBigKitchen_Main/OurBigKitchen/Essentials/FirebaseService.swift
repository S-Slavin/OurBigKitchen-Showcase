//
//  FirebaseService.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//


import Foundation

// Firebase protocols to allow compilation without Firebase
protocol FirebaseUser {
    var uid: String { get }
}

protocol FirebaseAuthProtocol {
    func addStateDidChangeListener(_ listener: @escaping (Any?, FirebaseUser?) -> Void)
}

protocol FirebaseServiceProtocol {
    var currentUser: FirebaseUser? { get set }
    var isLoading: Bool { get set }
    
    func setupAuthStateListener()
    func observeLeaderboard(completion: @escaping ([AppModels.CorporateVolunteer]) -> Void)
    func updateImpact(_ impact: Impact) async throws
}

class FirebaseService: ObservableObject, FirebaseServiceProtocol {
    static let shared = FirebaseService()
    
    @Published var currentUser: FirebaseUser?
    @Published var isLoading = false
    
    init() {
        configureFirebase()
    }
    
    private func configureFirebase() {
        #if DEBUG
        print("Firebase initialization skipped in DEBUG mode")
        #else
        // Firebase initialization will be added here
        #endif
    }
    
    func setupAuthStateListener() {
        #if DEBUG
        // No-op in DEBUG mode
        #else
        // Auth listener will be added here
        #endif
    }
    
    func observeLeaderboard(completion: @escaping ([AppModels.CorporateVolunteer]) -> Void) {
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Create sample data
            let sampleData: [AppModels.CorporateVolunteer] = [
                AppModels.CorporateVolunteer(id: "1", name: "TechCorp", company: "TechCorp", hoursContributed: 235, impactScore: 1250),
                AppModels.CorporateVolunteer(id: "2", name: "Global Finance", company: "Global Finance", hoursContributed: 180, impactScore: 980),
                AppModels.CorporateVolunteer(id: "3", name: "Green Energy", company: "Green Energy", hoursContributed: 156, impactScore: 820),
                AppModels.CorporateVolunteer(id: "4", name: "Healthcare Partners", company: "Healthcare Partners", hoursContributed: 120, impactScore: 650),
                AppModels.CorporateVolunteer(id: "5", name: "Construction Co", company: "Construction Co", hoursContributed: 95, impactScore: 510),
                AppModels.CorporateVolunteer(id: "6", name: "Food Service Inc", company: "Food Service Inc", hoursContributed: 85, impactScore: 460),
                AppModels.CorporateVolunteer(id: "7", name: "Community Bank", company: "Community Bank", hoursContributed: 70, impactScore: 380)
            ]
            
            completion(sampleData)
        }
    }
    
    func updateImpact(_ impact: Impact) async throws {
        #if DEBUG
        // No-op in DEBUG mode
        #else
        // Firestore update will be added here
        #endif
    }
}

enum FirebaseAuthError: Error {
    case notAuthenticated
}