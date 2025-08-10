import SwiftUI
import Combine

struct RegistrationFlowView: View {
    @StateObject private var viewModel: RegistrationFlowViewModel
    
    init(mockService: RegistrationService? = nil) {
        _viewModel = StateObject(wrappedValue: RegistrationFlowViewModel(registrationService: mockService ?? RegistrationService()))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
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
                                Text("Step 2: Personal Details")
                                    .font(.title2.bold())
                                    .padding(.bottom, 8)
                                Text("Please enter your details. All fields are required.")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                Group {
                                    HStack(spacing: 16) {
                                        TextField("First Name", text: $viewModel.firstName)
                                            .textContentType(.givenName)
                                            .autocapitalization(.words)
                                            .padding()
                                            .background(Color(.systemGray6))
                                            .cornerRadius(8)
                                        TextField("Last Name", text: $viewModel.lastName)
                                            .textContentType(.familyName)
                                            .autocapitalization(.words)
                                            .padding()
                                            .background(Color(.systemGray6))
                                            .cornerRadius(8)
                                    }
                                    TextField("Email", text: $viewModel.email)
                                        .keyboardType(.emailAddress)
                                        .textContentType(.emailAddress)
                                        .autocapitalization(.none)
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                    TextField("Mobile Phone", text: $viewModel.mobile)
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
                                        .textContentType(.fullStreetAddress)
                                        .autocapitalization(.words)
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                    Divider()
                                    Text("Emergency Contact")
                                        .font(.headline)
                                        .padding(.top, 8)
                                    TextField("Contact Name", text: $viewModel.emergencyName)
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
                            Text("Step 3: Working With Children Check (WWCC)")
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
                                Text("Step 4: Additional Information")
                                    .font(.title2.bold())
                                    .padding(.bottom, 8)
                                Text("Please provide any additional information that will help us better support your volunteering experience.")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                
                                VStack(spacing: 20) {
                                    // Duke of Ed checkbox
                                    Toggle(isOn: $viewModel.isDukeOfEd) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Duke of Edinburgh Award")
                                                .font(.headline)
                                            Text("I am completing this for my Duke of Edinburgh Award")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                    
                                    // Referral source
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("How did you hear about us?")
                                            .font(.headline)
                                        TextField("e.g., Friend, Social Media, Website", text: $viewModel.referralSource)
                                            .padding()
                                            .background(Color(.systemGray6))
                                            .cornerRadius(8)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .padding(.top, 32)
                        }
                    case 4:
                        // Food safety training
                        ScrollView {
                            VStack(spacing: 24) {
                                Text("Step 5: Food Safety Training")
                                    .font(.title2.bold())
                                    .padding(.bottom, 8)
                                Text("Please review our food safety guidelines before proceeding.")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                
                                VStack(spacing: 20) {
                                    // Food safety text
                                    ScrollView {
                                        VStack(alignment: .leading, spacing: 16) {
                                            Group {
                                                Text("Food Safety Guidelines")
                                                    .font(.headline)
                                                    .padding(.bottom, 4)
                                                
                                                Text("1. Personal Hygiene")
                                                    .font(.subheadline.bold())
                                                Text("• Wash hands thoroughly with soap and warm water before handling food\n• Wear clean clothing and appropriate protective gear\n• Keep hair tied back and wear a hairnet\n• Cover any cuts or wounds with waterproof bandages")
                                                
                                                Text("2. Food Handling")
                                                    .font(.subheadline.bold())
                                                Text("• Use separate cutting boards for raw and cooked foods\n• Maintain proper food temperatures\n• Follow FIFO (First In, First Out) principles\n• Check expiry dates regularly")
                                                
                                                Text("3. Kitchen Safety")
                                                    .font(.subheadline.bold())
                                                Text("• Keep work surfaces clean and sanitized\n• Store food at appropriate temperatures\n• Report any equipment issues immediately\n• Follow proper cleaning procedures")
                                                
                                                Text("4. Allergen Awareness")
                                                    .font(.subheadline.bold())
                                                Text("• Be aware of common allergens\n• Prevent cross-contamination\n• Label all food items clearly\n• Report any allergy concerns immediately")
                                            }
                                            .foregroundColor(.primary)
                                        }
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                    }
                                    .frame(height: 300)
                                    
                                    // Acceptance checkbox
                                    Toggle(isOn: $viewModel.hasAcceptedFoodSafety) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Food Safety Training")
                                                .font(.headline)
                                            Text("I have read and understand the food safety guidelines")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                                .padding(.horizontal)
                            }
                            .padding(.top, 32)
                        }
                    case 5:
                        // Volunteer agreement/terms
                        ScrollView {
                            VStack(spacing: 24) {
                                Text("Step 6: Volunteer Agreement & Terms")
                                    .font(.title2.bold())
                                    .padding(.bottom, 8)
                                Text("Please review and accept our volunteer agreement before proceeding.")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                
                                VStack(spacing: 20) {
                                    // Terms text
                                    ScrollView {
                                        VStack(alignment: .leading, spacing: 16) {
                                            Group {
                                                Text("Volunteer Agreement")
                                                    .font(.headline)
                                                    .padding(.bottom, 4)
                                                
                                                Text("1. Commitment and Reliability")
                                                    .font(.subheadline.bold())
                                                Text("• Arrive on time for scheduled shifts\n• Provide adequate notice for cancellations\n• Maintain regular communication with the team\n• Complete assigned tasks to the best of your ability")
                                                
                                                Text("2. Code of Conduct")
                                                    .font(.subheadline.bold())
                                                Text("• Treat all staff, volunteers, and community members with respect\n• Maintain professional behavior at all times\n• Follow health and safety guidelines\n• Report any concerns to management")
                                                
                                                Text("3. Confidentiality")
                                                    .font(.subheadline.bold())
                                                Text("• Maintain confidentiality of all information\n• Respect privacy of staff, volunteers, and community members\n• Do not share sensitive information outside the organization")
                                                
                                                Text("4. Health and Safety")
                                                    .font(.subheadline.bold())
                                                Text("• Follow all safety procedures and guidelines\n• Report any hazards or incidents immediately\n• Use provided safety equipment as required\n• Maintain a safe working environment")
                                                
                                                Text("5. Training and Development")
                                                    .font(.subheadline.bold())
                                                Text("• Complete required training programs\n• Stay updated on policies and procedures\n• Participate in ongoing development opportunities\n• Seek guidance when needed")
                                            }
                                            .foregroundColor(.primary)
                                        }
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                    }
                                    .frame(height: 300)
                                    
                                    // Acceptance checkbox
                                    Toggle(isOn: $viewModel.hasAcceptedTerms) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Volunteer Agreement")
                                                .font(.headline)
                                            Text("I have read and agree to the terms of the volunteer agreement")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                                .padding(.horizontal)
                            }
                            .padding(.top, 32)
                        }
                    case 6:
                        // Review & confirmation
                        ScrollView {
                            VStack(spacing: 24) {
                                Text("Step 7: Review & Confirmation")
                                    .font(.title2.bold())
                                    .padding(.bottom, 8)
                                Text("Please review your information before submitting your registration.")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                
                                VStack(spacing: 20) {
                                    // User Type
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Registration Type")
                                            .font(.headline)
                                        Text(viewModel.selectedUserType?.rawValue ?? "")
                                            .foregroundColor(.secondary)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                    
                                    // Personal Details
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Personal Details")
                                            .font(.headline)
                                        Group {
                                            Text("Name: \(viewModel.firstName) \(viewModel.lastName)")
                                            Text("Email: \(viewModel.email)")
                                            Text("Mobile: \(viewModel.mobile)")
                                            Text("Date of Birth: \(viewModel.dob.formatted(date: .long, time: .omitted))")
                                            Text("Address: \(viewModel.address)")
                                            Text("Emergency Contact: \(viewModel.emergencyName) (\(viewModel.emergencyPhone))")
                                            if viewModel.selectedUserType == .corporate {
                                                Text("Company: \(viewModel.companyName)")
                                            }
                                        }
                                        .foregroundColor(.secondary)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                    
                                    // WWCC Details (if applicable)
                                    if viewModel.isOver18 {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("WWCC Details")
                                                .font(.headline)
                                            Group {
                                                Text("WWCC Number: \(viewModel.wwcNumber)")
                                                Text("Expiry Date: \(viewModel.wwcExpiry.formatted(date: .long, time: .omitted))")
                                            }
                                            .foregroundColor(.secondary)
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                    }
                                    
                                    // Additional Info
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Additional Information")
                                            .font(.headline)
                                        Group {
                                            Text("Duke of Edinburgh: \(viewModel.isDukeOfEd ? "Yes" : "No")")
                                            Text("Referral Source: \(viewModel.referralSource)")
                                        }
                                        .foregroundColor(.secondary)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                    
                                    // Agreements
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Agreements")
                                            .font(.headline)
                                        Group {
                                            Text("Food Safety Training: \(viewModel.hasAcceptedFoodSafety ? "Accepted" : "Not Accepted")")
                                            Text("Volunteer Agreement: \(viewModel.hasAcceptedTerms ? "Accepted" : "Not Accepted")")
                                        }
                                        .foregroundColor(.secondary)
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
}

#Preview {
    RegistrationFlowView()
} 