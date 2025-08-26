import SwiftUI

struct VolunteerTypeSelectionView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedType: VolunteerType = .individual
    
    private let primaryColor = ThemeManager.Colors.primary
    private let accentColor = ThemeManager.Colors.accent
    private let backgroundColor = Color(red: 1.0, green: 0.98, blue: 0.94)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Modern background
                LinearGradient(
                    gradient: Gradient(colors: [backgroundColor, backgroundColor.opacity(0.95), Color(red: 1.0, green: 0.92, blue: 0.86)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    // Logo
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.3)
                        .padding(.top, geometry.size.height * 0.05)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    // Welcome message
                    VStack(spacing: 16) {
                        Text("Welcome!")
                            .font(.system(.title, design: .rounded, weight: .bold))
                            .foregroundColor(primaryColor)
                        
                        Text("Please select your volunteer type to continue")
                            .font(.subheadline)
                            .foregroundColor(accentColor)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    
                    // Volunteer type selection
                    VStack(spacing: 20) {
                        Text("I will volunteer as:")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.top, 20)
                        
                        VStack(spacing: 16) {
                            VolunteerTypeButton(
                                title: "Individual Volunteer",
                                subtitle: "Volunteer on your own",
                                icon: "person.fill",
                                isSelected: selectedType == .individual,
                                primaryColor: primaryColor,
                                accentColor: accentColor
                            ) {
                                selectedType = .individual
                            }
                            
                            VolunteerTypeButton(
                                title: "Corporate/Group",
                                subtitle: "Volunteer with your organization",
                                icon: "building.2.fill",
                                isSelected: selectedType == .corporate,
                                primaryColor: primaryColor,
                                accentColor: accentColor
                            ) {
                                selectedType = .corporate
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                    
                    // Continue Button
                    Button(action: {
                        print("DEBUG: VolunteerTypeSelectionView - Continue button tapped")
                        // Update user profile with selected volunteer type
                        if let currentUser = appState.userProfile {
                            print("DEBUG: Updating user profile with volunteer type: \(selectedType)")
                            // Update user role based on volunteer type
                            let role: AppModels.UserRole = selectedType == .individual ? .volunteer : .corporateVolunteer
                            
                            // Update user in storage
                            let storageManager = StorageManager.shared
                            let updatedUser = storageManager.createUser(
                                firstName: currentUser.firstName,
                                lastName: currentUser.lastName,
                                email: currentUser.email,
                                role: role,
                                dob: currentUser.dob,
                                wwcNumber: currentUser.wwcNumber,
                                wwcExpiry: currentUser.wwcExpiry,
                                companyName: selectedType == .corporate ? "Corporate Organization" : nil,
                                companyPosition: selectedType == .corporate ? "Volunteer" : nil,
                                companyEmail: selectedType == .corporate ? currentUser.email : nil
                            )
                            
                            // Update app state
                            appState.userProfile = updatedUser
                            appState.needsToChooseVolunteerType = false
                            
                            print("DEBUG: VolunteerTypeSelectionView - Flow completed, user ready for main app")
                            
                            // Force UI update
                            appState.objectWillChange.send()
                        } else {
                            print("DEBUG: No user profile found, creating basic profile")
                            // Create basic user profile if none exists
                            let basicUser = AppModels.User(
                                id: UUID().uuidString,
                                firstName: "User",
                                lastName: "User",
                                email: "user@example.com",
                                role: selectedType == .individual ? .volunteer : .corporateVolunteer,
                                preferences: AppModels.UserPreferences(),
                                achievements: [],
                                stats: AppModels.UserStats(),
                                hasFoodSafetyRegistration: false,
                                dob: Date(),
                                wwcNumber: nil,
                                wwcExpiry: nil,
                                companyName: selectedType == .corporate ? "Corporate Organization" : nil
                            )
                            
                            appState.userProfile = basicUser
                            appState.needsToChooseVolunteerType = false
                            
                            print("DEBUG: VolunteerTypeSelectionView - Basic profile created, flow completed")
                            appState.objectWillChange.send()
                        }
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [primaryColor, accentColor]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(25)
                            .shadow(color: primaryColor.opacity(0.4), radius: 8, x: 0, y: 5)
                    }
                    .buttonStyle(ButtonStyles.scale)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
                .padding(.top, geometry.safeAreaInsets.top + 20)
                .padding(.bottom, 30)
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Volunteer Type Button

struct VolunteerTypeButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let isSelected: Bool
    let primaryColor: Color
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : primaryColor)
                    .frame(width: 40)
                
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? 
                        AnyShapeStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [primaryColor, accentColor]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        ) : 
                        AnyShapeStyle(Color.white.opacity(0.8))
                    )
            )
            .shadow(color: isSelected ? primaryColor.opacity(0.4) : Color.black.opacity(0.07), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct VolunteerTypeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        VolunteerTypeSelectionView()
            .environmentObject(AppState())
    }
}
