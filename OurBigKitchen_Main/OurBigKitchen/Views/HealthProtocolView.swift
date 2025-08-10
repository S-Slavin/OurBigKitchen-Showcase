import SwiftUI

struct HealthProtocolView: View {
    @EnvironmentObject private var appState: AppState
    @State private var hasAccepted = false
    
    // Warm color scheme
    private let primaryColor = Color(red: 0.93, green: 0.46, blue: 0.12) // Orange
    private let accentColor = Color(red: 0.85, green: 0.33, blue: 0.10) // Dark Orange
    private let backgroundColor = Color(red: 1.0, green: 0.98, blue: 0.94) // Cream
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Full-screen background
                backgroundColor.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    Spacer(minLength: geometry.size.height * 0.03)
                    
                    // Content Card
                    VStack(spacing: geometry.size.height * 0.02) {
                        // Logo and title
                        Image("OurBigKitchenLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.4, height: geometry.size.width * 0.22)
                        
                        Text("Health & Safety Protocols")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(primaryColor)
                            .padding(.bottom, 5)
                        
                        // Brief protocols section - scrollable with fixed height
                        ScrollView {
                            VStack(alignment: .leading, spacing: 12) {
                                bulletPoint("Hygiene: Wash hands, wear gloves, report illness")
                                bulletPoint("Food Safety: Follow temperature and storage guidelines")
                                bulletPoint("Health: Report exposures and allergies")
                                bulletPoint("Prevention: Wear proper footwear, report hazards")
                                bulletPoint("Emergency: Know exits and first aid locations")
                            }
                            .padding()
                        }
                        .frame(height: geometry.size.height * 0.35)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        
                        // Checkbox with larger tap target
                        Button(action: {
                            withAnimation { hasAccepted.toggle() }
                        }) {
                            HStack(alignment: .center) {
                                Image(systemName: hasAccepted ? "checkmark.square.fill" : "square")
                                    .foregroundColor(hasAccepted ? primaryColor : .gray)
                                    .font(.title2)
                                
                                Text("I accept the health protocols")
                                    .font(.subheadline)
                                
                                Spacer()
                            }
                            .padding()
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal)
                        
                        // Continue button - larger for easier tapping
                        Button(action: {
                            acceptAndContinue()
                        }) {
                            Text("Continue")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(hasAccepted ? primaryColor : Color.gray)
                                .cornerRadius(10)
                        }
                        .disabled(!hasAccepted)
                        .padding(.horizontal)
                        .padding(.top, 5)
                        
                        // Skip button
                        Button("SKIP FOR DEMO") {
                            acceptAndContinue()
                        }
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 24)
                        .background(Color.orange)
                        .cornerRadius(12)
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                    }
                    .padding(.vertical, 20)
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.1), radius: 5)
                    .padding(.horizontal, 20)
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.85)
                    
                    Spacer()
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(trailing: Button("Skip") {
            acceptAndContinue()
        })
    }
    
    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundColor(primaryColor)
                .font(.title3)
            Text(text)
                .font(.body)
            Spacer()
        }
    }
    
    private func acceptAndContinue() {
        // Update UserDefaults
        UserDefaults.standard.set(true, forKey: "hasAcceptedHealthProtocols")
        UserDefaults.standard.set(true, forKey: "hasSignedIn")
        UserDefaults.standard.set(true, forKey: "isAuthenticated")
        UserDefaults.standard.synchronize()
        
        // Update app state properties directly
        appState.hasAcceptedHealthProtocols = true
        appState.isAuthenticated = true
        
        // Post notifications
        NotificationCenter.default.post(name: .didUpdateHealthProtocols, object: nil)
        NotificationCenter.default.post(name: .didUpdateAuth, object: nil)
        
        // Call app state method for redundancy
        appState.acceptHealthProtocols()
    }
}

#Preview {
    HealthProtocolView()
        .environmentObject(AppState())
} 