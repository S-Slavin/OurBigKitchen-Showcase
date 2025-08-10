//
//  FoodSafetyRegistrationView.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//

import SwiftUI

struct FoodSafetyRegistrationView: View {
    @StateObject private var viewModel = FoodSafetyViewModel()
    @Environment(\.dismiss) private var dismiss
    var onComplete: (() -> Void)?
    @State private var animateBackground = false
    @State private var currentStep = 1 // Step 1: Personal info & company, Step 2: Additional details
    @State private var showTermsSheet = false
    @ObservedObject private var termsManager = TermsManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Improved background
                LinearGradient(
                    gradient: Gradient(colors: [Color.orange.opacity(0.05), Color.orange.opacity(0.2)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .overlay(
                    ZStack {
                        // Animated background elements
                        Image(systemName: "fork.knife")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200)
                            .rotationEffect(Angle(degrees: animateBackground ? 5 : -5))
                            .opacity(0.03)
                            .offset(y: -100)
                        
                        Image(systemName: "hands.sparkles")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200)
                            .rotationEffect(Angle(degrees: animateBackground ? -5 : 5))
                            .opacity(0.03)
                            .offset(y: 100)
                    }
                )
                
                ScrollView {
                    VStack(spacing: 28) {
                        // Logo and Header
                        headerView
                            .padding(.top, 20)
                        
                        // Registration Form - Step 1 or 2 depending on currentStep
                        if currentStep == 1 {
                            registrationFormStepOne
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(Color.white)
                                        .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 5)
                                )
                                .padding(.horizontal)
                        } else {
                            registrationFormStepTwo
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(Color.white)
                                        .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 5)
                                )
                                .padding(.horizontal)
                        }
                        
                        // Success Message
                        if viewModel.showSuccessMessage {
                            successMessageView
                                .transition(.scale.combined(with: .opacity))
                        }
                        
                        // Error Message
                        if let validationError = viewModel.validationError {
                            errorMessageView(message: validationError)
                                .transition(.scale.combined(with: .opacity))
                        }
                        
                        // Navigation Buttons
                        if currentStep == 1 {
                            // Next button for step 1
                            nextButtonView
                        } else {
                            // Submit button for step 2
                            submitButtonView
                        }
                        
                        // Safety Information
                        safetyInformationView
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color.blue.opacity(0.05))
                                    .shadow(color: Color.black.opacity(0.03), radius: 10)
                            )
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 30)
                }
                .padding()
                .animation(.easeInOut(duration: 0.5), value: viewModel.showSuccessMessage)
                .animation(.easeInOut(duration: 0.3), value: viewModel.validationError)
                .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
            .navigationTitle("Food Safety Registration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                // Back button for step 2
                if currentStep == 2 {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Back") {
                            withAnimation {
                                currentStep = 1
                            }
                        }
                    }
                }
            }
            .disabled(viewModel.isLoading)
            .overlay {
                if viewModel.isLoading {
                    loadingOverlay
                }
            }
            .onChange(of: viewModel.showSuccessMessage) { newValue in
                if newValue {
                    // Give time for user to see success message before proceeding
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            onComplete?()
                        }
                    }
                }
            }
            .onAppear {
                // Start background animation
                withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                    animateBackground = true
                }
            }
            .sheet(isPresented: $showTermsSheet) {
                VStack {
                    HStack {
                        Spacer()
                        Button("SKIP FOR DEMO") {
                            showTermsSheet = false
                        }
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 24)
                        .background(Color.orange)
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                        .padding()
                    }
                    
                    TermsView(showTermsSheet: $showTermsSheet)
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()
            
            VStack(spacing: 15) {
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                
                Text("Processing...")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground).opacity(0.85))
                    .shadow(color: .black.opacity(0.1), radius: 15)
            )
        }
        .transition(.opacity)
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            Image(systemName: "fork.knife.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.orange)
                .shadow(color: .orange.opacity(0.3), radius: 10)
            
            Text("Digital Food Safety Declaration")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
            
            Text("This form ensures compliance with local food safety regulations. All volunteers and staff must complete this form before participating in kitchen activities.")
                .font(.system(size: 15, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal)
        }
        .padding(.vertical)
    }
    
    // Step 1: Company, Name, Email, and Declaration
    private var registrationFormStepOne: some View {
        VStack(spacing: 24) {
            // Name Input
            VStack(alignment: .leading, spacing: 10) {
                Text("Full Name")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                TextField("Enter your full name", text: $viewModel.participantName)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.1))
                    )
                    .autocapitalization(.words)
                    .textContentType(.name)
                    .submitLabel(.next)
            }
            .padding(.horizontal)
            
            // Email Input
            VStack(alignment: .leading, spacing: 10) {
                Text("Email")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                TextField("Enter your email address", text: $viewModel.participantEmail)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.1))
                    )
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textContentType(.emailAddress)
                    .submitLabel(.next)
            }
            .padding(.horizontal)
            
            // Terms acceptance button - only show if not already accepted
            if !termsManager.hasAcceptedTerms {
                Button {
                    showTermsSheet = true
                } label: {
                    HStack {
                        Image(systemName: termsManager.hasAcceptedTerms ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(termsManager.hasAcceptedTerms ? .green : .gray)
                        Text("Review and Accept Terms & Conditions")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            } else {
                // Show confirmation when terms are already accepted
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Terms & Conditions Accepted")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
            }
        }
    }
    
    // Step 2: Additional details - leave empty or add more fields if needed
    private var registrationFormStepTwo: some View {
        VStack(spacing: 24) {
            // Additional fields can be added here if needed
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Additional Information")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("All required information has been collected on the previous page.")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 40)
        }
    }
    
    // Next button for step 1
    private var nextButtonView: some View {
        Button {
            validateAndProceedToNextStep()
        } label: {
            Text("Next")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
                )
        }
        .disabled(!isStepOneValid)
        .opacity(isStepOneValid ? 1.0 : 0.6)
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
    
    // Submit button remains largely unchanged
    private var submitButtonView: some View {
        Button {
            withAnimation {
                viewModel.submitForm()
            }
        } label: {
            Text("Submit Food Safety Declaration")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.orange, Color.orange.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: Color.orange.opacity(0.3), radius: 10, x: 0, y: 5)
                )
        }
        .disabled(!viewModel.canSubmit)
        .opacity(viewModel.canSubmit ? 1.0 : 0.6)
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
    
    // Computed property to check if step 1 is valid
    private var isStepOneValid: Bool {
        return !viewModel.participantName.isEmpty &&
               !viewModel.participantEmail.isEmpty &&
               termsManager.hasAcceptedTerms
    }
    
    // Function to validate step 1 and move to step 2
    private func validateAndProceedToNextStep() {
        // Check if step 1 is valid
        if !viewModel.participantName.isEmpty &&
            !viewModel.participantEmail.isEmpty &&
            termsManager.hasAcceptedTerms {
            withAnimation {
                currentStep = 2
            }
        } else {
            // Show validation error
            if viewModel.firstName.isEmpty {
                viewModel.validationError = "Please enter your first name"
            } else if viewModel.lastName.isEmpty {
                viewModel.validationError = "Please enter your last name"
            } else if viewModel.participantEmail.isEmpty {
                viewModel.validationError = "Please enter your email"
            } else if !termsManager.hasAcceptedTerms {
                viewModel.validationError = "Please accept the terms and conditions"
            }
        }
    }
    
    private var successMessageView: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 20))
            
            VStack(alignment: .leading) {
                Text("Registration Successful!")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
                
                Text("Your information has been recorded and synced with Salesforce.")
                    .font(.system(size: 15, design: .rounded))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.green.opacity(0.1))
                .shadow(color: Color.green.opacity(0.1), radius: 10)
        )
        .padding(.horizontal)
    }
    
    private func errorMessageView(message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
                .font(.system(size: 20))
            
            Text(message)
                .font(.system(size: 15, design: .rounded))
                .foregroundColor(.red)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.red.opacity(0.1))
                .shadow(color: Color.red.opacity(0.1), radius: 10)
        )
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Error: \(message)")
    }
    
    private var safetyInformationView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Food Safety Information")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 12) {
                infoRow(icon: "hand.wave.fill", title: "Wash Hands", description: "Always wash hands thoroughly before handling food.")
                
                infoRow(icon: "thermometer", title: "Temperature Control", description: "Keep hot foods hot and cold foods cold.")
                
                infoRow(icon: "flame.fill", title: "Cooking", description: "Cook foods to appropriate temperatures to kill harmful bacteria.")
                
                infoRow(icon: "bandage.fill", title: "Illness", description: "Do not handle food if you're feeling unwell.")
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 24)
    }
    
    private func infoRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.system(size: 18))
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - Supporting Views

struct BulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text("•")
                .font(.subheadline)
                .padding(.trailing, 4)
            
            Text(text)
                .font(.subheadline)
        }
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .foregroundColor(configuration.isOn ? .orange : .secondary)
                .font(.system(size: 20))
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                        configuration.isOn.toggle()
                    }
                }
            configuration.label
        }
    }
}

// Add a pressable button style for better feedback
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    FoodSafetyRegistrationView()
} 