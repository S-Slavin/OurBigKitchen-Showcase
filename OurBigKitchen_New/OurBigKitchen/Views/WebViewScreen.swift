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
    WebViewScreen(
        url: URL(string: "https://www.ourbigkitchen.org/contact-us/")!,
        title: "Contact OBK"
    )
} 