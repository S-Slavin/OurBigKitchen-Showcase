import SwiftUI

struct IconGenerator: View {
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.2, green: 0.5, blue: 0.8),
                    Color(red: 0.1, green: 0.3, blue: 0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Single centered icon
            Image(systemName: "fork.knife.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 600, height: 600)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        }
        .frame(width: 1024, height: 1024)
    }
}

struct IconGenerator_Previews: PreviewProvider {
    static var previews: some View {
        IconGenerator()
            .previewLayout(.fixed(width: 1024, height: 1024))
    }
} 