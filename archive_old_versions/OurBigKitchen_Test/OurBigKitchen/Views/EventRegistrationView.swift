import SwiftUI

struct EventRegistrationView: View {
    let event: Event
    let onComplete: (Bool) -> Void
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var dietaryRestrictions: String = ""
    @State private var agreedToTerms: Bool = false
    @State private var isSubmitting: Bool = false
    @State private var errorMessage: String? = nil
    
    // In a real app, these would be loaded from a saved user profile
    @State private var savedName: String = "Jane Doe"
    @State private var savedEmail: String = "jane@example.com"
    @State private var savedPhone: String = "0412 345 678"
    
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
                    
                    // Personal Information section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Personal Information")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Full Name")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextField("", text: $name)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Email")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextField("", text: $email)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Phone Number")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextField("", text: $phone)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .keyboardType(.phonePad)
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Dietary Restrictions (Optional)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextField("Vegetarian, gluten-free, allergies, etc.", text: $dietaryRestrictions)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                    }
                    
                    // Requirements section
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
                    
                    // Terms and conditions
                    Toggle(isOn: $agreedToTerms) {
                        VStack(alignment: .leading) {
                            Text("I agree to the volunteer terms and conditions")
                                .font(.subheadline)
                            
                            Text("Including liability waiver and code of conduct")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    
                    // Error message
                    if let error = errorMessage {
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .padding(.top, 5)
                    }
                    
                    // Auto-fill button
                    Button(action: autoFillForm) {
                        HStack {
                            Image(systemName: "person.fill.badge.plus")
                            Text("Use saved information")
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                    .padding(.top, 5)
                    
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
            .navigationTitle("Volunteer Registration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onComplete(false)
                    }
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !name.isEmpty && 
        !email.isEmpty && 
        !phone.isEmpty &&
        email.contains("@") && 
        agreedToTerms
    }
    
    private func autoFillForm() {
        name = savedName
        email = savedEmail
        phone = savedPhone
    }
    
    private func submitRegistration() {
        guard isFormValid else {
            errorMessage = "Please fill in all required fields and agree to the terms"
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
}

#Preview {
    EventRegistrationView(event: Event.sampleEvents[0], onComplete: { _ in })
} 