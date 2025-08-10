import SwiftUI

struct EventDetailView: View {
    let event: Event
    @State private var isRegistering: Bool = false
    @State private var showingEditSheet: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var registeredVolunteers: [AppModels.User] = []
    
    // In a real app, these would be determined by authentication
    private let isAdmin: Bool = false
    private let currentUserId: String = "user123"
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(event.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Text(event.status.rawValue.capitalized)
                            .font(.subheadline)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(statusColor.opacity(0.2))
                            .foregroundColor(statusColor)
                            .cornerRadius(8)
                    }
                    
                    HStack {
                        Text(event.type.rawValue.capitalized)
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        if let program = event.program, !program.isEmpty {
                            Spacer()
                            
                            Text(program)
                                .font(.subheadline)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(ThemeManager.Colors.primary.opacity(0.15))
                                .foregroundColor(ThemeManager.Colors.primary)
                                .cornerRadius(8)
                        }
                    }
                    
                    // Display category if available
                    if let category = event.category, !category.isEmpty {
                        HStack {
                            Image(systemName: "tag.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            
                            Text(category)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.bottom, 10)
                
                // Image (in a real app, would load from URL)
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(16/9, contentMode: .fit)
                    .overlay(
                        Image(systemName: "calendar")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                    )
                    .cornerRadius(12)
                
                // Date and time section
                VStack(alignment: .leading, spacing: 8) {
                    Label {
                        Text("Date and Time")
                            .font(.headline)
                    } icon: {
                        Image(systemName: "clock")
                            .foregroundColor(.blue)
                    }
                    
                    Text(event.formattedDateRange)
                        .font(.subheadline)
                    
                    Text("Duration: \(event.formattedDuration)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Location section
                VStack(alignment: .leading, spacing: 8) {
                    Label {
                        Text("Location")
                            .font(.headline)
                    } icon: {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(.red)
                    }
                    
                    Text(event.location)
                        .font(.subheadline)
                }
                
                // Description section
                VStack(alignment: .leading, spacing: 8) {
                    Text("About This Event")
                        .font(.headline)
                    
                    Text(event.description)
                        .font(.body)
                }
                
                // Requirements section
                if !event.requirements.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Requirements")
                            .font(.headline)
                        
                        ForEach(event.requirements, id: \.self) { requirement in
                            HStack(alignment: .top) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.system(size: 14))
                                
                                Text(requirement)
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                
                // Organizer section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Organizer")
                        .font(.headline)
                    
                    HStack {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text(String(event.organizer.prefix(1)))
                                    .foregroundColor(.primary)
                            )
                        
                        Text(event.organizer)
                            .font(.subheadline)
                    }
                }
                
                // Volunteer availability section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Volunteer Availability")
                        .font(.headline)
                    
                    HStack {
                        ProgressView(value: Double(event.currentVolunteers), total: Double(event.maxVolunteers))
                            .progressViewStyle(LinearProgressViewStyle(tint: event.isFull ? .red : .green))
                            .frame(height: 8)
                        
                        Text("\(event.currentVolunteers)/\(event.maxVolunteers)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if event.isFull {
                        Text("This event is at full capacity")
                            .font(.subheadline)
                            .foregroundColor(.red)
                    } else {
                        Text("\(event.spotsRemaining) spots remaining")
                            .font(.subheadline)
                            .foregroundColor(.green)
                    }
                }
                
                // Registered volunteer list (admin only)
                if isAdmin && !registeredVolunteers.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Registered Volunteers")
                            .font(.headline)
                        
                        ForEach(registeredVolunteers) { volunteer in
                            HStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.3))
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Text(String(volunteer.fullName.prefix(1)))
                                            .foregroundColor(.primary)
                                            .font(.caption)
                                    )
                                
                                Text(volunteer.fullName)
                                    .font(.subheadline)
                                
                                Spacer()
                                
                                if volunteer.id == currentUserId {
                                    Text("You")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.2))
                                        .foregroundColor(.blue)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                
                // Action buttons
                VStack(spacing: 12) {
                    if isUserRegistered {
                        Button(action: cancelRegistration) {
                            Text("Cancel Registration")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(height: 50)
                                .frame(maxWidth: .infinity)
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                    } else if event.status == .upcoming && !event.isFull {
                        Button(action: { isRegistering = true }) {
                            Text("Register as Volunteer")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(height: 50)
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    
                    if isAdmin {
                        Button(action: { showingEditSheet = true }) {
                            Text("Edit Event")
                                .font(.headline)
                                .foregroundColor(.blue)
                                .frame(height: 50)
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(.top, 10)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isRegistering) {
            SimplifiedEventRegistrationView(event: event) { success in
                isRegistering = false
                if success {
                    showAlert = true
                    alertTitle = "Registration Successful"
                    alertMessage = "You have successfully registered for this event."
                    
                    // In a real app, we would update the event data from the server
                    // For now, just update our local list
                    let user = AppModels.User(
                        id: currentUserId,
                        firstName: "Current",
                        lastName: "User",
                        email: "user@example.com",
                        role: .volunteer
                    )
                    registeredVolunteers.append(user)
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EventFormView(mode: .edit(event), onSave: { _ in
                // In a real app, we would save the updates to the server
                showingEditSheet = false
            })
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            // In a real app, this would fetch registered volunteers from a service
            loadRegisteredVolunteers()
        }
    }
    
    private var statusColor: Color {
        switch event.status {
        case .upcoming:
            return .blue
        case .inProgress:
            return .green
        case .completed:
            return .purple
        case .cancelled:
            return .red
        }
    }
    
    private var isUserRegistered: Bool {
        registeredVolunteers.contains { $0.id == currentUserId }
    }
    
    private func loadRegisteredVolunteers() {
        // Simulate API call with sample data
        registeredVolunteers = [
            AppModels.User(id: "user1", firstName: "Jane", lastName: "Doe", email: "jane@example.com", role: .volunteer),
            AppModels.User(id: "user2", firstName: "John", lastName: "Smith", email: "john@example.com", role: .volunteer)
        ]
    }
    
    private func cancelRegistration() {
        // In a real app, we would call a service to cancel the registration
        registeredVolunteers.removeAll { $0.id == currentUserId }
        
        showAlert = true
        alertTitle = "Registration Cancelled"
        alertMessage = "You have cancelled your registration for this event."
    }
}

struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EventDetailView(event: Event(
                id: UUID(),
                title: "Sample Event",
                description: "This is a sample event for preview purposes",
                startDate: Date(),
                endDate: Date().addingTimeInterval(7200), // 2 hours later
                location: "Sample Location",
                maxVolunteers: 10,
                currentVolunteers: 5,
                status: .upcoming,
                type: .cooking,
                organizer: "Sample Organizer",
                requirements: ["Requirement 1", "Requirement 2"],
                imageURL: nil
            ))
        }
    }
} 