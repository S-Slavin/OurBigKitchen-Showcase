//
//  ImpactShareCardViewModel.swift
//  OurBigKitchen
//
//  Created by Admin on 6/8/2025.
//

import SwiftUI
import Combine

class ImpactShareCardViewModel: ObservableObject {
    @Published var mealsContributed: Int = 0
    @Published var volunteersHelped: Int = 0
    @Published var hoursVolunteered: Double = 0.0
    @Published var impactMessage: String = ""
    @Published var isGeneratingCard: Bool = false
    @Published var generatedCardImage: UIImage?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadImpactData()
    }
    
    func loadImpactData() {
        // Load impact data from ImpactService or local storage
        Task { @MainActor in
            // Mock data for now - replace with actual data loading
            self.mealsContributed = UserDefaults.standard.integer(forKey: "totalMealsContributed")
            self.volunteersHelped = UserDefaults.standard.integer(forKey: "totalVolunteersHelped")
            self.hoursVolunteered = UserDefaults.standard.double(forKey: "totalHoursVolunteered")
            
            generateImpactMessage()
        }
    }
    
    private func generateImpactMessage() {
        if mealsContributed > 0 {
            impactMessage = "Together we've contributed \(mealsContributed) meals to those in need!"
        } else if hoursVolunteered > 0 {
            impactMessage = "Volunteered \(String(format: "%.1f", hoursVolunteered)) hours making a difference!"
        } else {
            impactMessage = "Making a difference, one meal at a time! 🍽️"
        }
    }
    
    func generateShareCard() {
        isGeneratingCard = true
        
        Task { @MainActor in
            // Generate the impact share card image
            let cardImage = await createImpactCardImage()
            self.generatedCardImage = cardImage
            self.isGeneratingCard = false
        }
    }
    
    private func createImpactCardImage() async -> UIImage? {
        let size = CGSize(width: 400, height: 600)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Background gradient
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                    colors: [UIColor.orange.cgColor, UIColor.red.cgColor] as CFArray,
                                    locations: [0.0, 1.0])
            
            context.cgContext.drawLinearGradient(gradient!,
                                               start: CGPoint(x: 0, y: 0),
                                               end: CGPoint(x: size.width, y: size.height),
                                               options: [])
            
            // Title
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.white
            ]
            
            let title = "My OurBigKitchen Impact"
            let titleSize = title.size(withAttributes: titleAttributes)
            title.draw(at: CGPoint(x: (size.width - titleSize.width) / 2, y: 50),
                      withAttributes: titleAttributes)
            
            // Impact stats
            let statsY: CGFloat = 150
            let statsSpacing: CGFloat = 80
            
            if mealsContributed > 0 {
                drawStat(value: "\(mealsContributed)", label: "Meals Contributed", 
                        at: CGPoint(x: size.width / 2, y: statsY), in: context.cgContext)
            }
            
            if hoursVolunteered > 0 {
                drawStat(value: String(format: "%.1f", hoursVolunteered), label: "Hours Volunteered",
                        at: CGPoint(x: size.width / 2, y: statsY + statsSpacing), in: context.cgContext)
            }
            
            if volunteersHelped > 0 {
                drawStat(value: "\(volunteersHelped)", label: "People Helped",
                        at: CGPoint(x: size.width / 2, y: statsY + statsSpacing * 2), in: context.cgContext)
            }
            
            // Impact message
            let messageAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18),
                .foregroundColor: UIColor.white
            ]
            
            let messageRect = CGRect(x: 20, y: size.height - 150, width: size.width - 40, height: 100)
            impactMessage.draw(in: messageRect, withAttributes: messageAttributes)
            
            // Logo/branding
            let brandingAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 16),
                .foregroundColor: UIColor.white.withAlphaComponent(0.8)
            ]
            
            let branding = "OurBigKitchen"
            let brandingSize = branding.size(withAttributes: brandingAttributes)
            branding.draw(at: CGPoint(x: (size.width - brandingSize.width) / 2, y: size.height - 40),
                         withAttributes: brandingAttributes)
        }
    }
    
    private func drawStat(value: String, label: String, at point: CGPoint, in context: CGContext) {
        let valueAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 32),
            .foregroundColor: UIColor.white
        ]
        
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.white.withAlphaComponent(0.9)
        ]
        
        let valueSize = value.size(withAttributes: valueAttributes)
        let labelSize = label.size(withAttributes: labelAttributes)
        
        value.draw(at: CGPoint(x: point.x - valueSize.width / 2, y: point.y),
                  withAttributes: valueAttributes)
        
        label.draw(at: CGPoint(x: point.x - labelSize.width / 2, y: point.y + valueSize.height + 5),
                  withAttributes: labelAttributes)
    }
    
    func updateImpactData(meals: Int, hours: Double, volunteers: Int) {
        self.mealsContributed = meals
        self.hoursVolunteered = hours
        self.volunteersHelped = volunteers
        
        // Save to UserDefaults
        UserDefaults.standard.set(meals, forKey: "totalMealsContributed")
        UserDefaults.standard.set(hours, forKey: "totalHoursVolunteered")
        UserDefaults.standard.set(volunteers, forKey: "totalVolunteersHelped")
        
        generateImpactMessage()
    }
}