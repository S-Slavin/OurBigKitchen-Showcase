//
//  PhotoSharingView.swift
//  OurBigKitchen
//
//  Created by Admin on 26/4/2025.
//

import SwiftUI
import UIKit

struct PhotoSharingView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = PhotoSharingViewModel()
   @State private var selectedImage: UIImage?
    @State private var showCamera = false
    @State private var showGallery = false
    @State private var showFilterOptions = false
    @State private var showShareSheet = false
    @State private var caption = "Making a difference with Our Big Kitchen! 🍽️ #CommunityService"
    @State private var selectedFilter = 0
    
    // Filter options for photos
    private let filters = ["Original", "Vibrant", "Warm", "Cool", "Dramatic"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Photo Section
                    photoSection
                    
                    // Caption Section
                    captionSection
                    
                    // Tag Selection Section
                    tagSelectionSection
                    
                    // Filter Section
                    if selectedImage != nil {
                        filterSection
                    }
                    
                    // Share Buttons
                    if selectedImage != nil {
                        shareButtonsSection
                    }
                    
                    // Impact Data Section
                    if selectedImage != nil {
                        impactDataSection
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .navigationTitle("Share Your Impact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                if let image = selectedImage {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            viewModel.shareToAllPlatforms(image: image, caption: caption, tags: viewModel.selectedTags)
                            showShareSheet = true
                        } label: {
                            Text("Share")
                                .fontWeight(.semibold)
                                .foregroundColor(ThemeManager.Colors.primary)
                        }
                    }
                }
            }
            .sheet(isPresented: $showCamera) {
                // Use existing CameraView from ImpactFilterView
                CameraView(image: $selectedImage, isShown: $showCamera)
            }
            .sheet(isPresented: $showGallery) {
                ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
            }
            .sheet(isPresented: $showShareSheet) {
                if let image = selectedImage {
                    // Use the ShareSheet utility from our utility folder
                    let captionWithTags = viewModel.getCaptionWithTags(caption)
                    ShareSheet(items: [image, captionWithTags])
                }
            }
        }
    }
    
    // MARK: - Section Components
    
    private var photoSection: some View {
        VStack(spacing: 16) {
            if let image = selectedImage {
                // Display selected image
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(height: 320)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .overlay(
                        Button {
                            withAnimation {
                                selectedImage = nil
                            }
                        } label: {
                            Image(systemName: "arrow.triangle.2.circlepath.camera")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(
                                    Circle()
                                        .fill(ThemeManager.Colors.secondary)
                                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                                )
                        }
                        .padding(16),
                        alignment: .bottomTrailing
                    )
            } else {
                // Photo selection options
                HStack(spacing: 20) {
                    // Camera option
                    photoOptionButton(
                        title: "Camera",
                        icon: "camera.fill",
                        color: ThemeManager.Colors.primary
                    ) {
                        showCamera = true
                    }
                    
                    // Gallery option
                    photoOptionButton(
                        title: "Gallery",
                        icon: "photo.on.rectangle",
                        color: ThemeManager.Colors.secondary
                    ) {
                        showGallery = true
                    }
                }
                .padding(.vertical, 40)
            }
        }
    }
    
    private var captionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Add a caption")
                .font(.headline)
                .foregroundColor(.primary)
            
            TextEditor(text: $caption)
                .frame(height: 100)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
    }
    
    // MARK: - Tag Selection Section
    private var tagSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Add tags")
                .font(.headline)
                .foregroundColor(.primary)
            
            FlowLayout(spacing: 8) {
                ForEach(viewModel.availableTags, id: \.self) { tag in
                    Button {
                        viewModel.toggleTag(tag)
                    } label: {
                        Text(tag)
                            .font(.subheadline)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(viewModel.selectedTags.contains(tag) ? 
                                          ThemeManager.Colors.secondary : Color.gray.opacity(0.1))
                            )
                            .foregroundColor(viewModel.selectedTags.contains(tag) ?
                                             .white : .primary)
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    private var filterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Enhance your photo")
                .font(.headline)
                .foregroundColor(.primary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(0..<filters.count, id: \.self) { index in
                        Button {
                            withAnimation {
                                selectedFilter = index
                                if let image = selectedImage {
                                    selectedImage = viewModel.applyFilter(to: image, filterIndex: index)
                                }
                            }
                        } label: {
                            VStack(spacing: 8) {
                                Circle()
                                    .fill(index == selectedFilter ? 
                                          ThemeManager.Colors.primary : Color.gray.opacity(0.2))
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        Image(systemName: "wand.and.stars")
                                            .font(.system(size: 24, weight: .medium))
                                            .foregroundColor(.white)
                                    )
                                
                                Text(filters[index])
                                    .font(.caption)
                                    .foregroundColor(index == selectedFilter ? 
                                                    ThemeManager.Colors.primary : .primary)
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    private var shareButtonsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Share on social media")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 20) {
                socialMediaButton(
                    platform: "Facebook",
                    icon: "f.circle.fill",
                    color: Color(red: 0.23, green: 0.35, blue: 0.6)
                ) {
                    if let image = selectedImage {
                        viewModel.shareToFacebook(image: image, caption: caption)
                    }
                }
                
                socialMediaButton(
                    platform: "Instagram",
                    icon: "camera.circle.fill",
                    color: Color(red: 0.8, green: 0.26, blue: 0.4)
                ) {
                    if let image = selectedImage {
                        viewModel.shareToInstagram(image: image, caption: caption)
                    }
                }
                
                socialMediaButton(
                    platform: "Twitter",
                    icon: "t.circle.fill",
                    color: Color(red: 0.11, green: 0.63, blue: 0.95)
                ) {
                    if let image = selectedImage {
                        viewModel.shareToTwitter(image: image, caption: caption)
                    }
                }
                
                socialMediaButton(
                    platform: "More",
                    icon: "ellipsis.circle.fill",
                    color: Color.gray
                ) {
                    if let image = selectedImage {
                        viewModel.shareToAllPlatforms(image: image, caption: caption)
                        showShareSheet = true
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    private var impactDataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Include your impact")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 20) {
                impactStatView(value: "120", label: "Meals")
                impactStatView(value: "48", label: "Hours")
                impactStatView(value: "56", label: "People")
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
        }
    }
    
    // MARK: - Helper Views
    
    private func photoOptionButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                    .frame(width: 70, height: 70)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(color)
                    )
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
        }
    }
    
    private func socialMediaButton(platform: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Circle()
                    .fill(color)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    )
                
                Text(platform)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
        }
    }
    
    private func impactStatView(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(ThemeManager.Colors.primary)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    PhotoSharingView()
} 