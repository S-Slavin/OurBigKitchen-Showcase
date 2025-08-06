//
//  PersonalInformationView.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//

import SwiftUI

struct PersonalInformationView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = PersonalInfoViewModel()
    @State private var showingSaveAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile picture section
                profilePictureSection
                
                // Form fields
                VStack(spacing: 16) {
                    formField(title: "Full Name", text: $viewModel.name, placeholder: "Enter your name")
                    
                    formField(title: "Email", text: $viewModel.email, placeholder: "Enter your email")
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    
                    formField(title: "Phone", text: $viewModel.phone, placeholder: "Enter your phone number")
                        .keyboardType(.phonePad)
                    
                    formField(title: "Location", text: $viewModel.location, placeholder: "Enter your location")
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(.systemBackground))
                )
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                
                // Additional information section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Additional Information")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 16) {
                        Toggle("Available for Emergency Calls", isOn: $viewModel.isAvailableForEmergencyCalls)
                        
                        Divider()
                        
                        Toggle("Available for Last-Minute Events", isOn: $viewModel.isAvailableForLastMinuteEvents)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color(.systemBackground))
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                }
                
                // Skills section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Skills & Interests")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(viewModel.availableSkills, id: \.self) { skill in
                            Toggle(skill, isOn: Binding(
                                get: { viewModel.selectedSkills.contains(skill) },
                                set: { isSelected in
                                    if isSelected {
                                        viewModel.selectedSkills.insert(skill)
                                    } else {
                                        viewModel.selectedSkills.remove(skill)
                                    }
                                }
                            ))
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color(.systemBackground))
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                }
                
                // Save button
                Button {
                    showingSaveAlert = true
                } label: {
                    Text("Save Changes")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(10)
                }
                .padding(.top, 10)
            }
            .padding()
        }
        .navigationTitle("Personal Information")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Save Changes", isPresented: $showingSaveAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Save") {
                viewModel.saveChanges()
                dismiss()
            }
        } message: {
            Text("Save changes to your profile?")
        }
        .onAppear {
            viewModel.loadUserData()
        }
    }
    
    // MARK: - View Components
    
    private var profilePictureSection: some View {
        VStack {
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
                .padding(.bottom, 8)
            
            Button("Change Profile Picture") {
                // Would handle profile picture selection in a real app
            }
            .font(.callout)
            .foregroundColor(.blue)
        }
        .padding()
    }
    
    private func formField(title: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            TextField(placeholder, text: text)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
    }
}

// View Model
class PersonalInfoViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var phone: String = ""
    @Published var location: String = ""
    @Published var isAvailableForEmergencyCalls: Bool = false
    @Published var isAvailableForLastMinuteEvents: Bool = false
    @Published var selectedSkills: Set<String> = []
    
    let availableSkills = [
        "Cooking",
        "Food Preparation",
        "Delivery",
        "Administration",
        "Event Planning",
        "Marketing",
        "Photography",
        "Social Media"
    ]
    
    func loadUserData() {
        // In a real app, this would load from UserManager or similar
        // Using mock data for now
        name = "John Doe"
        email = "john.doe@example.com"
        phone = "0412 345 678"
        location = "Sydney, NSW"
        isAvailableForEmergencyCalls = true
        isAvailableForLastMinuteEvents = false
        selectedSkills = ["Cooking", "Food Preparation"]
    }
    
    func saveChanges() {
        // In a real app, this would save to UserManager or similar
        print("Saving user data")
    }
}

#Preview {
    NavigationStack {
        PersonalInformationView()
    }
} 