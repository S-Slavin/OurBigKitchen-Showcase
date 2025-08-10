//
//  SocialSharingView.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//

import SwiftUI
import Foundation
import UIKit

// Forward referencing the ViewModels and Models to resolve naming conflicts
typealias FilterViewModel = ImpactFilterViewModel
typealias UserImpact = Impact // To disambiguate from any other Impact declarations

struct SocialSharingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var viewModel = SocialSharingViewModel()
    @State private var selectedTab = 0
    @State private var showShareSheet = false
    @State private var shareImage: UIImage? = nil
    @State private var isCreatingImage = false
    @State private var impactMessage = "I just volunteered at Our Big Kitchen! 🍽️ Together we're making a difference in our community. #OurBigKitchen #Volunteer"
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingShareSheet = false
    @State private var showingPlatformPicker = false
    @State private var showingCaptionPicker = false
    @State private var selectedCaptionIndex = 0
    @State private var customCaption = ""
    @State private var isUsingCustomCaption = false
    @State private var showingOnboarding = false
    
    private let tabs = ["Primary", "Stats", "Story", "Custom"]
    private let captionTemplates = [
        "Making a difference at Our Big Kitchen! 🍽️ #CommunityService",
        "Proud to volunteer with @OurBigKitchen today! 💪 #GivingBack",
        "Every meal counts! Helping those in need at OBK 🥘 #FoodSecurity",
        "Together we can make a bigger impact! 🤝 #CommunityKitchen"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    VStack(spacing: 8) {
                        Text("Let's Build a Kinder World")
                            .font(.title2)
                            .bold()
                            .multilineTextAlignment(.center)
                        
                        Text("Share your impact and inspire others to join our mission")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)
                    
                    // Tab Selection
                    Picker("Share Type", selection: $selectedTab) {
                        ForEach(0..<tabs.count, id: \.self) { index in
                            Text(tabs[index])
                                .tag(index)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Content based on selected tab
                    switch selectedTab {
                    case 0:
                        primaryShareView
                    case 1:
                        statsShareView
                    case 2:
                        storyShareView
                    case 3:
                        customShareView
                    default:
                        EmptyView()
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Share Your Journey to Create a Ripple Effect of Change")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 20))
                            Text("SKIP FOR DEMO")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 24)
                        .background(Color.orange)
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .sheet(isPresented: $showingOnboarding, onDismiss: {
                // Reset the state if needed
                if !UserDefaults.standard.bool(forKey: "com.ourbigkitchen.hasCompletedOnboarding") {
                    UserDefaults.standard.set(true, forKey: "com.ourbigkitchen.hasCompletedOnboarding")
                }
            }) {
                OnboardingView()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .onAppear {
                // Only show onboarding if it hasn't been completed
                if !UserDefaults.standard.bool(forKey: "com.ourbigkitchen.hasCompletedOnboarding") {
                    showingOnboarding = true
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                VStack {
                    HStack {
                        Spacer()
                        Button("SKIP FOR DEMO") {
                            showingImagePicker = false
                        }
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 24)
                        .background(Color.orange)
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                        .padding()
                    }
                    
                    ImagePicker(image: $selectedImage)
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(items: shareItems())
            }
            .sheet(isPresented: $showingPlatformPicker) {
                PlatformPickerView(viewModel: viewModel)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingCaptionPicker) {
                captionPickerView
            }
        }
    }
    
    @Namespace private var namespace
    
    // MARK: - Primary Share View
    
    private var primaryShareView: some View {
        VStack(spacing: 24) {
            // Photo Section
            VStack(spacing: 16) {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                } else {
                    Button {
                        showingImagePicker = true
                    } label: {
                        VStack(spacing: 12) {
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            Text("Add Your Volunteer Photo")
                                .font(.headline)
                            Text("Capture the moment of kindness")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 300)
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                    }
                }
            }
            .padding(.horizontal)
            
            // Impact Logging Section
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                    Text("Log Your Impact")
                        .font(.headline)
                }
                .padding(.horizontal)
                
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "fork.knife")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        TextField("Meals made", text: $viewModel.mealsMadeString)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        TextField("Hours volunteered", text: $viewModel.timeSpentString)
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    Button {
                        viewModel.saveUserContribution()
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Save Impact")
                        }
                        .font(.headline)
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(!viewModel.canSaveContribution)
                }
                .padding(.horizontal)
            }
            
            // Caption and sharing UI elements
            shareCaptionSection
            
            // Sharing Options
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "square.and.arrow.up.fill")
                        .foregroundColor(.purple)
                    Text("Share with the World")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(viewModel.platforms) { platform in
                            Button {
                                viewModel.selectedPlatform = platform
                                shareToSelectedPlatform()
                            } label: {
                                VStack(spacing: 10) {
                                    Image(systemName: platform.iconName)
                                        .font(.system(size: 24))
                                        .foregroundColor(platform.color)
                                        .frame(width: 56, height: 56)
                                        .background(platform.color.opacity(0.1))
                                        .cornerRadius(16)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(platform.color.opacity(0.3), lineWidth: 1)
                                        )
                                    
                                    Text(platform.rawValue)
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                }
                                .frame(width: 70)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                }
                
                Button(action: {
                    prepareAndShare()
                }) {
                    HStack {
                        Image(systemName: "share")
                        Text("Share with All Apps")
                    }
                    .font(.headline)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]), 
                            startPoint: .leading, 
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
    }
    
    // MARK: - Stats Share View
    
    private var statsShareView: some View {
        VStack(spacing: 24) {
            if let impact = viewModel.userImpact {
                // Impact Card Preview
                VStack(spacing: 20) {
                    impactCard(impact: impact)
                        .padding(.horizontal)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    // Share Button
                    Button {
                        shareStats()
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share Stats")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Social platforms section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Share to specific platforms")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        HStack(spacing: 16) {
                            ForEach(SocialSharingViewModel.SocialPlatform.allCases.filter { $0 != .all }, id: \.self) { platform in
                                Button {
                                    shareToPlatform(platform)
                                } label: {
                                    VStack(spacing: 8) {
                                        ZStack {
                                            Circle()
                                                .fill(platform.color.opacity(0.1))
                                                .frame(width: 50, height: 50)
                                            
                                            Image(systemName: platform.iconName)
                                                .font(.system(size: 20))
                                                .foregroundColor(platform.color)
                                        }
                                        
                                        Text(platform.rawValue)
                                            .font(.caption)
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 8)
                }
            } else {
                Text("No impact data available")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Story Share View
    
    private var storyShareView: some View {
        VStack(spacing: 24) {
            if let impact = viewModel.userImpact {
                // Story Preview
                VStack(spacing: 20) {
                    storyCard(impact: impact)
                        .padding(.horizontal)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    // Share Button
                    Button {
                        shareStory()
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share Story")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Social platforms section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Share to specific platforms")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        HStack(spacing: 16) {
                            ForEach(SocialSharingViewModel.SocialPlatform.allCases.filter { $0 != .all }, id: \.self) { platform in
                                Button {
                                    shareToPlatform(platform)
                                } label: {
                                    VStack(spacing: 8) {
                                        ZStack {
                                            Circle()
                                                .fill(platform.color.opacity(0.1))
                                                .frame(width: 50, height: 50)
                                            
                                            Image(systemName: platform.iconName)
                                                .font(.system(size: 20))
                                                .foregroundColor(platform.color)
                                        }
                                        
                                        Text(platform.rawValue)
                                            .font(.caption)
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 8)
                }
            } else {
                Text("No impact data available")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Custom Share View
    
    private var customShareView: some View {
        VStack(spacing: 24) {
            // Impact Stats
            VStack(spacing: 16) {
                Text("Your Impact")
                    .font(.title2)
                    .bold()
                
                HStack(spacing: 20) {
                    ImpactStat(
                        icon: "clock.fill",
                        color: ThemeManager.Colors.hoursContributed,
                        value: "\(viewModel.userImpact?.hoursContributed ?? 0)",
                        label: "Hours"
                    )
                    ImpactStat(
                        icon: "fork.knife",
                        color: ThemeManager.Colors.mealsServed,
                        value: "\(viewModel.userImpact?.mealsProvided ?? 0)",
                        label: "Meals"
                    )
                    ImpactStat(
                        icon: "calendar",
                        color: ThemeManager.Colors.accent,
                        value: "\(viewModel.userImpact?.eventsAttended ?? 0)",
                        label: "Events"
                    )
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            
            // Share Message
            VStack(alignment: .leading, spacing: 8) {
                Text("Share Your Journey")
                    .font(.headline)
                
                TextEditor(text: $impactMessage)
                    .frame(height: 100)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            
            // Add Photo Button
            Button {
                showingImagePicker = true
            } label: {
                HStack {
                    Image(systemName: "photo")
                    Text("Add Photo")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            .padding(.horizontal)
            
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
            
            // Share Options
            VStack(spacing: 12) {
                Button(action: {
                    prepareAndShare()
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18, weight: .medium))
                        Text("Share")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .shadow(color: Color.blue.opacity(0.3), radius: 4, x: 0, y: 2)
                }
                .sheet(isPresented: $showingShareSheet) {
                    ShareSheet(items: shareItems())
                }
                
                // Social platforms section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Share to specific platforms")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(SocialSharingViewModel.SocialPlatform.allCases.filter { $0 != .all }, id: \.self) { platform in
                                Button {
                                    shareToPlatform(platform)
                                } label: {
                                    VStack(spacing: 8) {
                                        ZStack {
                                            Circle()
                                                .fill(platform.color.opacity(0.1))
                                                .frame(width: 60, height: 60)
                                            
                                            Image(systemName: platform.iconName)
                                                .font(.system(size: 24))
                                                .foregroundColor(platform.color)
                                        }
                                        
                                        Text(platform.rawValue)
                                            .font(.caption)
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                    }
                                    .frame(width: 80)
                                    .padding(8)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 120)
                }
                .padding(.vertical, 8)
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack {
            ProgressView()
            Text("Loading your impact data...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 100)
    }
    
    // MARK: - Helper Views
    
    private func impactCard(impact: Impact) -> some View {
        VStack(spacing: 16) {
            Text("My Impact at OBK")
                .font(.title2)
                .bold()
            
            HStack(spacing: 20) {
                ImpactStatView(
                    value: impact.mealsProvided,
                    label: "Meals",
                    icon: "fork.knife",
                    color: .blue
                )
                
                ImpactStatView(
                    value: impact.hoursContributed,
                    label: "Hours",
                    icon: "clock",
                    color: .orange
                )
                
                ImpactStatView(
                    value: impact.peopleHelped,
                    label: "People Helped",
                    icon: "person.2",
                    color: .blue
                )
            }
            
            HStack(spacing: 20) {
                ImpactStatView(
                    value: Int(impact.foodWasteSaved),
                    label: "Food Waste Saved",
                    icon: "leaf",
                    color: .green
                )
                
                ImpactStatView(
                    value: Int(impact.carbonSaved),
                    label: "Carbon Saved",
                    icon: "cloud",
                    color: .blue
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    private func storyCard(impact: Impact) -> some View {
        VStack(spacing: 16) {
            Text("My Volunteer Journey")
                .font(.title2)
                .bold()
            
            Text("I've contributed \(impact.hoursContributed) hours at Our Big Kitchen, helping prepare \(impact.mealsProvided) meals for those in need. Together with other volunteers, we've helped \(impact.peopleHelped) people in our community and saved \(String(format: "%.1f", impact.foodWasteSaved)) kg of food from going to waste!")
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    private func shareStats() {
        guard let impact = viewModel.userImpact else { return }
        let message = """
        My Impact at Our Big Kitchen 🏆
        
        🍽 \(impact.mealsProvided) Meals Provided
        ⏰ \(impact.hoursContributed) Hours Contributed
        👥 \(impact.peopleHelped) People Helped
        🌱 \(String(format: "%.1f", impact.foodWasteSaved)) kg Food Saved
        🌍 \(String(format: "%.1f", impact.carbonSaved)) kg CO₂ Saved
        
        Join me in making a difference! #OurBigKitchen #CommunityService
        """
        
        impactMessage = message
        showingShareSheet = true
    }
    
    private func shareStory() {
        guard let impact = viewModel.userImpact else { return }
        let message = """
        My Volunteer Journey at Our Big Kitchen 🌟
        
        I'm proud to have contributed \(impact.hoursContributed) hours at Our Big Kitchen, where we've prepared \(impact.mealsProvided) meals for those in need. Together with amazing volunteers, we've positively impacted \(impact.peopleHelped) lives and saved \(String(format: "%.1f", impact.foodWasteSaved)) kg of food from going to waste!
        
        Every hour counts, every meal matters. Join us in making a difference! 💪
        #OurBigKitchen #CommunityService #Volunteering
        """
        
        impactMessage = message
        showingShareSheet = true
    }
    
    private func shareToPlatform(_ platform: SocialSharingViewModel.SocialPlatform) {
        // Update the message based on the current view and platform
        let message = isUsingCustomCaption ? customCaption : captionTemplates[selectedCaptionIndex]
        impactMessage = message
        
        // Show the share sheet with the appropriate content
        if let image = selectedImage {
            viewModel.shareFilteredImpact(with: image)
        } else {
            viewModel.shareImpact()
        }
    }
    
    private func shareToSelectedPlatform() {
        // Setup the caption text
        impactMessage = isUsingCustomCaption ? customCaption : captionTemplates[selectedCaptionIndex]
        
        if viewModel.selectedPlatform != nil {
            // You could add platform specific sharing logic here
            showingShareSheet = true
        }
    }
    
    private func prepareAndShare() {
        // Set showingShareSheet to true to present the share sheet
        showingShareSheet = true
    }
    
    private var captionPickerView: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Toggle between template and custom caption
                Picker("Caption Type", selection: $isUsingCustomCaption) {
                    Text("Templates").tag(false)
                    Text("Custom").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                if isUsingCustomCaption {
                    // Custom caption editor
                    VStack(alignment: .leading) {
                        Text("Write your own message")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        TextEditor(text: $customCaption)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .frame(height: 150)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                } else {
                    // Template caption selector
                    VStack(alignment: .leading) {
                        Text("Choose a template")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(0..<captionTemplates.count, id: \.self) { index in
                                    Button {
                                        selectedCaptionIndex = index
                                    } label: {
                                        Text(captionTemplates[index])
                                            .padding()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(selectedCaptionIndex == index ? Color.blue.opacity(0.1) : Color(.systemGray6))
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(selectedCaptionIndex == index ? Color.blue : Color.clear, lineWidth: 1)
                                            )
                                            .foregroundColor(.primary)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.vertical)
            .navigationTitle("Edit Caption")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("SKIP FOR DEMO") {
                        showingCaptionPicker = false
                    }
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(Color.orange)
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingCaptionPicker = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showingCaptionPicker = false
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
    
    // Caption and sharing UI elements
    private var shareCaptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Share Your Story")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button {
                    showingCaptionPicker = true
                } label: {
                    HStack(spacing: 4) {
                        Text("Edit")
                            .font(.subheadline)
                        Image(systemName: "pencil")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                }
            }
            
            // Caption display
            Text(isUsingCustomCaption ? customCaption : captionTemplates[selectedCaptionIndex])
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(12)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
    
    private func shareItems() -> [Any] {
        var items: [Any] = []
        
        // Add the caption text
        let caption = isUsingCustomCaption ? customCaption : captionTemplates[selectedCaptionIndex]
        items.append(caption)
        
        // Add the image if available
        if let image = selectedImage {
            items.append(image)
        }
        
        return items
    }
}

struct PlatformPickerView: View {
    @ObservedObject var viewModel: SocialSharingViewModel
    @Environment(\.dismiss) private var dismiss
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("SKIP FOR DEMO") {
                    dismiss()
                }
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.vertical, 16)
                .padding(.horizontal, 24)
                .background(Color.orange)
                .cornerRadius(15)
                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                .padding()
            }
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(SocialSharingViewModel.SocialPlatform.allCases, id: \.self) { platform in
                    PlatformButton(
                        platform: platform,
                        isSelected: viewModel.selectedPlatforms.contains(platform),
                        action: { viewModel.togglePlatform(platform) }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

struct PlatformButton: View {
    let platform: SocialSharingViewModel.SocialPlatform
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? platform.color : Color.clear)
                        .overlay(
                            Circle()
                                .strokeBorder(platform.color, lineWidth: 2)
                        )
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: platform.iconName)
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? .white : platform.color)
                }
                
                Text(platform.rawValue)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Using the shared ShareSheet implementation from the codebase
// This avoids duplicate declaration errors

extension SocialSharingViewModel {
    struct CardStyle {
        let gradient: LinearGradient
    }
    
    var cardStyles: [CardStyle] {
        [
            CardStyle(gradient: LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)),
            CardStyle(gradient: LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing)),
            CardStyle(gradient: LinearGradient(colors: [.green, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)),
            CardStyle(gradient: LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)),
            CardStyle(gradient: LinearGradient(colors: [.black, .gray], startPoint: .topLeading, endPoint: .bottomTrailing))
        ]
    }
    
    var storyBackgrounds: [Image] {
        [
            Image(systemName: "photo"),
            Image(systemName: "photo"),
            Image(systemName: "photo"),
            Image(systemName: "photo"),
            Image(systemName: "photo")
        ]
    }
    
    func formatImpactMessage(impact: Impact) -> String {
        var message = """
        🎉 My Impact at Our Big Kitchen:
        🍽 \(impact.mealsProvided) meals provided
        ⏰ \(impact.hoursContributed) hours contributed
        💝 \(impact.peopleHelped) people helped
        """
        
        if let mealsMade = impact.mealsMade, let _ = impact.timeSpent {
            message += "\n👩‍🍳 \(mealsMade) meals made"
            message += "\n🌱 \(String(format: "%.1f", impact.foodWasteSaved)) kg food waste saved"
            message += "\n🗑️ \(String(format: "%.1f", impact.foodWasteSaved)) kg food saved from landfill"
        }
        
        message += "\n♻️ \(String(format: "%.1f", impact.carbonSaved)) kg of CO2 saved"
        message += "\nJoin me in making a difference! #OurBigKitchen #Community"
        
        return message
    }
}

#Preview {
    NavigationView {
        SocialSharingView()
    }
}