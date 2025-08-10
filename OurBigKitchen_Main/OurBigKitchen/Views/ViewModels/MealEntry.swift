//
//  MealEntry.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//


import Foundation
import SwiftUI
// Import the Models module to access the Impact struct

// MARK: - MealEntry
struct MealEntry: Identifiable, Codable {
    let id: UUID
    var groupCode: String
    var dishName: String
    var mealCount: Int
    var date: Date
    
    var isValid: Bool {
        !groupCode.isEmpty &&
        !dishName.isEmpty &&
        mealCount > 0
    }
    
    static var empty: MealEntry {
        MealEntry(
            id: UUID(),
            groupCode: "",
            dishName: "",
            mealCount: 1,
            date: Date()
        )
    }
}

// MARK: - VolunteerOpportunity
// Moved to AppModels.swift to avoid duplication

// MARK: - UI Achievement (for in-memory UI use only)
// This is different from the model Achievement in UserManager
struct UIAchievement: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let icon: String
    let requiredPoints: Int
    let colorName: String
    
    var color: Color {
        Color(colorName)
    }
    
    init(id: UUID, title: String, description: String, icon: String, requiredPoints: Int, color: Color) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.requiredPoints = requiredPoints
        
        // Store color as string name
        switch color {
        case .red: self.colorName = "red"
        case .orange: self.colorName = "orange"
        case .yellow: self.colorName = "yellow"
        case .green: self.colorName = "green"
        case .blue: self.colorName = "blue"
        case .purple: self.colorName = "purple"
        case .gray: self.colorName = "gray"
        default: self.colorName = "blue" // Default fallback
        }
    }
    
    static let sampleAchievements = [
        UIAchievement(
            id: UUID(),
            title: "First Timer",
            description: "Complete your first volunteer session",
            icon: "star.fill",
            requiredPoints: 0,
            color: .yellow
        ),
        UIAchievement(
            id: UUID(),
            title: "Meal Master",
            description: "Help prepare 100 meals",
            icon: "fork.knife",
            requiredPoints: 100,
            color: .blue
        )
    ]
}

// MARK: - Achievements
struct MealEntryAchievement: Identifiable, Codable {
    var id: UUID
    var title: String
    var description: String
    var icon: String
    var requiredPoints: Int
    private var colorName: String
    
    var color: Color {
        Color(colorName)
    }
    
    init(id: UUID, title: String, description: String, icon: String, requiredPoints: Int, color: Color) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.requiredPoints = requiredPoints
        
        // Store color as string name
        switch color {
        case .red: self.colorName = "red"
        case .orange: self.colorName = "orange"
        case .yellow: self.colorName = "yellow"
        case .green: self.colorName = "green"
        case .blue: self.colorName = "blue"
        case .purple: self.colorName = "purple"
        case .gray: self.colorName = "gray"
        default: self.colorName = "blue" // Default fallback
        }
    }
    
    static var examples: [MealEntryAchievement] = [
        MealEntryAchievement(
            id: UUID(),
            title: "First Timer",
            description: "Complete your first volunteer session",
            icon: "star.fill",
            requiredPoints: 1,
            color: .green
        ),
        MealEntryAchievement(
            id: UUID(),
            title: "Meal Master",
            description: "Help prepare 100 meals",
            icon: "fork.knife",
            requiredPoints: 100,
            color: .blue
        )
    ]
}