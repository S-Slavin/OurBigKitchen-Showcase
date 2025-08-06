//
//  CorporateLeaderboardView.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//


import SwiftUI
import Charts

struct CorporateLeaderboardView: View {
    @StateObject private var viewModel = CorporateLeaderboardViewModel()
    @State private var timeRange: TimeRange = .month
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Time Range Picker
                    Picker("Time Range", selection: $timeRange) {
                        ForEach(TimeRange.allCases) { range in
                            Text(range.displayName).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Top Companies
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Top Corporate Partners")
                            .font(.headline)
                        
                        VStack(spacing: 16) {
                            ForEach(Array(viewModel.topCompanies.enumerated()), id: \.element.id) { index, company in
                                PodiumPosition(position: index + 1, company: company)
                            }
                        }
                    }
                    .padding()
                    
                    // Impact Chart
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Impact Overview")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ImpactChart(data: viewModel.impactData)
                            .frame(height: 200)
                            .padding()
                    }
                    
                    // All Companies
                    VStack(alignment: .leading, spacing: 8) {
                        Text("All Corporate Partners")
                            .font(.headline)
                        
                        ForEach(viewModel.companies) { company in
                            CompanyRow(company: company)
                                .padding(.vertical, 4)
                        }
                    }
                    .padding()
                }
                .padding(.vertical)
            }
            .navigationTitle("Corporate Partners")
            .refreshable {
                await viewModel.loadData()
            }
        }
    }
}

// MARK: - Supporting Views
struct PodiumPosition: View {
    let position: Int
    let company: AppModels.CorporateVolunteer
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(podiumColor(position: position))
                    .frame(width: 50, height: 50)
                
                Text("\(position)")
                    .font(.title2.bold())
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(company.name)
                    .font(.headline)
                
                Text("\(company.hoursContributed) volunteer hours")
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("\(Int(company.impactScore))")
                    .font(.title3.bold())
                
                Text("Impact")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func podiumColor(position: Int) -> Color {
        switch position {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .brown
        default: return .blue
        }
    }
}

struct CompanyRow: View {
    let company: AppModels.CorporateVolunteer
    
    var body: some View {
        HStack {
            Text(company.name)
                .font(.subheadline)
            
            Spacer()
            
            Text("\(company.hoursContributed) hrs")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("\(Int(company.impactScore))")
                .font(.subheadline.bold())
                .foregroundColor(.primary)
                .frame(width: 60, alignment: .trailing)
        }
    }
}

// MARK: - Supporting Types
enum TimeRange: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
    case allTime = "All Time"
    
    var id: String { rawValue }
    var displayName: String { rawValue }
}

// MARK: - ViewModel
@MainActor
class CorporateLeaderboardViewModel: ObservableObject, @unchecked Sendable {
    @Published var companies: [AppModels.CorporateVolunteer] = []
    @Published var topCompanies: [AppModels.CorporateVolunteer] = []
    @Published var impactData: [ImpactData] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let firebaseService = FirebaseService()
    
    func loadLeaderboard() {
        isLoading = true
        
        firebaseService.observeLeaderboard { [weak self] companies in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.companies = companies.sorted { $0.impactScore > $1.impactScore }
                self?.topCompanies = Array(self?.companies.prefix(3) ?? [])
            }
        }
    }
    
    @MainActor
    func loadData() async {
        // Simulate network request
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Generate sample impact data
        impactData = (0..<6).map { index in
            ImpactData(
                date: Calendar.current.date(byAdding: .month, value: -index, to: Date())!,
                value: Double.random(in: 100...1000)
            )
        }.reversed()
    }
}

struct ImpactData: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

// Add the missing ImpactChart struct
struct ImpactChart: View {
    let data: [ImpactData]
    
    var body: some View {
        Chart {
            ForEach(data) { item in
                LineMark(
                    x: .value("Date", item.date),
                    y: .value("Impact", item.value)
                )
                .foregroundStyle(Color.blue.gradient)
                
                AreaMark(
                    x: .value("Date", item.date),
                    y: .value("Impact", item.value)
                )
                .foregroundStyle(Color.blue.opacity(0.1).gradient)
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 6)) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(date, format: .dateTime.month())
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
    }
}