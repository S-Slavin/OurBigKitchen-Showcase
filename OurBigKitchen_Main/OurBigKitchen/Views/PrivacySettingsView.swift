//
//  PrivacySettingsView.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//

import SwiftUI

struct PrivacySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = PrivacyViewModel()
    @State private var showingSaveAlert = false
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile visibility section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Profile Visibility")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        // Profile visibility toggle
                        Toggle("Show my profile to other volunteers", isOn: $viewModel.showProfileToVolunteers)
                            .padding()
                        
                        Divider()
                            .padding(.horizontal)
                        
                        // Impact stats visibility toggle
                        Toggle("Share my impact statistics", isOn: $viewModel.shareImpactStatistics)
                            .padding()
                        
                        Divider()
                            .padding(.horizontal)
                        
                        // Include in leaderboards toggle
                        Toggle("Include me in leaderboards", isOn: $viewModel.includeInLeaderboards)
                            .padding()
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(.systemBackground))
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                }
                
                // Data sharing section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Data Usage")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        // Analytics toggle
                        Toggle("Allow analytics collection", isOn: $viewModel.allowAnalytics)
                            .padding()
                        
                        Divider()
                            .padding(.horizontal)
                        
                        // Marketing toggle
                        Toggle("Allow marketing communications", isOn: $viewModel.allowMarketing)
                            .padding()
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(.systemBackground))
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                }
                
                // Location permissions section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Location Services")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        // Location permissions picker
                        Picker("Location Access", selection: $viewModel.locationPermission) {
                            ForEach(PrivacyViewModel.LocationPermission.allCases, id: \.self) { permission in
                                Text(permission.displayName).tag(permission)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(.systemBackground))
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                }
                
                // Privacy policy section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Privacy Documents")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        // Privacy policy link
                        privacyLink(
                            title: "Privacy Policy",
                            icon: "doc.text",
                            color: .blue
                        )
                        
                        Divider()
                            .padding(.horizontal)
                        
                        // Terms of service link
                        privacyLink(
                            title: "Terms of Service",
                            icon: "doc.plaintext",
                            color: .blue
                        )
                        
                        Divider()
                            .padding(.horizontal)
                        
                        // Data deletion request
                        privacyLink(
                            title: "Request Data Deletion",
                            icon: "trash",
                            color: .red,
                            action: { showingDeleteConfirmation = true }
                        )
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(.systemBackground))
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                }
                
                // Save button
                Button {
                    showingSaveAlert = true
                } label: {
                    Text("Save Privacy Settings")
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
        .navigationTitle("Privacy Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Save Changes", isPresented: $showingSaveAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Save") {
                viewModel.saveSettings()
                dismiss()
            }
        } message: {
            Text("Save privacy settings?")
        }
        .alert("Request Data Deletion", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Request Deletion", role: .destructive) {
                viewModel.requestDataDeletion()
            }
        } message: {
            Text("This will send a request to delete all your personal data. This action cannot be undone. Are you sure?")
        }
        .onAppear {
            viewModel.loadSettings()
        }
    }
    
    // MARK: - Helper Views
    
    private func privacyLink(title: String, icon: String, color: Color, action: (() -> Void)? = nil) -> some View {
        Button(action: {
            if let action = action {
                action()
            } else {
                viewModel.showPrivacyDocument(title: title)
            }
        }) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 18))
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.footnote)
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - View Model

class PrivacyViewModel: ObservableObject {
    // Profile visibility settings
    @Published var showProfileToVolunteers = true
    @Published var shareImpactStatistics = true
    @Published var includeInLeaderboards = true
    
    // Data usage settings
    @Published var allowAnalytics = true
    @Published var allowMarketing = false
    
    // Location permissions
    @Published var locationPermission: LocationPermission = .whileUsing
    
    enum LocationPermission: String, CaseIterable {
        case always = "always"
        case whileUsing = "whenInUse"
        case never = "never"
        
        var displayName: String {
            switch self {
            case .always: return "Always"
            case .whileUsing: return "While Using"
            case .never: return "Never"
            }
        }
    }
    
    func loadSettings() {
        // In a real app, this would load from UserDefaults or backend
        // Using default values for now
    }
    
    func saveSettings() {
        // In a real app, this would save to UserDefaults or backend
        print("Saving privacy settings")
    }
    
    func showPrivacyDocument(title: String) {
        // In a real app, this would show the appropriate document
        print("Showing \(title)")
    }
    
    func requestDataDeletion() {
        // In a real app, this would send a request to delete user data
        print("Requesting data deletion")
    }
}

#Preview {
    NavigationStack {
        PrivacySettingsView()
    }
} 