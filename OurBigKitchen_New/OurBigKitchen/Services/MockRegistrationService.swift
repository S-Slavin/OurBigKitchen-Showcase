import Foundation
import Combine

class MockRegistrationService: RegistrationService {
    enum MockScenario {
        case success
        case networkError
        case invalidData
        case serverError
        case delayedSuccess(delay: TimeInterval)
    }
    
    var mockScenario: MockScenario = .success
    
    init(scenario: MockScenario = .success) {
        self.mockScenario = scenario
        super.init()
    }
    
    override func submitRegistration(_ data: RegistrationData) -> AnyPublisher<Void, RegistrationError> {
        switch mockScenario {
        case .success:
            return Just(())
                .setFailureType(to: RegistrationError.self)
                .eraseToAnyPublisher()
            
        case .networkError:
            return Fail(error: RegistrationError.networkError(NSError(domain: "MockError", code: -1009, userInfo: [NSLocalizedDescriptionKey: "No internet connection"])))
                .eraseToAnyPublisher()
            
        case .invalidData:
            return Fail(error: RegistrationError.invalidData)
                .eraseToAnyPublisher()
            
        case .serverError:
            return Fail(error: RegistrationError.serverError("Mock server error"))
                .eraseToAnyPublisher()
            
        case .delayedSuccess(let delay):
            return Just(())
                .delay(for: .seconds(delay), scheduler: DispatchQueue.main)
                .setFailureType(to: RegistrationError.self)
                .eraseToAnyPublisher()
        }
    }
} 