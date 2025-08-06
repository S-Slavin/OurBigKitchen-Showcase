//
//  ImpactShareCardView.swift
//  OurBigKitchen
//
//  Created by Admin on 6/8/2025.
//

import SwiftUI

struct ImpactShareCardView: View {
    @StateObject private var viewModel = ImpactShareCardViewModel()
    @State private var showingShareSheet = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Text("Share Your Impact")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Show others the difference you're making")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top)
            
            // Impact Preview Card
            VStack(spacing: 16) {
                // Card Preview
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.orange, Color.red]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 300)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    
                    VStack(spacing: 20) {
                        Text("My OurBigKitchen Impact")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        VStack(spacing: 12) {
                            if viewModel.mealsContributed > 0 {
                                ShareCardStatView(
                                    value: "\(viewModel.mealsContributed)",
                                    label: "Meals Contributed",
                                    color: .white
                                )
                            }
                            
                            if viewModel.hoursVolunteered > 0 {
                                ShareCardStatView(
                                    value: String(format: "%.1f", viewModel.hoursVolunteered),
                                    label: "Hours Volunteered",
                                    color: .white
                                )
                            }
                            
                            if viewModel.volunteersHelped > 0 {
                                ShareCardStatView(
                                    value: "\(viewModel.volunteersHelped)",
                                    label: "People Helped",
                                    color: .white
                                )
                            }
                        }
                        
                        Spacer()
                        
                        Text(viewModel.impactMessage)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Text("OurBigKitchen")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(20)
                }
                .padding(.horizontal)
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        viewModel.generateShareCard()
                        showingShareSheet = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Share My Impact")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.orange, Color.red]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    .disabled(viewModel.isGeneratingCard)
                    
                    Button(action: {
                        // Refresh impact data
                        viewModel.loadImpactData()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Refresh Data")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .sheet(isPresented: $showingShareSheet) {
            if let image = viewModel.generatedCardImage {
                ShareSheet(items: [image, viewModel.impactMessage])
            }
        }
        .overlay(
            Group {
                if viewModel.isGeneratingCard {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Generating your impact card...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(24)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(radius: 10)
                    }
                }
            }
        )
        .onAppear {
            viewModel.loadImpactData()
        }
    }
}

struct ShareCardStatView: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(color)
            
            Text(label)
                .font(.caption)
                .foregroundColor(color.opacity(0.9))
        }
    }
}

struct ImpactShareCardView_Previews: PreviewProvider {
    static var previews: some View {
        ImpactShareCardView()
    }
}