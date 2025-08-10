//
//  ImpactFilterViewModel.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//

import Foundation
import SwiftUI
import UIKit

@MainActor
class ImpactFilterViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var impact: Impact
    @Published var currentFilterSet: String = "Classic"
    @Published var selectedBackgroundType: String = "Solid Color"
    @Published var selectedBackgroundColor: Color = Color.blue.opacity(0.1)
    @Published var accentColors: [Color] = [.orange, .blue, .green]
    @Published var selectedTextColor: Color = .black
    @Published var boldText: Bool = true
    @Published var showLogo: Bool = true
    @Published var textSizeMultiplier: Double = 1.0
    @Published var filteredImage: UIImage?
    @Published var selfieImage: UIImage?
    
    // Input fields for impact calculation
    @Published var mealsMadeString: String = ""
    @Published var timeSpentString: String = ""
    
    // Service dependencies
    private let imageRenderingService: ImageRenderingService = .shared
    
    // MARK: - Initialization
    
    init(impact: Impact) {
        self.impact = impact
        applyFilterSet("Classic") // Apply default filter
        
        // Initialize string values if impact already has meals made and time spent
        if let mealsMade = impact.mealsMade {
            mealsMadeString = "\(mealsMade)"
        }
        
        if let timeSpent = impact.timeSpent {
            timeSpentString = "\(timeSpent)"
        }
    }
    
    // MARK: - User Input Processing
    
    func updateMealsMade(_ newValue: String) {
        mealsMadeString = newValue
        
        // Update impact with new value
        if let mealsMade = Int(newValue) {
            var updatedImpact = impact
            updatedImpact.mealsMade = mealsMade
            impact = updatedImpact
        } else if newValue.isEmpty {
            var updatedImpact = impact
            updatedImpact.mealsMade = nil
            impact = updatedImpact
        }
    }
    
    func updateTimeSpent(_ newValue: String) {
        timeSpentString = newValue
        
        // Update impact with new value
        if let timeSpent = Int(newValue) {
            var updatedImpact = impact
            updatedImpact.timeSpent = timeSpent
            impact = updatedImpact
        } else if newValue.isEmpty {
            var updatedImpact = impact
            updatedImpact.timeSpent = nil
            impact = updatedImpact
        }
    }
    
    // MARK: - Filter Application
    
    func applyFilterSet(_ filterSet: String) {
        currentFilterSet = filterSet
        
        switch filterSet {
        case "Classic":
            selectedBackgroundColor = Color.blue.opacity(0.1)
            accentColors = [.orange, .blue, .green]
            selectedTextColor = .black
            boldText = true
            textSizeMultiplier = 1.0
            
        case "Vibrant":
            selectedBackgroundColor = Color.purple.opacity(0.2)
            accentColors = [.pink, .orange, .yellow]
            selectedTextColor = .purple
            boldText = true
            textSizeMultiplier = 1.1
            
        case "Minimal":
            selectedBackgroundColor = Color.white
            accentColors = [.gray, .gray.opacity(0.7), .gray.opacity(0.5)]
            selectedTextColor = .black
            boldText = false
            textSizeMultiplier = 0.9
            
        case "Community":
            selectedBackgroundColor = Color.green.opacity(0.1)
            accentColors = [.green, .blue, .teal]
            selectedTextColor = .darkGreen
            boldText = true
            textSizeMultiplier = 1.0
            
        case "Monochrome":
            selectedBackgroundColor = Color.black
            accentColors = [.white, .gray, .white.opacity(0.8)]
            selectedTextColor = .white
            boldText = true
            textSizeMultiplier = 1.0
            
        default:
            break
        }
    }
    
    func resetFilter() {
        applyFilterSet("Classic")
    }
    
    func applyFilter(withSelfie selfie: UIImage? = nil) {
        self.selfieImage = selfie
        // Rendering will be implemented in the next version
        // For now, we just pass the filter parameters to the next screen
    }
    
    // MARK: - Image Rendering
    
    func renderImpactImage() -> UIImage? {
        // Create a view to render
        let renderView = FilteredImpactPreview(
            impact: impact,
            backgroundColor: selectedBackgroundColor,
            accentColors: accentColors,
            textColor: selectedTextColor,
            boldText: boldText,
            showLogo: showLogo,
            textSizeMultiplier: textSizeMultiplier,
            selfieImage: selfieImage
        )
        
        // Render the view as an image
        let renderedImage = imageRenderingService.renderView(
            renderView,
            size: CGSize(width: 500, height: selfieImage != nil ? 600 : 500)
        )
        
        // Apply any additional filters if needed
        if let renderedImage = renderedImage, currentFilterSet != "Classic" {
            return imageRenderingService.applyFilter(to: renderedImage, filter: currentFilterSet)
        }
        
        return renderedImage
    }
}

// MARK: - Supporting Types

extension Color {
    static let darkGreen = Color(red: 0.0, green: 0.5, blue: 0.0)
}

// MARK: - Filtered Impact Preview

struct FilteredImpactPreview: View {
    let impact: Impact
    let backgroundColor: Color
    let accentColors: [Color]
    let textColor: Color
    let boldText: Bool
    let showLogo: Bool
    let textSizeMultiplier: Double
    let selfieImage: UIImage?
    
    var body: some View {
        ZStack {
            // Background
            Rectangle()
                .fill(backgroundColor)
                .cornerRadius(12)
            
            // Content
            VStack(spacing: 24) {
                // Title
                Text("Your Impact at OBK")
                    .font(.system(size: 32 * textSizeMultiplier, weight: boldText ? .bold : .semibold))
                    .foregroundColor(textColor)
                
                // Selfie if available
                if let selfie = selfieImage {
                    Image(uiImage: selfie)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            VStack {
                                Spacer()
                                Text("My Impact")
                                    .font(.system(size: 24 * textSizeMultiplier, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.black.opacity(0.4))
                                    .cornerRadius(8)
                                    .padding(.bottom, 12)
                            }
                        )
                        .shadow(radius: 3)
                }
                
                // Main Stats
                HStack(spacing: 20) {
                    StatItem(
                        value: "\(impact.mealsProvided)",
                        label: "Meals",
                        icon: "fork.knife",
                        color: accentColors[0]
                    )
                    
                    StatItem(
                        value: "\(impact.hoursContributed)",
                        label: "Hours",
                        icon: "clock.fill",
                        color: accentColors[1]
                    )
                    
                    StatItem(
                        value: "\(impact.peopleHelped)",
                        label: "People",
                        icon: "person.2.fill",
                        color: accentColors[2]
                    )
                }
                
                // Include food waste and CO2 if input values are available
                if impact.mealsMade != nil && impact.timeSpent != nil {
                    // Environment impact stats
                    HStack(spacing: 20) {
                        StatItem(
                            value: String(format: "%.1f kg", impact.foodWasteSaved),
                            label: "Food Saved",
                            icon: "arrow.3.trianglepath",
                            color: accentColors[0]
                        )
                        
                        StatItem(
                            value: String(format: "%.1f kg", impact.carbonSaved),
                            label: "CO2 Saved",
                            icon: "leaf.fill",
                            color: accentColors[1]
                        )
                    }
                }
                
                // Logo and tag
                if showLogo {
                    VStack(spacing: 4) {
                        Text("Our Big Kitchen")
                            .font(.system(size: 20 * textSizeMultiplier, weight: boldText ? .bold : .semibold))
                            .foregroundColor(textColor)
                        
                        Text("Making a difference together")
                            .font(.system(size: 16 * textSizeMultiplier, weight: .regular))
                            .foregroundColor(textColor.opacity(0.8))
                    }
                }
                
                // Carbon impact (if input values are not available)
                if (impact.mealsMade == nil || impact.timeSpent == nil) && selfieImage == nil {
                    HStack {
                        Image(systemName: "leaf.fill")
                            .foregroundColor(accentColors[2])
                        
                        Text("You've saved approx. \(String(format: "%.1f", impact.carbonSaved)) kg CO2")
                            .font(.system(size: 16 * textSizeMultiplier, weight: boldText ? .semibold : .regular))
                            .foregroundColor(textColor)
                    }
                }
            }
            .padding(32)
        }
        .aspectRatio(selfieImage != nil ? 1.2 : 1, contentMode: .fit)
    }
    
    private struct StatItem: View {
        let value: String
        let label: String
        let icon: String
        let color: Color
        
        var body: some View {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(color)
                
                Text(value)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(color)
                
                Text(label)
                    .font(.system(size: 16))
                    .foregroundColor(color.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Image Rendering Service
// This would be in its own file in a real app

// Removing the duplicate ImageRenderingService class since it's already defined in its own file
// in /Users/admin/Desktop/OurBigKitchen/OurBigKitchen/Services/ImageRenderingService.swift

// ... existing code ... 