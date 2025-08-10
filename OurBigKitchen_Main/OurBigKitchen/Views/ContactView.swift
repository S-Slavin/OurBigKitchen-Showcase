//
//  ContactView.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//

import SwiftUI

struct ContactView: View {
    @StateObject private var viewModel = ContactViewModel()
    @State private var isShowingWebView = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Contact Category")) {
                    Picker("Category", selection: $viewModel.selectedCategory) {
                        ForEach(ContactService.ContactCategory.allCases) { category in
                            Text(category.rawValue)
                                .tag(category)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    
                    HStack {
                        Image(systemName: viewModel.selectedCategory.iconName)
                            .foregroundColor(viewModel.getCategoryColor(viewModel.selectedCategory))
                        Text(viewModel.selectedCategory.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 5)
                }
                
                Section(header: Text("Your Information")) {
                    TextField("Name", text: $viewModel.name)
                        .autocorrectionDisabled()
                    
                    TextField("Email", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                }
                
                Section(header: Text("Message")) {
                    TextField("Subject", text: $viewModel.subject)
                }
                
                Section {
                    Button(action: {
                        isShowingWebView = true
                    }) {
                        Text("Contact OBK")
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(viewModel.name.isEmpty || 
                              viewModel.email.isEmpty || 
                              !viewModel.email.contains("@") || 
                              viewModel.subject.isEmpty)
                }
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("Contact Us")
            .sheet(isPresented: $isShowingWebView) {
                if let contactURL = viewModel.contactURL {
                    WebViewScreen(url: contactURL, title: "Contact OBK")
                } else {
                    Text("Unable to load contact form. Please try again later.")
                        .padding()
                }
            }
            .onChange(of: isShowingWebView) { newValue in
                if newValue {
                    viewModel.contactViaWeb()
                }
            }
        }
    }
}

#Preview {
    ContactView()
} 