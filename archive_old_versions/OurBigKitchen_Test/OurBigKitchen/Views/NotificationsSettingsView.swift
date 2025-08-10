//
//  NotificationsSettingsView.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//

import SwiftUI

struct NotificationsSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = NotificationsViewModel()
    @State private var showingSaveAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Master toggle for all notifications
                VStack(alignment: .leading, spacing: 16) {
                    toggleCard(
                        title: "Push Notifications",
                        description: "Enable or disable all notifications from Our Big Kitchen",
                        isOn: $viewModel.pushNotificationsEnabled
                    )
                    
                    if viewModel.pushNotificationsEnabled {
                        // Section for event notifications
                        notificationSection(
                            title: "Event Notifications",
                            toggles: [
                                ("Upcoming events", $viewModel.upcomingEventsEnabled),
                                ("Event reminders", $viewModel.eventRemindersEnabled),
                                ("New opportunities", $viewModel.newOpportunitiesEnabled),
                                ("Last-minute help needed", $viewModel.lastMinuteHelpEnabled)
                            ]
                        )
                        
                        // Section for social notifications
                        notificationSection(
                            title: "Social Notifications",
                            toggles: [
                                ("Impact milestones", $viewModel.impactMilestonesEnabled),
                                ("Friend activities", $viewModel.friendActivitiesEnabled),
                                ("Community news", $viewModel.communityNewsEnabled)
                            ]
                        )
                    }
                }
                
                Divider()
                    .padding(.vertical, 8)
                
                // Email notification settings
                VStack(alignment: .leading, spacing: 16) {
                    toggleCard(
                        title: "Email Notifications",
                        description: "Receive updates and news via email",
                        isOn: $viewModel.emailNotificationsEnabled
                    )
                    
                    if viewModel.emailNotificationsEnabled {
                        // Email frequency selection
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Email Frequency")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            VStack(spacing: 0) {
                                ForEach(NotificationsViewModel.EmailFrequency.allCases, id: \.self) { frequency in
                                    RadioButton(
                                        title: frequency.displayName,
                                        isSelected: viewModel.emailFrequency == frequency,
                                        action: { viewModel.emailFrequency = frequency }
                                    )
                                    
                                    if frequency != .never && frequency != NotificationsViewModel.EmailFrequency.allCases.last {
                                        Divider()
                                            .padding(.horizontal)
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color(.systemBackground))
                            )
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        }
                        
                        // Email content selection
                        notificationSection(
                            title: "Email Content",
                            toggles: [
                                ("Weekly newsletter", $viewModel.weeklyNewsletterEnabled),
                                ("Impact reports", $viewModel.impactReportsEnabled),
                                ("Special events", $viewModel.specialEventsEmailsEnabled)
                            ]
                        )
                    }
                }
                
                // Save button
                Button {
                    showingSaveAlert = true
                } label: {
                    Text("Save Preferences")
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
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Save Changes", isPresented: $showingSaveAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Save") {
                viewModel.savePreferences()
                dismiss()
            }
        } message: {
            Text("Save notification preferences?")
        }
        .onAppear {
            viewModel.loadPreferences()
        }
    }
    
    // MARK: - Helper Views
    
    private func notificationSection(title: String, toggles: [(String, Binding<Bool>)]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                ForEach(0..<toggles.count, id: \.self) { index in
                    Toggle(toggles[index].0, isOn: toggles[index].1)
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                    
                    if index < toggles.count - 1 {
                        Divider()
                            .padding(.horizontal)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.systemBackground))
            )
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
    }
    
    private func toggleCard(title: String, description: String, isOn: Binding<Bool>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: isOn)
                    .labelsHidden()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Radio Button Component

struct RadioButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - View Model

class NotificationsViewModel: ObservableObject {
    // Push notification settings
    @Published var pushNotificationsEnabled = true
    @Published var upcomingEventsEnabled = true
    @Published var eventRemindersEnabled = true
    @Published var newOpportunitiesEnabled = true
    @Published var lastMinuteHelpEnabled = false
    @Published var impactMilestonesEnabled = true
    @Published var friendActivitiesEnabled = false
    @Published var communityNewsEnabled = true
    
    // Email notification settings
    @Published var emailNotificationsEnabled = true
    @Published var emailFrequency: EmailFrequency = .weekly
    @Published var weeklyNewsletterEnabled = true
    @Published var impactReportsEnabled = true
    @Published var specialEventsEmailsEnabled = true
    
    enum EmailFrequency: String, CaseIterable {
        case daily = "daily"
        case weekly = "weekly"
        case monthly = "monthly"
        case never = "never"
        
        var displayName: String {
            switch self {
            case .daily: return "Daily"
            case .weekly: return "Weekly"
            case .monthly: return "Monthly"
            case .never: return "Never"
            }
        }
    }
    
    func loadPreferences() {
        // In a real app, this would load from UserDefaults or backend
        // Using default values for now
    }
    
    func savePreferences() {
        // In a real app, this would save to UserDefaults or backend
        print("Saving notification preferences")
    }
}

#Preview {
    NavigationStack {
        NotificationsSettingsView()
    }
} 