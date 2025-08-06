import SwiftUI
import ComposableArchitecture

public struct AuthenticationView: View {
    let store: StoreOf<AuthenticationFeature>
    
    public init(store: StoreOf<AuthenticationFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationView {
                VStack(spacing: 24) {
                    // Logo
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("Our Big Kitchen")
                        .font(.largeTitle)
                        .bold()
                    
                    Text("Sign in to track your impact")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Login Form
                    VStack(spacing: 16) {
                        TextField("Email", text: viewStore.binding(
                            get: \.email,
                            send: AuthenticationFeature.Action.emailChanged
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        
                        SecureField("Password", text: viewStore.binding(
                            get: \.password,
                            send: AuthenticationFeature.Action.passwordChanged
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        if let error = viewStore.error {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        
                        Button(action: { viewStore.send(.loginTapped) }) {
                            if viewStore.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Sign In")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .disabled(viewStore.isLoading)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding()
                .navigationBarHidden(true)
            }
        }
    }
} 