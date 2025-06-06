import SwiftUI

struct EventFormView: View {
    enum FormMode {
        case create
        case edit(Event)
    }
    
    let mode: FormMode
    let onSave: (Event) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date().addingTimeInterval(7200) // 2 hours later
    @State private var location: String = ""
    @State private var maxVolunteers: Int = 10
    @State private var eventType: Event.EventType = .cooking
    @State private var organizer: String = ""
    @State private var requirements: [String] = []
    @State private var newRequirement: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Event Information")) {
                    TextField("Title", text: $title)
                    
                    VStack(alignment: .leading) {
                        Text("Description")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $description)
                            .frame(minHeight: 100)
                            .padding(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    Picker("Event Type", selection: $eventType) {
                        ForEach(Event.EventType.allCases, id: \.self) { type in
                            Text(type.rawValue.capitalized).tag(type)
                        }
                    }
                    
                    TextField("Organizer", text: $organizer)
                }
                
                Section(header: Text("Date and Time")) {
                    DatePicker("Start Date", selection: $startDate)
                    
                    DatePicker("End Date", selection: $endDate)
                        .onChange(of: startDate) { newValue in
                            if endDate < newValue {
                                endDate = newValue.addingTimeInterval(7200) // 2 hours later
                            }
                        }
                }
                
                Section(header: Text("Location")) {
                    TextField("Location", text: $location)
                }
                
                Section(header: Text("Volunteer Capacity")) {
                    Stepper("Maximum Volunteers: \(maxVolunteers)", value: $maxVolunteers, in: 1...100)
                }
                
                Section(header: Text("Requirements")) {
                    ForEach(requirements.indices, id: \.self) { index in
                        HStack {
                            Text(requirements[index])
                            
                            Spacer()
                            
                            Button(action: {
                                requirements.remove(at: index)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    HStack {
                        TextField("Add requirement", text: $newRequirement)
                        
                        Button(action: addRequirement) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                        .disabled(newRequirement.isEmpty)
                    }
                }
            }
            .navigationTitle(isEditMode ? "Edit Event" : "Create Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditMode ? "Save" : "Create") {
                        saveEvent()
                    }
                    .disabled(!isFormValid)
                }
            }
            .onAppear {
                if case .edit(let event) = mode {
                    // Populate the form with existing event data
                    title = event.title
                    description = event.description
                    startDate = event.startDate
                    endDate = event.endDate
                    location = event.location
                    maxVolunteers = event.maxVolunteers
                    eventType = event.type
                    organizer = event.organizer
                    requirements = event.requirements
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Invalid Form"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private var isEditMode: Bool {
        if case .edit = mode {
            return true
        }
        return false
    }
    
    private var isFormValid: Bool {
        !title.isEmpty &&
        !description.isEmpty &&
        !location.isEmpty &&
        !organizer.isEmpty &&
        endDate > startDate
    }
    
    private func addRequirement() {
        guard !newRequirement.isEmpty else { return }
        
        requirements.append(newRequirement)
        newRequirement = ""
    }
    
    private func validateForm() -> Bool {
        if title.isEmpty {
            alertMessage = "Please enter a title for the event."
            showAlert = true
            return false
        }
        
        if description.isEmpty {
            alertMessage = "Please enter a description for the event."
            showAlert = true
            return false
        }
        
        if location.isEmpty {
            alertMessage = "Please enter a location for the event."
            showAlert = true
            return false
        }
        
        if organizer.isEmpty {
            alertMessage = "Please enter an organizer for the event."
            showAlert = true
            return false
        }
        
        if endDate <= startDate {
            alertMessage = "End date must be after start date."
            showAlert = true
            return false
        }
        
        return true
    }
    
    private func saveEvent() {
        guard validateForm() else { return }
        
        let newEvent: Event
        
        if case .edit(let existingEvent) = mode {
            // Update existing event
            newEvent = Event(
                id: existingEvent.id,
                title: title,
                description: description,
                startDate: startDate,
                endDate: endDate,
                location: location,
                maxVolunteers: maxVolunteers,
                currentVolunteers: existingEvent.currentVolunteers,
                status: existingEvent.status,
                type: eventType,
                organizer: organizer,
                requirements: requirements,
                imageURL: existingEvent.imageURL
            )
        } else {
            // Create new event
            newEvent = Event(
                title: title,
                description: description,
                startDate: startDate,
                endDate: endDate,
                location: location,
                maxVolunteers: maxVolunteers,
                type: eventType,
                organizer: organizer,
                requirements: requirements
            )
        }
        
        onSave(newEvent)
        dismiss()
    }
}

#Preview("Create Mode") {
    EventFormView(mode: .create, onSave: { _ in })
}

#Preview("Edit Mode") {
    EventFormView(
        mode: .edit(Event.sampleEvents[0]),
        onSave: { _ in }
    )
} 