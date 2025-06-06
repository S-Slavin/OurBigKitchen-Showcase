import SwiftUI
import Charts

struct ImpactDashboardView: View {
    @StateObject private var viewModel = ImpactDashboardViewModel()
    @State private var impactFilterViewModel: ImpactFilterViewModel?
    @State private var scrollOffset: CGFloat = 0
    @State private var selectedStat: String? = nil
    @State private var animateIn = false
    @State private var showSignInSheet = false
    @State private var showCameraView = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(.systemBackground).edgesIgnoringSafeArea(.all)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header with gradient and title
                        headerView
                            .scaleEffect(animateIn ? 1.0 : 0.95)
                            .opacity(animateIn ? 1.0 : 0.0)
                        
                        // Sign In or User Profile Section
                        signInSection
                            .offset(y: animateIn ? 0 : 10)
                            .opacity(animateIn ? 1.0 : 0.0)
                        
                        // Time Range Picker
                        timeRangePicker
                            .padding(.horizontal)
                            .offset(y: animateIn ? 0 : 15)
                            .opacity(animateIn ? 1.0 : 0.0)
                        
                        // Overall Impact Summary
                        impactSummaryCard
                            .padding(.horizontal)
                            .offset(y: animateIn ? 0 : 20)
                            .opacity(animateIn ? 1.0 : 0.0)
                        
                        // Social Sharing Section
                        shareImpactSection
                            .padding(.horizontal)
                            .offset(y: animateIn ? 0 : 30)
                            .opacity(animateIn ? 1.0 : 0.0)
                        
                        Spacer(minLength: 80)
                    }
                    .padding(.horizontal, 0)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Impact Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.refreshData()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showCameraView = true
                    } label: {
                        Image(systemName: "camera")
                            .font(.system(size: 18))
                    }
                }
            }
            .overlay {
                if viewModel.isLoading {
                    loadingOverlay
                }
            }
            .sheet(isPresented: $showCameraView) {
                CameraImpactView(
                    isShown: $showCameraView,
                    onCapture: { image in
                        viewModel.processNewImpactImage(image)
                    }
                )
            }
            .sheet(isPresented: $viewModel.showingFilterSheet) {
                if let impact = viewModel.userImpact {
                    let filterVM = ImpactFilterViewModel(impact: impact)
                    ImpactFilterView(viewModel: filterVM)
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                        .onAppear {
                            impactFilterViewModel = filterVM
                        }
                        .onDisappear {
                            if let renderedImage = impactFilterViewModel?.renderImpactImage() {
                                viewModel.shareFilteredImpact(with: renderedImage)
                            } else {
                                viewModel.shareFilteredImpact(with: nil)
                            }
                        }
                }
            }
            .sheet(isPresented: $showSignInSheet) {
                SimpleSignInView()
                .presentationDetents([.height(650), .large])
                .presentationDragIndicator(.visible)
            }
            .onAppear {
                withAnimation(Animation.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                    animateIn = true
                }
                
                NotificationCenter.default.addObserver(
                    forName: NSNotification.Name("OpenImpactCamera"),
                    object: nil,
                    queue: .main
                ) { _ in
                    showCameraView = true
                }
            }
            .onDisappear {
                NotificationCenter.default.removeObserver(
                    self,
                    name: NSNotification.Name("OpenImpactCamera"),
                    object: nil
                )
            }
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 16) {
            Text("Your Impact")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Track and share how you're making a difference")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            // Metrics row
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                metricCard(
                    value: "\(viewModel.totalMealsServed.formatted())",
                    label: "Meals",
                    icon: "fork.knife",
                    color: ThemeManager.Colors.mealsServed
                )
                
                metricCard(
                    value: String(format: "%.1f", viewModel.totalHoursVolunteered),
                    label: "Hours",
                    icon: "clock.fill",
                    color: ThemeManager.Colors.hoursContributed
                )
                
                metricCard(
                    value: String(format: "%.1f kg", viewModel.totalFoodWasteSaved),
                    label: "Saved",
                    icon: "leaf.fill",
                    color: ThemeManager.Colors.wasteReduced
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeManager.Colors.cardBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 3)
        )
        .padding(.horizontal)
    }
    
    private func metricCard(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Sign In Section
    
    private var signInSection: some View {
        VStack(spacing: 16) {
            if viewModel.isUserSignedIn {
                // User is signed in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Welcome, \(viewModel.userName)")
                            .font(.headline)
                        
                        Text("Keep tracking your impact!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button {
                        viewModel.signOut()
                    } label: {
                        Text("Sign Out")
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal)
            } else {
                // User is not signed in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Sign In")
                            .font(.headline)
                        
                        Text("Track your personal impact")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button {
                        showSignInSheet = true
                    } label: {
                        Text("Sign In")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Time Range Picker
    
    private var timeRangePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(ImpactDashboardViewModel.TimeRange.allCases, id: \.self) { timeRange in
                    Button(action: {
                        viewModel.selectedTimeRange = timeRange
                    }) {
                        Text(timeRange.rawValue)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(viewModel.selectedTimeRange == timeRange ? 
                                          Color.blue : Color.gray.opacity(0.15))
                            )
                            .foregroundColor(viewModel.selectedTimeRange == timeRange ? 
                                             .white : .primary)
                            .fontWeight(viewModel.selectedTimeRange == timeRange ? .semibold : .regular)
                    }
                    .buttonStyle(ButtonStyles.scale)
                }
            }
            .padding(.vertical, 5)
        }
    }
    
    // MARK: - Impact Summary Card
    
    private var impactSummaryCard: some View {
        VStack(spacing: 16) {
            Text("Impact Summary")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Charts and metrics
            if viewModel.dailyStats.isEmpty {
                Text("No data available for the selected time period")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
            } else {
                // Stats grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    metricCard(
                        value: viewModel.totalMealsServed.formatted(),
                        label: "Meals Served",
                        icon: "fork.knife",
                        color: ThemeManager.Colors.mealsServed
                    )
                    
                    metricCard(
                        value: String(format: "%.1f kg", viewModel.totalFoodWasteSaved),
                        label: "Food Waste Saved",
                        icon: "leaf.fill",
                        color: ThemeManager.Colors.wasteReduced
                    )
                    
                    metricCard(
                        value: viewModel.totalVolunteers.formatted(),
                        label: "Volunteers",
                        icon: "person.3.fill",
                        color: ThemeManager.Colors.volunteers
                    )
                    
                    metricCard(
                        value: String(format: "%.1f", viewModel.totalHoursVolunteered),
                        label: "Hours Volunteered",
                        icon: "clock.fill",
                        color: ThemeManager.Colors.hoursContributed
                    )
                }
                
                // Add chart
                impactChartView
                    .frame(height: 220)
                    .padding(.top, 10)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeManager.Colors.cardBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 3)
        )
    }
    
    private var impactChartView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Meals Over Time")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(viewModel.dailyStats) { stat in
                        BarMark(
                            x: .value("Date", stat.date, unit: .day),
                            y: .value("Meals", stat.mealsServed)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                    }
                }
            } else {
                // Fallback for iOS 15
                HStack(alignment: .bottom, spacing: 6) {
                    ForEach(viewModel.dailyStats) { stat in
                        VStack {
                            // Simple bar
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                                .frame(height: CGFloat(stat.mealsServed) * 0.5)
                            
                            // Date label
                            Text(stat.date.formatted(.dateTime.day().month(.abbreviated)))
                                .font(.system(size: 8))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.top, 10)
            }
        }
    }
    
    // MARK: - Share Impact Section
    
    private var shareImpactSection: some View {
        VStack(spacing: 20) {
            Text("Share Your Journey")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 16) {
                // Remove the "Track Your Impact" button
                
                Button {
                    viewModel.showingFilterSheet = true
                } label: {
                    HStack {
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 18))
                        Text("Create Impact Card")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(ThemeManager.Colors.secondary)
                    )
                    .foregroundColor(.white)
                }
                .buttonStyle(ButtonStyles.scale)
                .disabled(viewModel.userImpact == nil)
                
                HStack(spacing: 20) {
                    Text("Share on")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    socialButton(
                        platform: .facebook,
                        color: Color(red: 0.23, green: 0.35, blue: 0.6)
                    ) {
                        viewModel.shareToSocialMedia(.facebook)
                    }
                    
                    socialButton(
                        platform: .twitter,
                        color: Color(red: 0.11, green: 0.63, blue: 0.95)
                    ) {
                        viewModel.shareToSocialMedia(.twitter)
                    }
                    
                    socialButton(
                        platform: .instagram,
                        color: Color(red: 0.8, green: 0.26, blue: 0.4)
                    ) {
                        viewModel.shareToSocialMedia(.instagram)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeManager.Colors.cardBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 3)
        )
    }
    
    private func socialButton(platform: SocialSharingViewModel.SocialPlatform, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: platform.iconName)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(color)
                    )
                
                Text(platform.rawValue)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
            }
            .frame(minWidth: 60)
        }
        .buttonStyle(ButtonStyles.bouncy)
        .disabled(viewModel.userImpact == nil)
    }
    
    // MARK: - Loading Overlay
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.1)
                .ignoresSafeArea()
            
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
                .frame(width: 120, height: 120)
                .shadow(color: Color.black.opacity(0.1), radius: 10)
            
            ProgressView()
                .scaleEffect(1.2)
        }
        .transition(.opacity)
    }
    
    // MARK: - Sign In View
    
    struct SignInView: View {
        @State private var email = ""
        @State private var password = ""
        @State private var isCreatingAccount = false
        var onComplete: (Bool) -> Void
        
        var body: some View {
            GeometryReader { geometry in
                NavigationStack {
                    ScrollView {
                        VStack(spacing: 24) {
                            Spacer(minLength: geometry.size.height * 0.05)
                            
                            // Icon with proportional sizing
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: min(geometry.size.width * 0.2, 70)))
                                .foregroundColor(.blue)
                            
                            // Title with proportional spacing
                            Text(isCreatingAccount ? "Create Account" : "Sign In")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.bottom, geometry.size.height * 0.01)
                            
                            // Form fields with proportional sizing
                            VStack(spacing: geometry.size.height * 0.02) {
                                if isCreatingAccount {
                                    TextField("Full Name", text: .constant(""))
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(10)
                                }
                                
                                TextField("Email", text: $email)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                
                                SecureField("Password", text: $password)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                            }
                            
                            // Buttons with proportional sizing
                            Button {
                                onComplete(true)
                            } label: {
                                Text(isCreatingAccount ? "Create Account" : "Sign In")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            .padding(.top, geometry.size.height * 0.02)
                            
                            Button {
                                isCreatingAccount.toggle()
                            } label: {
                                Text(isCreatingAccount ? 
                                     "Already have an account? Sign In" : 
                                     "Don't have an account? Create one")
                                    .foregroundColor(.blue)
                            }
                            .padding(.top, geometry.size.height * 0.01)
                            
                            Spacer(minLength: geometry.size.height * 0.1)
                        }
                        .padding(.horizontal, geometry.size.width * 0.06)
                        .frame(minHeight: geometry.size.height)
                    }
                    .navigationTitle(isCreatingAccount ? "Create Account" : "Sign In")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                onComplete(false)
                            }
                        }
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}

// MARK: - Supporting Views

struct ImpactStatView: View {
    let value: Int
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text("\(value)")
                .font(.title3.bold())
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ChartView<T>: View where T: Identifiable {
    let title: String
    let data: [T]
    let valuePath: KeyPath<T, Double>
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(data) { item in
                        BarMark(
                            x: .value("Date", ""),
                            y: .value("Value", item[keyPath: valuePath])
                        )
                        .foregroundStyle(color.gradient)
                        .cornerRadius(8)
                    }
                }
                .frame(height: 160)
            } else {
                // Fallback for older iOS versions
                Text("Charts require iOS 16 or later")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - DailyStats Extension
extension DailyStats {
    // Add Double versions of Int properties for use with ChartView
    var mealsServedDouble: Double {
        return Double(mealsServed)
    }
    
    var peopleServedDouble: Double {
        return Double(peopleServed)
    }
}

// MARK: - Helper Structs and Extensions

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    ImpactDashboardView()
} 