import SwiftUI

// MARK: - Modern Text Field Components

struct ModernTextField: View {
    var placeholder: String
    @Binding var text: String
    var icon: String
    var keyboardType: UIKeyboardType = .default
    
    @State private var isFocused = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(isFocused ? ThemeManager.Colors.primary : ThemeManager.Colors.primary.opacity(0.6))
                .frame(width: 30)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
            
            TextField(placeholder, text: $text, onEditingChanged: { editing in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isFocused = editing
                }
            })
            .keyboardType(keyboardType)
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .font(.system(size: 17, weight: .regular))
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(isFocused ? 0.08 : 0.05), radius: isFocused ? 8 : 5, x: 0, y: isFocused ? 4 : 2)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isFocused ? ThemeManager.Colors.primary.opacity(0.5) : Color.gray.opacity(0.2), lineWidth: isFocused ? 1.5 : 1)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
        )
    }
}

struct ModernSecureField: View {
    var placeholder: String
    @Binding var text: String
    var icon: String
    
    @State private var isFocused = false
    @State private var showPassword = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(isFocused ? ThemeManager.Colors.primary : ThemeManager.Colors.primary.opacity(0.6))
                .frame(width: 30)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
            
            if showPassword {
                TextField(placeholder, text: $text, onEditingChanged: { editing in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isFocused = editing
                    }
                })
                .keyboardType(.default)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .font(.system(size: 17, weight: .regular))
            } else {
                SecureField(placeholder, text: $text)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .font(.system(size: 17, weight: .regular))
                    .onTapGesture {
                        withAnimation {
                            isFocused = true
                        }
                    }
            }
            
            Button(action: {
                showPassword.toggle()
            }) {
                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(Color.gray.opacity(0.6))
                    .font(.system(size: 15))
                    .padding(.trailing, 8)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(isFocused ? 0.08 : 0.05), radius: isFocused ? 8 : 5, x: 0, y: isFocused ? 4 : 2)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isFocused ? ThemeManager.Colors.primary.opacity(0.5) : Color.gray.opacity(0.2), lineWidth: isFocused ? 1.5 : 1)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
        )
    }
}
