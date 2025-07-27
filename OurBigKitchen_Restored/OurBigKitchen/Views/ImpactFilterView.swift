//
//  ImpactFilterView.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//

import SwiftUI
import UIKit

struct ImpactFilterView: View {
    @ObservedObject var viewModel: ImpactFilterViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showCameraSheet = false
    @State private var selfieImage: UIImage?
    
    // Filter options
    private let filterSets = [
        "Classic", "Vibrant", "Minimal", "Community", "Monochrome"
    ]
    
    private let backgroundOptions = [
        "Solid Color", "Gradient", "Pattern", "Photo"
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Preview section
                    previewSection
                    
                    // Camera/Selfie Section
                    selfieSection
                    
                    // Filter sets
                    filterSetsSection
                    
                    // Background options
                    backgroundSection
                    
                    // Color customization
                    colorSection
                    
                    // Text options
                    textOptionsSection
                    
                    // Apply button
                    Button {
                        viewModel.applyFilter(withSelfie: selfieImage)
                        dismiss()
                    } label: {
                        Text("Apply and Share")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    // Skip button
                    Button {
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 24))
                            Text("SKIP FOR DEMO")
                                .font(.title)
                                .fontWeight(.black)
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 24)
                        .padding(.horizontal, 36)
                        .background(Color.orange)
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white, lineWidth: 2)
                        )
                    }
                    .padding(.top, 30)
                    .padding(.bottom, 20)
                }
                .padding()
            }
            .navigationTitle("Impact Filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Reset") {
                        viewModel.resetFilter()
                        selfieImage = nil
                    }
                }
            }
            .sheet(isPresented: $showCameraSheet) {
                VStack {
                    HStack {
                        Spacer()
                        Button("SKIP FOR DEMO") {
                            showCameraSheet = false
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
                    
                    CameraView(image: $selfieImage, isShown: $showCameraSheet)
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
    }
    
    // MARK: - Selfie Section
    
    private var selfieSection: some View {
        VStack(spacing: 12) {
            Text("Take a Selfie")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack {
                if let selfie = selfieImage {
                    Image(uiImage: selfie)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            Button(action: { selfieImage = nil }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .shadow(radius: 2)
                            }
                            .padding(8),
                            alignment: .topTrailing
                        )
                } else {
                    Button {
                        showCameraSheet = true
                    } label: {
                        VStack {
                            Image(systemName: "camera.fill")
                                .font(.largeTitle)
                                .padding()
                            
                            Text("Tap to take a selfie")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 150)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 5)
            )
        }
    }
    
    // MARK: - Preview Section
    
    private var previewSection: some View {
        VStack(spacing: 16) {
            Text("Preview")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ZStack {
                // Background
                Rectangle()
                    .fill(viewModel.selectedBackgroundColor)
                    .cornerRadius(12)
                
                // Impact card
                VStack(spacing: 16) {
                    Text("Your Impact")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(viewModel.selectedTextColor)
                    
                    // Overlay selfie if available
                    if let selfie = selfieImage {
                        Image(uiImage: selfie)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .padding(.horizontal)
                            .opacity(0.85)
                            .overlay(
                                Text("Your Impact")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .shadow(radius: 2),
                                alignment: .bottom
                            )
                    }
                    
                    HStack(spacing: 20) {
                        impactPreviewItem(
                            value: "\(viewModel.impact.mealsProvided)",
                            label: "Meals",
                            icon: "fork.knife",
                            color: viewModel.accentColors[0]
                        )
                        
                        impactPreviewItem(
                            value: "\(viewModel.impact.hoursContributed)",
                            label: "Hours",
                            icon: "clock.fill",
                            color: viewModel.accentColors[1]
                        )
                        
                        impactPreviewItem(
                            value: "\(viewModel.impact.peopleHelped)",
                            label: "People",
                            icon: "person.2.fill",
                            color: viewModel.accentColors[2]
                        )
                    }
                    
                    // Add food waste saved and CO2 saved if meals made and time spent are entered
                    if viewModel.impact.mealsMade != nil && viewModel.impact.timeSpent != nil {
                        VStack(spacing: 12) {
                            HStack(spacing: 20) {
                                impactStatView(
                                    value: String(format: "%.1f", viewModel.impact.foodWasteSaved),
                                    label: "Food Saved (kg)",
                                    icon: "arrow.3.trianglepath",
                                    color: viewModel.accentColors[0]
                                )
                                
                                impactPreviewItem(
                                    value: String(format: "%.1f", viewModel.impact.carbonSaved),
                                    label: "kg CO2 Saved",
                                    icon: "leaf.fill",
                                    color: viewModel.accentColors[1]
                                )
                            }
                        }
                    }
                    
                    Text("Our Big Kitchen")
                        .font(.caption)
                        .foregroundColor(viewModel.selectedTextColor.opacity(0.8))
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
            .frame(height: selfieImage != nil || (viewModel.impact.mealsMade != nil) ? 380 : 200)
            .shadow(radius: 3)
        }
    }
    
    // MARK: - Filter Sets Section
    
    private var filterSetsSection: some View {
        VStack(spacing: 12) {
            Text("Filter Style")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(filterSets, id: \.self) { filter in
                        Button {
                            viewModel.applyFilterSet(filter)
                        } label: {
                            Text(filter)
                                .font(.subheadline)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(viewModel.currentFilterSet == filter ? Color.blue : Color.gray.opacity(0.2))
                                )
                                .foregroundColor(viewModel.currentFilterSet == filter ? .white : .primary)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    // MARK: - Background Section
    
    private var backgroundSection: some View {
        VStack(spacing: 12) {
            Text("Background")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                ForEach(backgroundOptions, id: \.self) { option in
                    Button {
                        viewModel.selectedBackgroundType = option
                    } label: {
                        VStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 50)
                                
                                if option == "Solid Color" {
                                    Circle()
                                        .fill(viewModel.selectedBackgroundColor)
                                        .frame(width: 30, height: 30)
                                } else if option == "Gradient" {
                                    LinearGradient(
                                        colors: [viewModel.accentColors[0], viewModel.accentColors[1]],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                } else if option == "Pattern" {
                                    Image(systemName: "square.grid.3x3")
                                        .font(.title2)
                                } else {
                                    Image(systemName: "photo")
                                        .font(.title2)
                                }
                            }
                            
                            Text(option)
                                .font(.caption)
                                .foregroundColor(viewModel.selectedBackgroundType == option ? .blue : .primary)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(viewModel.selectedBackgroundType == option ? Color.blue : Color.clear, lineWidth: 2)
                        )
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            
            // Background color picker if solid color is selected
            if viewModel.selectedBackgroundType == "Solid Color" {
                colorPickerRow(title: "Background Color", selection: $viewModel.selectedBackgroundColor)
            }
        }
    }
    
    // MARK: - Color Section
    
    private var colorSection: some View {
        VStack(spacing: 12) {
            Text("Accent Colors")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Primary accent color
            colorPickerRow(title: "Primary Accent", selection: $viewModel.accentColors[0])
            
            // Secondary accent color
            colorPickerRow(title: "Secondary Accent", selection: $viewModel.accentColors[1])
            
            // Tertiary accent color
            colorPickerRow(title: "Tertiary Accent", selection: $viewModel.accentColors[2])
            
            // Text color
            colorPickerRow(title: "Text Color", selection: $viewModel.selectedTextColor)
        }
    }
    
    // MARK: - Text Options Section
    
    private var textOptionsSection: some View {
        VStack(spacing: 12) {
            Text("Text Style")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Toggle("Bold Text", isOn: $viewModel.boldText)
            Toggle("Show Logo", isOn: $viewModel.showLogo)
            
            Stepper("Text Size: \(Int(viewModel.textSizeMultiplier * 100))%", 
                    value: $viewModel.textSizeMultiplier,
                    in: 0.7...1.3,
                    step: 0.1)
        }
    }
    
    // MARK: - Supporting Views
    
    private func impactPreviewItem(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.system(
                    size: 16 * viewModel.textSizeMultiplier,
                    weight: viewModel.boldText ? .bold : .regular
                ))
                .foregroundColor(viewModel.selectedTextColor)
            
            Text(label)
                .font(.system(
                    size: 12 * viewModel.textSizeMultiplier,
                    weight: .regular
                ))
                .foregroundColor(viewModel.selectedTextColor.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
    }
    
    private func impactStatView(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.system(
                    size: 16 * viewModel.textSizeMultiplier,
                    weight: viewModel.boldText ? .bold : .regular
                ))
                .foregroundColor(viewModel.selectedTextColor)
            
            Text(label)
                .font(.system(
                    size: 12 * viewModel.textSizeMultiplier,
                    weight: .regular
                ))
                .foregroundColor(viewModel.selectedTextColor.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
    }
    
    private func colorPickerRow(title: String, selection: Binding<Color>) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            
            Spacer()
            
            ColorPicker("", selection: selection)
                .labelsHidden()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Camera View
struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isShown: Bool
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.cameraDevice = .front
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.image = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.image = originalImage
            }
            
            parent.isShown = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isShown = false
        }
    }
}

// MARK: - Preview
#Preview {
    ImpactFilterView(viewModel: ImpactFilterViewModel(impact: Impact.empty))
} 