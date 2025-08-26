import SwiftUI

struct WebViewScreen: View {
    let url: URL
    let title: String
    @State private var isLoading = true
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                WebView(url: url, isLoading: $isLoading)
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("SKIP FOR DEMO") {
                        dismiss()
                    }
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(Color.orange)
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        UIApplication.shared.open(url)
                    } label: {
                        Image(systemName: "safari")
                    }
                }
            }
        }
    }
}

#Preview {
    let previewURL = URL(string: "https://www.ourbigkitchen.org/contact-us/") ?? URL(string: "https://ourbigkitchen.org") ?? URL(string: "https://example.com")!
    return WebViewScreen(
        url: previewURL,
        title: "Contact OBK"
    )
} 