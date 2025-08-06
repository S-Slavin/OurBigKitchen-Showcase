import SwiftUI
import ComposableArchitecture
import Charts

public struct ImpactView: View {
    let store: StoreOf<ImpactFeature>
    
    public init(store: StoreOf<ImpactFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        Text("Your Impact")
                            .font(.largeTitle)
                            .bold()
                            .padding(.top)
                        
                        // Today's Impact Card
                        VStack(spacing: 16) {
                            Text("Today's Impact")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 20) {
                                ImpactMetricCard(
                                    title: "Meals Served",
                                    value: "\(viewStore.todayMetrics.mealsServed)",
                                    icon: "heart.fill",
                                    color: .red
                                )
                                
                                ImpactMetricCard(
                                    title: "Food Saved",
                                    value: "\(String(format: "%.1f", viewStore.todayMetrics.foodSavedKg))kg",
                                    icon: "leaf.fill",
                                    color: .green
                                )
                            }
                            
                            HStack(spacing: 20) {
                                ImpactMetricCard(
                                    title: "Families Helped",
                                    value: "\(viewStore.todayMetrics.familiesHelped)",
                                    icon: "house.fill",
                                    color: .blue
                                )
                                
                                ImpactMetricCard(
                                    title: "Lives Touched",
                                    value: "\(viewStore.todayMetrics.livesTouched)",
                                    icon: "person.3.fill",
                                    color: .orange
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        // Recent Activity
                        if !viewStore.impactMetrics.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Recent Activity")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                ForEach(Array(viewStore.impactMetrics.prefix(5).enumerated()), id: \.offset) { index, metric in
                                    ImpactActivityRow(metric: metric, index: index)
                                }
                            }
                        }
                        
                        Spacer()
                    }
                }
                .refreshable {
                    viewStore.send(.refreshData)
                }
                .navigationBarHidden(true)
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
            .alert("Error", isPresented: .constant(viewStore.error != nil)) {
                Button("OK") {
                    // Error handling can be added here
                }
            } message: {
                Text(viewStore.error ?? "")
            }
        }
    }
}

private struct ImpactMetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .bold()
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

private struct ImpactActivityRow: View {
    let metric: AppModels.ImpactMetric
    let index: Int
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Impact Recorded")
                    .font(.subheadline)
                    .bold()
                
                Text("\(metric.mealsServed) meals • \(String(format: "%.1f", metric.foodSavedKg))kg saved")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(index + 1)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

// Preview
#Preview {
    ImpactView(store: Store(initialState: ImpactFeature.State()) {
        ImpactFeature()
    })
}
