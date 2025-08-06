import SwiftUI

struct TermsAndConditionsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Terms and Conditions")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.bottom)
                    
                    Group {
                        Text("1. Acceptance of Terms")
                            .font(.headline)
                        Text("By accessing and using Our Big Kitchen, you agree to be bound by these Terms and Conditions.")
                        
                        Text("2. User Responsibilities")
                            .font(.headline)
                        Text("Users must provide accurate information and maintain the security of their accounts.")
                        
                        Text("3. Privacy Policy")
                            .font(.headline)
                        Text("Your use of Our Big Kitchen is also governed by our Privacy Policy.")
                        
                        Text("4. Code of Conduct")
                            .font(.headline)
                        Text("Users must adhere to our community guidelines and maintain respectful behavior.")
                    }
                    .padding(.bottom, 10)
                }
                .padding()
            }
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct TermsAndConditionsView_Previews: PreviewProvider {
    static var previews: some View {
        TermsAndConditionsView()
    }
} 