//
//  AnalyticsView.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//


import SwiftUI
import Charts

struct AnalyticsView: View {
    @StateObject private var viewModel = AnalyticsViewModel()
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Time Range Picker
                    Picker("Time Range", selection: $viewModel.selectedTimeRange) {
                        Text("Day").tag(AnalyticsViewModel.TimeRange.day)
                        Text("Week").tag(AnalyticsViewModel.TimeRange.week)
                        Text("Month").tag(AnalyticsViewModel.TimeRange.month)
                        Text("Year").tag(AnalyticsViewModel.TimeRange.year)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Analytics Overview
                    if let analyticsData = viewModel.analyticsData {
                        AnalyticsOverviewView(data: analyticsData)
                    }
                    
                    // Social Metrics
                    if let socialMetrics = viewModel.socialMetrics {
                        SocialMetricsView(metrics: socialMetrics)
                    }
                    
                    // Impact Data
                    if let impactData = viewModel.impactData {
                        ImpactDataView(data: impactData)
                    }
                }
                .padding()
            }
            .navigationTitle("Analytics")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.loadData() }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") { viewModel.error = nil }
            } message: {
                Text(viewModel.error?.localizedDescription ?? "")
            }
        }
    }
}

// MARK: - Supporting Views

struct AnalyticsOverviewView: View {
    let data: AnalyticsViewModel.AnalyticsData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Analytics Overview")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                MetricCard(
                    title: "Active Users",
                    value: "\(data.activeUsers)",
                    icon: "person.2.fill"
                )
                
                MetricCard(
                    title: "Sessions",
                    value: "\(data.sessions)",
                    icon: "arrow.clockwise"
                )
                
                MetricCard(
                    title: "Avg. Session",
                    value: Formatters.formatDuration(data.averageSessionDuration),
                    icon: "clock.fill"
                )
                
                MetricCard(
                    title: "Retention",
                    value: Formatters.percent.string(from: NSNumber(value: data.retentionRate)) ?? "0%",
                    icon: "chart.line.uptrend.xyaxis"
                )
            }
            
            // Top Events Chart
            VStack(alignment: .leading, spacing: 8) {
                Text("Top Events")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Chart {
                    ForEach(Array(data.topEvents.sorted(by: { $0.value > $1.value }).prefix(5)), id: \.key) { event in
                        BarMark(
                            x: .value("Event", event.key),
                            y: .value("Count", event.value)
                        )
                        .foregroundStyle(Color.accentColor)
                    }
                }
                .frame(height: 200)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
}

struct SocialMetricsView: View {
    let metrics: AnalyticsViewModel.SocialMetrics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Social Metrics")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                MetricCard(
                    title: "Followers",
                    value: "\(metrics.followers)",
                    icon: "person.2.fill"
                )
                
                MetricCard(
                    title: "Following",
                    value: "\(metrics.following)",
                    icon: "person.2.fill"
                )
                
                MetricCard(
                    title: "Shares",
                    value: "\(metrics.shares)",
                    icon: "square.and.arrow.up"
                )
                
                MetricCard(
                    title: "Likes",
                    value: "\(metrics.likes)",
                    icon: "heart.fill"
                )
                
                MetricCard(
                    title: "Comments",
                    value: "\(metrics.comments)",
                    icon: "bubble.left.fill"
                )
            }
        }
    }
}

struct ImpactDataView: View {
    let data: AnalyticsViewModel.ImpactData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Impact Data")
                .font(.headline)
            
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: iconForImpactType(data.type))
                        .font(.title)
                        .foregroundColor(.accentColor)
                    
                    VStack(alignment: .leading) {
                        Text(data.type.rawValue.capitalized)
                            .font(.headline)
                        
                        Text("\(Formatters.decimal.string(from: NSNumber(value: data.value)) ?? "0") \(data.unit)")
                            .font(.title2)
                            .bold()
                    }
                    
                    Spacer()
                    
                    Text(Formatters.dateTime.string(from: data.timestamp))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
        }
    }
    
    private func iconForImpactType(_ type: AnalyticsViewModel.ImpactType) -> String {
        switch type {
        case .mealsServed: return "fork.knife"
        case .volunteers: return "person.2"
        case .wasteReduced: return "leaf"
        case .donations: return "dollarsign.circle"
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.accentColor)
                
                Spacer()
                
                Text(value)
                    .font(.title2)
                    .bold()
            }
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}