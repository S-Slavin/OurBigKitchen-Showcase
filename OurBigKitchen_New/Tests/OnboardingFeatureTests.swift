import XCTest
import ComposableArchitecture
@testable import OurBigKitchen

@MainActor
final class OnboardingFeatureTests: XCTestCase {
    func testInitialState() async {
        let store = TestStore(
            initialState: OnboardingFeature.State(),
            reducer: OnboardingFeature()
        )
        
        XCTAssertEqual(store.state.currentPage, .welcome)
    }
    
    func testGetStartedTapped() async {
        let store = TestStore(
            initialState: OnboardingFeature.State(),
            reducer: OnboardingFeature()
        )
        
        await store.send(.getStartedTapped)
        await store.receive(.delegate(.didCompleteOnboarding))
    }
    
    func testAllPagesExist() {
        let pages = OnboardingFeature.Page.allCases
        XCTAssertEqual(pages.count, 4)
        XCTAssertTrue(pages.contains(.welcome))
        XCTAssertTrue(pages.contains(.impact))
        XCTAssertTrue(pages.contains(.community))
        XCTAssertTrue(pages.contains(.last))
    }
} 