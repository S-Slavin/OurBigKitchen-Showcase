import SwiftUI

struct MealContributionPopup: View {
    @Binding var isPresented: Bool
    @State private var mealsMade: String = ""
    @State private var hoursVolunteered: String = ""
    @State private var showSuccess: Bool = false
    
    var onSave: (Int, Double) -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isPresented = false
                }
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Text("Log Your Contribution")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 22))
                    }
                }
                .padding(.bottom, 8)
                
                // Input fields
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "fork.knife")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        TextField("Meals made", text: $mealsMade)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        TextField("Hours volunteered", text: $hoursVolunteered)
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                
                // Save button
                Button {
                    saveContribution()
                } label: {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Save Contribution")
                    }
                    .font(.headline)
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(!isValid)
                
                if showSuccess {
                    Text("Contribution saved!")
                        .foregroundColor(.green)
                        .font(.subheadline)
                        .padding(.top, 8)
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
            )
            .frame(width: UIScreen.main.bounds.width - 60)
            .transition(.scale)
        }
    }
    
    private var isValid: Bool {
        guard let _ = Int(mealsMade), let _ = Double(hoursVolunteered) else {
            return false
        }
        return true
    }
    
    private func saveContribution() {
        guard let meals = Int(mealsMade), let hours = Double(hoursVolunteered) else {
            return
        }
        
        onSave(meals, hours)
        
        // Show success message
        showSuccess = true
        
        // Close the popup after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showSuccess = false
            isPresented = false
        }
    }
}

struct MealContributionPopup_Previews: PreviewProvider {
    static var previews: some View {
        MealContributionPopup(isPresented: .constant(true)) { _, _ in
            // Handle save action
        }
    }
} 