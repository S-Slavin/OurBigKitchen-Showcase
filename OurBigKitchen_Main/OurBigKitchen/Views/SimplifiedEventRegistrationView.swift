import SwiftUI
import EventKit

struct SimplifiedEventRegistrationView: View {
    let event: Event
    let onComplete: (Bool) -> Void
    
    @State private var adultCount: Int = 1
    @State private var childCount: Int = 0
    @State private var isSubmitting: Bool = false
    @State private var errorMessage: String? = nil
    @State private var showingCalendarPermission: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header with event info
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Registration for:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(event.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.blue)
                            
                            Text(event.formattedDateRange)
                                .font(.subheadline)
                        }
                        
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(.red)
                            
                            Text(event.location)
                                .font(.subheadline)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Participant count section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("How Many Participants?")
                            .font(.headline)
                        
                        HStack {
                            Text("Adults")
                                .frame(width: 100, alignment: .leading)
                            
                            Spacer()
                            
                            Button(action: { if adultCount > 1 { adultCount -= 1 } }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(adultCount > 1 ? .blue : .gray)
                                    .font(.title2)
                            }
                            .disabled(adultCount <= 1)
                            
                            Text("\(adultCount)")
                                .font(.headline)
                                .frame(width: 40, alignment: .center)
                            
                            Button(action: { adultCount += 1 }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.title2)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        
                        HStack {
                            Text("Children")
                                .frame(width: 100, alignment: .leading)
                            
                            Spacer()
                            
                            Button(action: { if childCount > 0 { childCount -= 1 } }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(childCount > 0 ? .blue : .gray)
                                    .font(.title2)
                            }
                            .disabled(childCount <= 0)
                            
                            Text("\(childCount)")
                                .font(.headline)
                                .frame(width: 40, alignment: .center)
                            
                            Button(action: { childCount += 1 }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.title2)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        
                        Text("Total participants: \(adultCount + childCount)")
                            .font(.headline)
                            .padding(.top, 5)
                    }
                    
                    // Requirements section if any exist
                    if !event.requirements.isEmpty {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Requirements")
                                .font(.headline)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(event.requirements, id: \.self) { requirement in
                                    HStack(alignment: .top) {
                                        Image(systemName: "exclamationmark.circle")
                                            .foregroundColor(.orange)
                                            .font(.system(size: 14))
                                        
                                        Text(requirement)
                                            .font(.subheadline)
                                    }
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                    
                    // Cancellation policy info
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Cancellation Policy")
                            .font(.headline)
                        
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                                .font(.system(size: 16))
                            
                            Text("Please note that we require 24 hours notice for cancellations. This helps us plan our events effectively and give others a chance to participate.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Add to Calendar button
                    Button(action: addToCalendar) {
                        HStack {
                            Image(systemName: "calendar.badge.plus")
                                .font(.headline)
                            Text("Add to Calendar")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                    }
                    
                    // Error message
                    if let error = errorMessage {
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .padding(.top, 5)
                    }
                    
                    // Submit button
                    Button(action: submitRegistration) {
                        if isSubmitting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Submit Registration")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(isFormValid ? Color.blue : Color.gray)
                    .cornerRadius(10)
                    .disabled(!isFormValid || isSubmitting)
                    .padding(.top, 10)
                }
                .padding()
            }
            .navigationTitle("Register for Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onComplete(false)
                    }
                }
            }
            .alert("Calendar Access", isPresented: $showingCalendarPermission) {
                Button("Settings", role: .none) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please allow calendar access in your device settings to save this event.")
            }
        }
    }
    
    private var isFormValid: Bool {
        (adultCount + childCount) > 0
    }
    
    private func submitRegistration() {
        guard isFormValid else {
            errorMessage = "Please select at least one participant"
            return
        }
        
        isSubmitting = true
        errorMessage = nil
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isSubmitting = false
            
            // In a real app, we would call a service to submit the registration
            // For now, just simulate a successful submission
            onComplete(true)
        }
    }
    
    private func addToCalendar() {
        let eventStore = EKEventStore()
        
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized, .fullAccess, .writeOnly:
            createCalendarEvent(store: eventStore)
        case .notDetermined:
            eventStore.requestAccess(to: .event) { granted, error in
                if granted {
                    DispatchQueue.main.async {
                        createCalendarEvent(store: eventStore)
                    }
                } else {
                    DispatchQueue.main.async {
                        showingCalendarPermission = true
                    }
                }
            }
        case .denied, .restricted:
            showingCalendarPermission = true
        @unknown default:
            showingCalendarPermission = true
        }
    }
    
    private func createCalendarEvent(store: EKEventStore) {
        let calendarEvent = EKEvent(eventStore: store)
        calendarEvent.title = event.title
        calendarEvent.startDate = event.startDate
        calendarEvent.endDate = event.endDate
        calendarEvent.notes = event.description
        calendarEvent.location = event.location
        
        calendarEvent.calendar = store.defaultCalendarForNewEvents
        
        do {
            try store.save(calendarEvent, span: .thisEvent)
            
            // Show a temporary success message
            errorMessage = "Event successfully added to your calendar"
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if errorMessage == "Event successfully added to your calendar" {
                    errorMessage = nil
                }
            }
        } catch {
            errorMessage = "Could not save to calendar: \(error.localizedDescription)"
        }
    }
}

#Preview {
    SimplifiedEventRegistrationView(event: Event.sampleEvents[0], onComplete: { _ in })
} 