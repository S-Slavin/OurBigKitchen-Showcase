import SwiftUI

struct AuthTypeSelectionView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedType: AuthType = .volunteer
    private let primaryColor = ThemeManager.Colors.primary
    private let accentColor = ThemeManager.Colors.accent
    private let backgroundColor = Color(red: 1.0, green: 0.98, blue: 0.94)
    
    enum AuthType {
        case volunteer
        case wwcc
        case corporate
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    // Modern background
                    LinearGradient(
                        gradient: Gradient(colors: [backgroundColor, backgroundColor.opacity(0.95), Color(red: 1.0, green: 0.92, blue: 0.86)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .edgesIgnoringSafeArea(.all)

                    VStack(spacing: 24) {
                        // Logo
                        Image("AppLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.4)
                            .padding(.top, geometry.size.height * 0.02)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)

                        Text("Welcome to Our Big Kitchen")
                            .font(.system(.title, design: .rounded, weight: .bold))
                            .foregroundColor(primaryColor)
                            .padding(.top, 8)
                            .padding(.bottom, 10)
                        
                        Text("Please select how you'd like to volunteer")
                            .font(.subheadline)
                            .foregroundColor(accentColor)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 30)
                        
                        // Auth Type Selection
                        VStack(spacing: 16) {
                            AuthTypeButton(
                                title: "Volunteer",
                                subtitle: "For personal volunteering",
                                icon: "person.fill",
                                isSelected: selectedType == .volunteer,
                                primaryColor: primaryColor,
                                accentColor: accentColor
                            ) {
                                selectedType = .volunteer
                            }
                            
                            AuthTypeButton(
                                title: "WWCC",
                                subtitle: "For WWCC volunteering",
                                icon: "person.fill",
                                isSelected: selectedType == .wwcc,
                                primaryColor: primaryColor,
                                accentColor: accentColor
                            ) {
                                selectedType = .wwcc
                            }
                            
                            AuthTypeButton(
                                title: "Corporate Sign Up",
                                subtitle: "For company-organized volunteering",
                                icon: "building.2.fill",
                                isSelected: selectedType == .corporate,
                                primaryColor: primaryColor,
                                accentColor: accentColor
                            ) {
                                selectedType = .corporate
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        // Continue Button
                        NavigationLink(
                            destination: destinationView,
                            label: {
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
                        )
                        .buttonStyle(ButtonStyles.scale)
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                    .padding(.top, geometry.safeAreaInsets.top + 20)
                    .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    @ViewBuilder
    private var destinationView: some View {
        switch selectedType {
        case .volunteer:
            SimpleSignInView()
        case .wwcc:
            WWCSignInView()
        case .corporate:
            CorporateSignInView()
        }
    }
}

struct AuthTypeButton: View {
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

struct AuthTypeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        AuthTypeSelectionView()
            .environmentObject(AppState())
    }
} 