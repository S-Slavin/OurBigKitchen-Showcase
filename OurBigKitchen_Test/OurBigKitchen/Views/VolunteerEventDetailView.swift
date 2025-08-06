import SwiftUI

struct VolunteerEventDetailView: View {
    let event: VolunteerEvent
    @Environment(\.dismiss) private var dismiss
    @State private var isRegistering = false
    @State private var showingConfirmation = false
    
    // Warm color scheme 
    private let primaryColor = Color(red: 0.93, green: 0.46, blue: 0.12) // Orange
    private let backgroundColor = Color(red: 1.0, green: 0.98, blue: 0.94) // Cream
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header with image and category
                VStack(spacing: 0) {
                    // Image placeholder
                    ZStack {
                        Rectangle()
                            .fill(primaryColor.opacity(0.2))
                            .frame(height: 200)
                        
                        Image(systemName: "calendar.badge.clock")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(primaryColor)
                            .frame(width: 80, height: 80)
                    }
                    
                    // Category badge
                    HStack {
                        Spacer()
                        
                        Text(event.category)
                            .font(.caption)
                            .bold()
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(primaryColor)
                            .foregroundColor(.white)
                            .cornerRadius(0)
                    }
                    .offset(y: -20)
                    .padding(.trailing, 20)
                }
                
                // Title and description
                VStack(alignment: .leading, spacing: 12) {
                    Text(event.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(event.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal)
                
                // Details grid
                VStack(spacing: 15) {
                    detailRow(icon: "calendar", title: "Date", value: event.date.formatted(date: .long, time: .shortened))
                    
                    detailRow(icon: "clock", title: "Duration", value: String(format: "%.1f hours", event.duration))
                    
                    detailRow(icon: "mappin.and.ellipse", title: "Location", value: event.location)
                    
                    detailRow(icon: "person.2.fill", title: "Availability", value: "\(event.spotsAvailable) spots remaining")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Status badge
                HStack {
                    Spacer()
                    
                    if event.isRegistered {
                        Text("You're registered!")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                }
                .padding(.vertical)
                
                // Action button
                Button(action: {
                    if event.isRegistered {
                        showingConfirmation = true
                    } else {
                        isRegistering = true
                    }
                }) {
                    Text(event.isRegistered ? "Cancel Registration" : "Register Now")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(event.isRegistered ? Color.red : primaryColor)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .background(backgroundColor)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .alert("Register for Event", isPresented: $isRegistering) {
            Button("Cancel", role: .cancel) { }
            Button("Register") {
                // In a real app, this would call an API
                showingConfirmation = true
            }
        } message: {
            Text("Would you like to register for \(event.title)?")
        }
        .alert("Registration Confirmed", isPresented: $showingConfirmation) {
            Button("OK", role: .cancel) {
                dismiss()
            }
        } message: {
            Text(event.isRegistered 
                ? "Your registration has been canceled."
                : "You have successfully registered for this event. We look forward to seeing you there!")
        }
    }
    
    private func detailRow(icon: String, title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(primaryColor)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.body)
            }
            
            Spacer()
        }
    }
} 