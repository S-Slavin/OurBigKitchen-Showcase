import XCTest
import ComposableArchitecture
@testable import OurBigKitchen

@MainActor
final class MainFeatureTests: XCTestCase {
    func testInitialState() async {
        let store = TestStore(
            initialState: MainFeature.State(),
            reducer: MainFeature()
        )
        
        XCTAssertEqual(store.state.selectedTab, .home)
    }
    
    func testTabSelection() async {
        let store = TestStore(
            initialState: MainFeature.State(),
            reducer: MainFeature()
        )
        
        // Test selecting impact tab
        await store.send(.tabSelected(.impact)) {
            $0.selectedTab = .impact
        }
        
        // Test selecting profile tab
        await store.send(.tabSelected(.profile)) {
            $0.selectedTab = .profile
        }
        
        // Test selecting home tab
        await store.send(.tabSelected(.home)) {
            $0.selectedTab = .home
        }
    }
    
    func testAllTabsExist() {
        let tabs = [MainFeature.State.Tab.home, .impact, .profile]
        XCTAssertEqual(tabs.count, 3)
    }
} 