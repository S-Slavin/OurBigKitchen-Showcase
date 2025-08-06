import Foundation
import ComposableArchitecture

// MARK: - Auth Client
struct AuthClient {
    var signIn: @Sendable (String, String) async throws -> AppModels.User
    var signOut: @Sendable () async throws -> Void
    var getCurrentUser: @Sendable () async throws -> AppModels.User?
}

extension AuthClient: DependencyKey {
    static let liveValue = AuthClient(
        signIn: { email, password in
            // Mock implementation
            return AppModels.User(
                id: UUID(),
                firstName: "Test",
                lastName: "User",
                email: email,
                role: .individual
            )
        },
        signOut: {
            // Mock implementation
        },
        getCurrentUser: {
            // Mock implementation
            return nil
        }
    )
}

// MARK: - Impact Client
struct ImpactClient {
    var getMetrics: @Sendable () async throws -> [AppModels.ImpactMetric]
    var submitMetric: @Sendable (AppModels.ImpactMetric) async throws -> AppModels.ImpactMetric
    var fetchImpact: @Sendable () async throws -> AppModels.ImpactMetric
}

extension ImpactClient: DependencyKey {
    static let liveValue = ImpactClient(
        getMetrics: {
            // Mock implementation
            return [
                AppModels.ImpactMetric(
                    mealsServed: 150,
                    foodSavedKg: 75.5,
                    familiesHelped: 12,
                    livesTouched: 48,
                    timestamp: Date()
                )
            ]
        },
        submitMetric: { metric in
            // Mock implementation
            return metric
        },
        fetchImpact: {
            // Mock implementation for ImpactFeature
            return AppModels.ImpactMetric(
                mealsServed: 150,
                foodSavedKg: 75.5,
                familiesHelped: 12,
                livesTouched: 48,
                timestamp: Date()
            )
        }
    )
}

// MARK: - Session Client
struct SessionClient {
    var getCurrentSession: @Sendable () async throws -> AppModels.Session?
    var createSession: @Sendable (AppModels.User) async throws -> AppModels.Session
    var endSession: @Sendable () async throws -> Void
}

extension SessionClient: DependencyKey {
    static let liveValue = SessionClient(
        getCurrentSession: {
            // Mock implementation
            return nil
        },
        createSession: { user in
            // Mock implementation
            return AppModels.Session(
                id: UUID(),
                userId: user.id,
                startTime: Date(),
                isActive: true
            )
        },
        endSession: {
            // Mock implementation
        }
    )
}

// MARK: - Terms Client
struct TermsClient {
    var getTerms: @Sendable () async throws -> String
    var acceptTerms: @Sendable () async throws -> Void
    var hasAcceptedTerms: @Sendable () async throws -> Bool
}

extension TermsClient: DependencyKey {
    static let liveValue = TermsClient(
        getTerms: {
            // Mock implementation
            return "Terms and Conditions..."
        },
        acceptTerms: {
            // Mock implementation
        },
        hasAcceptedTerms: {
            // Mock implementation
            return false
        }
    )
}

// MARK: - Dependency Values Extension
extension DependencyValues {
    var auth: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
    
    var impact: ImpactClient {
        get { self[ImpactClient.self] }
        set { self[ImpactClient.self] = newValue }
    }
    
    var session: SessionClient {
        get { self[SessionClient.self] }
        set { self[SessionClient.self] = newValue }
    }
    
    var terms: TermsClient {
        get { self[TermsClient.self] }
        set { self[TermsClient.self] = newValue }
    }
} 