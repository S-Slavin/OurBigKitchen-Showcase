//
//  PhotoSharingViewModel.swift
//  OurBigKitchen
//
//  Created by Admin on 26/4/2025.
//

import Foundation
import SwiftUI
import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

class PhotoSharingViewModel: ObservableObject {
    @Published var includeImpactData = true
    @Published var isProcessing = false
    @Published var shareResult: Bool?
    @Published var errorMessage: String?
    
    // Tag selection properties
    @Published var selectedTags: Set<String> = []
    @Published var availableTags: [String] = [
        "Cooking", "Serving", "Volunteering", "Donations", 
        "Delivery", "Food Rescue", "Community", "Education",
        "Team Building", "Helping Others"
    ]
    
    private let context = CIContext()
    
    // Function to toggle a tag selection
    func toggleTag(_ tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }
    
    // Function to apply various filters to an image based on index
    func applyFilter(to image: UIImage, filterIndex: Int) -> UIImage {
        // If original filter is selected, return original image
        if filterIndex == 0 {
            return image
        }
        
        guard let ciImage = CIImage(image: image) else { return image }
        var filteredImage: CIImage
        
        switch filterIndex {
        case 1: // Vibrant
            let filter = CIFilter.vibrance()
            filter.inputImage = ciImage
            filter.amount = 1.0 // Max vibrancy
            
            if let output = filter.outputImage {
                filteredImage = output
            } else {
                return image
            }
            
        case 2: // Warm
            let filter = CIFilter.colorControls()
            filter.inputImage = ciImage
            filter.saturation = 1.2
            filter.brightness = 0.1
            filter.contrast = 1.1
            
            if let output = filter.outputImage {
                // Add warmth by applying a light orange overlay
                let warmFilter = CIFilter.colorMatrix()
                warmFilter.inputImage = output
                warmFilter.rVector = CIVector(x: 1.1, y: 0, z: 0, w: 0)
                warmFilter.gVector = CIVector(x: 0, y: 1.0, z: 0, w: 0)
                warmFilter.bVector = CIVector(x: 0, y: 0, z: 0.9, w: 0)
                
                if let warmOutput = warmFilter.outputImage {
                    filteredImage = warmOutput
                } else {
                    filteredImage = output
                }
            } else {
                return image
            }
            
        case 3: // Cool
            let filter = CIFilter.colorControls()
            filter.inputImage = ciImage
            filter.saturation = 1.1
            filter.brightness = 0.05
            filter.contrast = 1.1
            
            if let output = filter.outputImage {
                // Add coolness by applying a light blue overlay
                let coolFilter = CIFilter.colorMatrix()
                coolFilter.inputImage = output
                coolFilter.rVector = CIVector(x: 0.9, y: 0, z: 0, w: 0)
                coolFilter.gVector = CIVector(x: 0, y: 1.0, z: 0, w: 0)
                coolFilter.bVector = CIVector(x: 0, y: 0, z: 1.1, w: 0)
                
                if let coolOutput = coolFilter.outputImage {
                    filteredImage = coolOutput
                } else {
                    filteredImage = output
                }
            } else {
                return image
            }
            
        case 4: // Dramatic
            let filter = CIFilter.photoEffectNoir()
            filter.inputImage = ciImage
            
            if let noirOutput = filter.outputImage {
                let vignetteFilter = CIFilter.vignette()
                vignetteFilter.inputImage = noirOutput
                vignetteFilter.intensity = 0.7
                vignetteFilter.radius = 1.5
                
                if let output = vignetteFilter.outputImage {
                    filteredImage = output
                } else {
                    filteredImage = noirOutput
                }
            } else {
                return image
            }
            
        default:
            return image
        }
        
        // Convert back to UIImage
        if let cgImage = context.createCGImage(filteredImage, from: filteredImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        
        return image
    }
    
    // Function to add impact data overlay to an image
    func addImpactDataOverlay(to image: UIImage, mealsProvided: Int, hoursContributed: Int, tags: Set<String>) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        
        return renderer.image { ctx in
            // Draw the original image
            image.draw(in: CGRect(origin: .zero, size: image.size))
            
            // Set up attributes for text
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .bold),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle,
                .strokeColor: UIColor.black,
                .strokeWidth: -2.0
            ]
            
            // Create tags text
            let tagsText = tags.isEmpty ? "" : "Tags: #" + tags.joined(separator: " #") + "\n"
            
            // Create impact data text
            let impactText = """
            \(tagsText)Impact:
            🍽️ \(mealsProvided) meals provided
            ⏱️ \(hoursContributed) hours contributed
            """
            
            // Draw text in bottom corner with padding
            let textRect = CGRect(x: 20, y: image.size.height - 100, width: image.size.width - 40, height: 80)
            impactText.draw(in: textRect, withAttributes: attributes)
        }
    }
    
    // Function to share to Facebook
    func shareToFacebook(image: UIImage, caption: String) {
        shareToSocialMedia(platform: "facebook", image: image, caption: caption)
    }
    
    // Function to share to Instagram
    func shareToInstagram(image: UIImage, caption: String) {
        shareToSocialMedia(platform: "instagram", image: image, caption: caption)
    }
    
    // Function to share to Twitter
    func shareToTwitter(image: UIImage, caption: String) {
        shareToSocialMedia(platform: "twitter", image: image, caption: caption)
    }
    
    // Generic function to share to social media (using URL schemes)
    private func shareToSocialMedia(platform: String, image: UIImage, caption: String) {
        // In a real app, this would use the platform's SDK or URL scheme
        // For demo purposes, we're just using a generic share sheet
        
        shareToAllPlatforms(image: image, caption: caption, tags: selectedTags)
    }
    
    // Function to share to all platforms using activity controller
    func shareToAllPlatforms(image: UIImage, caption: String, tags: Set<String> = []) {
        isProcessing = true
        
        // Add hashtags to caption if not already present
        var updatedCaption = caption
        for tag in tags {
            if !updatedCaption.contains("#\(tag)") {
                updatedCaption += " #\(tag)"
            }
        }
        
        // Process the image if impact data should be included
        let finalImage = includeImpactData ? addImpactDataOverlay(
            to: image, 
            mealsProvided: Int.random(in: 10...50), 
            hoursContributed: Int.random(in: 2...8),
            tags: tags
        ) : image
        
        // In a real app, this would actually trigger the sharing
        // For now, just simulate success
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isProcessing = false
            self.shareResult = true
        }
    }
    
    // Function to get a caption with tags as hashtags
    func getCaptionWithTags(_ caption: String) -> String {
        var updatedCaption = caption
        for tag in selectedTags {
            if !updatedCaption.contains("#\(tag)") {
                updatedCaption += " #\(tag)"
            }
        }
        return updatedCaption
    }
} 