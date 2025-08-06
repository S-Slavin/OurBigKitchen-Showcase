import Foundation
import ComposableArchitecture
import UIKit

@Reducer
public struct ImpactFeature {
    @ObservableState
    public struct State: Equatable {
        public var selectedTags: [String] = ["#Cooking", "#Volunteering"]
        public var caption: String = ""
        public var showToast: Bool = false
        public var toastMessage: String = ""
        public var showImagePicker: Bool = false
        public var selectedImage: UIImage?
        
        public var totalMealsServed: Int = 0
        public var familiesHelped: Int = 0
        public var livesTouched: Int = 0
        public var foodSavedKg: Double = 0.0
        
        public let allTags = ["#Cooking", "#Serving", "#Volunteering", "#Donations", "#Community", "#Help"]
        
        public var impactMetrics: [AppModels.ImpactMetric] = []
        public var todayMetrics: AppModels.ImpactMetric = AppModels.ImpactMetric(
            mealsServed: 0,
            foodSavedKg: 0.0,
            familiesHelped: 0,
            livesTouched: 0
        )
        public var isLoading = false
        public var error: String?
        
        public init() {}
        
        public static func == (lhs: State, rhs: State) -> Bool {
            lhs.selectedTags == rhs.selectedTags &&
            lhs.caption == rhs.caption &&
            lhs.showToast == rhs.showToast &&
            lhs.toastMessage == rhs.toastMessage &&
            lhs.showImagePicker == rhs.showImagePicker &&
            lhs.totalMealsServed == rhs.totalMealsServed &&
            lhs.familiesHelped == rhs.familiesHelped &&
            lhs.livesTouched == rhs.livesTouched &&
            lhs.foodSavedKg == rhs.foodSavedKg &&
            lhs.impactMetrics == rhs.impactMetrics &&
            lhs.todayMetrics == rhs.todayMetrics &&
            lhs.isLoading == rhs.isLoading &&
            lhs.error == rhs.error
            // Note: UIImage is not Equatable, so we skip it in the comparison
        }
    }
    
    public enum Action: Equatable {
        case setShowImagePicker(Bool)
        case setSelectedImage(UIImage?)
        case captionChanged(String)
        case tagSelected(String)
        case resetTapped
        case logActivityTapped
        case viewInsightsTapped
        case showToast(message: String)
        case hideToast
        case fetchImpactStats
        case fetchImpactStatsResponse(TaskResult<AppModels.ImpactMetric>)
        case onAppear
        case refreshData
        case loadImpactMetrics
        case impactMetricsLoaded([AppModels.ImpactMetric])
        case todayMetricsLoaded(AppModels.ImpactMetric)
        case errorOccurred(String)
    }
    
    @Dependency(\.impact) var impact
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .setShowImagePicker(isPresented):
                state.showImagePicker = isPresented
                return .none
                
            case let .setSelectedImage(image):
                state.selectedImage = image
                state.showImagePicker = false
                return .none
                
            case let .captionChanged(caption):
                state.caption = caption
                return .none
                
            case let .tagSelected(tag):
                if state.selectedTags.contains(tag) {
                    state.selectedTags.removeAll { $0 == tag }
                } else {
                    state.selectedTags.append(tag)
                }
                return .none
                
            case .resetTapped:
                state.selectedTags = ["#Cooking", "#Volunteering"]
                state.caption = ""
                state.selectedImage = nil
                return .send(.showToast(message: "Reset complete"))
                
            case .logActivityTapped:
                return .send(.showToast(message: "Activity logged!"))
                
            case .viewInsightsTapped:
                return .send(.showToast(message: "Insights coming soon!"))
                
            case let .showToast(message):
                state.toastMessage = message
                state.showToast = true
                return .run { send in
                    try await Task.sleep(for: .seconds(2))
                    await send(.hideToast)
                }
                
            case .hideToast:
                state.showToast = false
                return .none
                
            case .fetchImpactStats:
                return .run { send in
                    await send(.fetchImpactStatsResponse(TaskResult { try await impact.fetchImpact() }))
                }
                
            case let .fetchImpactStatsResponse(.success(stats)):
                state.totalMealsServed = stats.mealsServed
                state.familiesHelped = stats.familiesHelped
                state.livesTouched = stats.livesTouched
                state.foodSavedKg = stats.foodSavedKg
                return .none
                
            case let .fetchImpactStatsResponse(.failure(error)):
                return .send(.showToast(message: error.localizedDescription))
                
            case .onAppear:
                return .send(.loadImpactMetrics)
                
            case .refreshData:
                return .send(.loadImpactMetrics)
                
            case .loadImpactMetrics:
                state.isLoading = true
                state.error = nil
                return .run { send in
                    // Simulate loading impact metrics
                    try await Task.sleep(for: .milliseconds(500))
                    
                    let mockMetrics = [
                        AppModels.ImpactMetric(
                            mealsServed: 150,
                            foodSavedKg: 75.5,
                            familiesHelped: 12,
                            livesTouched: 48
                        )
                    ]
                    
                    await send(.impactMetricsLoaded(mockMetrics))
                    await send(.todayMetricsLoaded(mockMetrics.first!))
                }
                
            case .impactMetricsLoaded(let metrics):
                state.isLoading = false
                state.impactMetrics = metrics
                return .none
                
            case .todayMetricsLoaded(let metrics):
                state.todayMetrics = metrics
                return .none
                
            case .errorOccurred(let error):
                state.isLoading = false
                state.error = error
                return .none
            }
        }
    }
} 