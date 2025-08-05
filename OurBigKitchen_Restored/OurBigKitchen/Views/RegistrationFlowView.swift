import SwiftUI
import Combine

struct RegistrationFlowView: View {
    @StateObject private var viewModel: RegistrationFlowViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(mockService: RegistrationService? = nil, preselectedUserType: RegistrationFlowViewModel.UserType? = nil) {
        let vm = RegistrationFlowViewModel(registrationService: mockService ?? RegistrationService())
        
        // Set a default user type and start at personal details (step 1)
        vm.selectedUserType = preselectedUserType ?? .individual
        vm.currentStep = 1 // Skip volunteer type selection - users already chose
        
        _viewModel = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Demo navigation button - bigger on top as requested
                HStack {
                    Spacer()
                    Button("NEXT →") {
                        if viewModel.currentStep < viewModel.totalSteps - 1 {
                            withAnimation { viewModel.currentStep += 1 }
                        } else {
                            dismiss() // Only dismiss at the very end
                        }
                    }
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(Color.orange)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Step indicator
                HStack(spacing: 4) {
                    ForEach(0..<viewModel.totalSteps, id: \.self) { step in
                        Capsule()
                            .fill(step <= viewModel.currentStep ? Color.accentColor : Color.gray.opacity(0.3))
                            .frame(height: 6)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.top, 24)
                .padding(.horizontal)
                
                Spacer(minLength: 16)
                
                // Step content
                Group {
                    switch viewModel.currentStep {
                    case 0:
                        // User type selection
                        VStack(spacing: 24) {
                            Text("Step 1: Who are you registering as?")
                                .font(.title2.bold())
                                .padding(.bottom, 8)
                            Text("Please select your registration type. This helps us tailor the onboarding process for you.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            HStack(spacing: 24) {
                                ForEach(RegistrationFlowViewModel.UserType.allCases) { type in
                                    Button(action: {
                                        viewModel.selectedUserType = type
                                    }) {
                                        VStack(spacing: 10) {
                                            Image(systemName: type == .individual ? "person.crop.circle" : "person.3.sequence.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 48, height: 48)
                                                .foregroundColor(viewModel.selectedUserType == type ? .accentColor : .gray)
                                            Text(type.rawValue)
                                                .font(.headline)
                                                .foregroundColor(viewModel.selectedUserType == type ? .accentColor : .primary)
                                        }
                                        .padding()
                                        .frame(maxWidth: 160)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(viewModel.selectedUserType == type ? Color.accentColor.opacity(0.15) : Color(.systemGray6))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(viewModel.selectedUserType == type ? Color.accentColor : Color.clear, lineWidth: 2)
                                        )
                                    }
                                    .accessibilityLabel(type.rawValue)
                                }
                            }
                        }
                        .padding(.top, 32)
                        .padding(.horizontal)
                    case 1:
                        // Personal details
                        ScrollView {
                            VStack(spacing: 20) {
                                Text("Step 1: Personal Details")
                                    .font(.title2.bold())
                                    .padding(.bottom, 8)
                                
                                VStack(spacing: 16) {
                                    TextField("First Name", text: $viewModel.firstName)
                                        .autocapitalization(.words)
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                    TextField("Last Name", text: $viewModel.lastName)
                                        .autocapitalization(.words)
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                    TextField("Email", text: $viewModel.email)
                                        .keyboardType(.emailAddress)
                                        .textContentType(.emailAddress)
                                        .autocapitalization(.none)
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                    TextField("Phone", text: $viewModel.mobile)
                                        .keyboardType(.phonePad)
                                        .textContentType(.telephoneNumber)
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                    DatePicker("Date of Birth", selection: $viewModel.dob, displayedComponents: .date)
                                        .datePickerStyle(.compact)
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                    TextField("Address", text: $viewModel.address)
                                        .autocapitalization(.words)
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                    TextField("City", text: $viewModel.city)
                                        .autocapitalization(.words)
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                    TextField("State", text: $viewModel.state)
                                        .autocapitalization(.words)
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                    TextField("Postal Code", text: $viewModel.postalCode)
                                        .keyboardType(.numberPad)
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                    TextField("Emergency Contact Name", text: $viewModel.emergencyName)
                                        .autocapitalization(.words)
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                    TextField("Contact Phone", text: $viewModel.emergencyPhone)
                                        .keyboardType(.phonePad)
                                        .textContentType(.telephoneNumber)
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                    if viewModel.selectedUserType == .corporate {
                                        Divider()
                                        TextField("Company Name", text: $viewModel.companyName)
                                            .autocapitalization(.words)
                                            .padding()
                                            .background(Color(.systemGray6))
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 16)
                        }
                    case 2:
                        // WWCC details
                        VStack(spacing: 24) {
                            Text("Step 2: Working With Children Check (WWCC)")
                                .font(.title2.bold())
                                .padding(.bottom, 8)
                            if viewModel.isOver18 {
                                Text("If you are 18 years or older, you must provide a valid Working With Children Check (WWCC) to volunteer.")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                TextField("WWCC Number", text: $viewModel.wwcNumber)
                                    .keyboardType(.default)
                                    .autocapitalization(.allCharacters)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                DatePicker("WWCC Expiry Date", selection: $viewModel.wwcExpiry, displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                VStack(alignment: .leading, spacing: 6) {
                                    Link("Apply for a WWCC", destination: URL(string: "https://www.service.nsw.gov.au/transaction/apply-for-a-working-with-children-check")!)
                                    Link("Update or change name", destination: URL(string: "https://www.kidsguardian.nsw.gov.au/child-safe-organisations/working-with-children-check/apply")!)
                                    Link("Recover WWCC number", destination: URL(string: "https://www.kidsguardian.nsw.gov.au/child-safe-organisations/working-with-children-check/apply")!)
                                }
                                .font(.footnote)
                                .foregroundColor(.blue)
                                .padding(.top, 4)
                            } else {
                                Text("You are under 18. WWCC is not required.")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 32)
                    case 3:
                        // Additional info
                        ScrollView {
                            VStack(spacing: 24) {
                                Text("Step 3: Additional Information")
                                    .font(.title2.bold())
                                    .padding(.bottom, 8)
                                
                                VStack(spacing: 16) {
                                    Text("Dietary Restrictions")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    TextField("Any dietary restrictions or allergies", text: $viewModel.dietaryRestrictions)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                    
                                    Text("Medical Conditions")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    TextField("Any medical conditions we should be aware of", text: $viewModel.medicalConditions)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                    
                                    Text("Volunteer Experience")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    TextField("Previous volunteer experience (optional)", text: $viewModel.volunteerExperience)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                    
                                    Text("Skills")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    TextField("Cooking skills, languages, etc. (optional)", text: $viewModel.skills)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                    
                                    Text("Availability")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    TextField("Preferred days/times to volunteer", text: $viewModel.availability)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                    
                                    Text("Motivation")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    TextField("Why do you want to volunteer with us?", text: $viewModel.motivation)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 16)
                        }
                    case 4:
                        // Review and submit
                        ScrollView {
                            VStack(spacing: 24) {
                                Text("Step 4: Review Your Information")
                                    .font(.title2.bold())
                                    .padding(.bottom, 8)
                                
                                VStack(spacing: 16) {
                                    // Personal details review
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Personal Details")
                                            .font(.headline)
                                            .foregroundColor(.accentColor)
                                        Text("Name: \(viewModel.firstName) \(viewModel.lastName)")
                                        Text("Email: \(viewModel.email)")
                                        Text("Phone: \(viewModel.mobile)")
                                        Text("Date of Birth: \(viewModel.dob, formatter: dateFormatter)")
                                        Text("Address: \(viewModel.address)")
                                        Text("City: \(viewModel.city), \(viewModel.state) \(viewModel.postalCode)")
                                        if !viewModel.companyName.isEmpty {
                                            Text("Company: \(viewModel.companyName)")
                                        }
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                    
                                    // WWCC review
                                    if viewModel.isOver18 {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("WWCC Information")
                                                .font(.headline)
                                                .foregroundColor(.accentColor)
                                            Text("WWCC Number: \(viewModel.wwcNumber)")
                                            Text("Expiry Date: \(viewModel.wwcExpiry, formatter: dateFormatter)")
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                    }
                                    
                                    // Additional info review
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Additional Information")
                                            .font(.headline)
                                            .foregroundColor(.accentColor)
                                        if !viewModel.dietaryRestrictions.isEmpty {
                                            Text("Dietary Restrictions: \(viewModel.dietaryRestrictions)")
                                        }
                                        if !viewModel.medicalConditions.isEmpty {
                                            Text("Medical Conditions: \(viewModel.medicalConditions)")
                                        }
                                        if !viewModel.volunteerExperience.isEmpty {
                                            Text("Volunteer Experience: \(viewModel.volunteerExperience)")
                                        }
                                        if !viewModel.skills.isEmpty {
                                            Text("Skills: \(viewModel.skills)")
                                        }
                                        if !viewModel.availability.isEmpty {
                                            Text("Availability: \(viewModel.availability)")
                                        }
                                        if !viewModel.motivation.isEmpty {
                                            Text("Motivation: \(viewModel.motivation)")
                                        }
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                    
                                    // Submit button
                                    Button(action: viewModel.submitRegistration) {
                                        HStack {
                                            if viewModel.isSubmitting {
                                                ProgressView()
                                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                    .padding(.trailing, 8)
                                            }
                                            Text(viewModel.isSubmitting ? "Submitting..." : "Submit Registration")
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(viewModel.isReviewValid ? Color.accentColor : Color.gray)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                    }
                                    .disabled(!viewModel.isReviewValid || viewModel.isSubmitting)
                                    
                                    if viewModel.showSuccessMessage {
                                        HStack {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                            Text("Registration submitted successfully!")
                                                .foregroundColor(.green)
                                        }
                                        .padding()
                                        .background(Color.green.opacity(0.1))
                                        .cornerRadius(8)
                                    }
                                    
                                    if let errorMessage = viewModel.errorMessage {
                                        HStack {
                                            Image(systemName: "exclamationmark.triangle.fill")
                                                .foregroundColor(.red)
                                            Text(errorMessage)
                                                .foregroundColor(.red)
                                        }
                                        .padding()
                                        .background(Color.red.opacity(0.1))
                                        .cornerRadius(8)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .padding(.top, 32)
                        }
                    default:
                        EmptyView()
                    }
                }
                .frame(maxHeight: .infinity)
                
                Spacer(minLength: 16)
                
                // Navigation buttons
                HStack {
                    if viewModel.currentStep > 0 {
                        Button("Back") {
                            withAnimation { viewModel.currentStep -= 1 }
                        }
                        .padding()
                    }
                    Spacer()
                    if viewModel.currentStep == 0 {
                        Button("Next") {
                            withAnimation { viewModel.currentStep += 1 }
                        }
                        .padding()
                        .disabled(viewModel.selectedUserType == nil)
                    } else if viewModel.currentStep < viewModel.totalSteps - 1 {
                        Button("Next") {
                            withAnimation { viewModel.currentStep += 1 }
                        }
                        .padding()
                        .disabled(!viewModel.isPersonalDetailsValid)
                    } else {
                        Button("Finish") {
                            // TODO: Handle final submission
                        }
                        .padding()
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .navigationTitle("Volunteer Registration")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
}

#Preview {
    RegistrationFlowView()
} 