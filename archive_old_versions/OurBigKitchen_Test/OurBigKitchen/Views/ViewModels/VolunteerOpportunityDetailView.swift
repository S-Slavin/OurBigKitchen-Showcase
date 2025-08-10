//
//  VolunteerOpportunityDetailView.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//


import SwiftUI

struct VolunteerOpportunityDetailView: View {
    let event: Event
    @State private var isRegistering = false
    @State private var showingConfirmation = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Image
                if let imageURL = event.imageURL {
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(height: 200)
                    .clipped()
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    // Title and Category
                    VStack(alignment: .leading, spacing: 8) {
                        Text(event.title)
                            .font(.title2)
                            .bold()
                        
                        Text(event.type.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Details
                    VStack(alignment: .leading, spacing: 12) {
                        DetailRow(icon: "calendar", title: "Date", value: event.startDate.formatted(date: .long, time: .shortened))
                        DetailRow(icon: "clock", title: "Duration", value: formatDuration(event.duration))
                        DetailRow(icon: "mappin.and.ellipse", title: "Location", value: event.location)
                        DetailRow(icon: "person.2.fill", title: "Spots Available", value: "\(event.spotsRemaining) of \(event.maxVolunteers)")
                    }
                    
                    // Description
                    Text("About")
                        .font(.headline)
                    
                    Text(event.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { isRegistering = true }) {
                    Text("Register")
                }
                .disabled(event.isFull)
            }
        }
        .alert("Confirm Registration", isPresented: $isRegistering) {
            Button("Cancel", role: .cancel) { }
            Button("Register") {
                showingConfirmation = true
                dismiss()
            }
        } message: {
            Text("Would you like to register for this volunteer opportunity?")
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration / 3600)
        return "\(hours) hour\(hours == 1 ? "" : "s")"
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Label(title, systemImage: icon)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .foregroundColor(.primary)
        }
    }
}