import Foundation
import Combine
import SwiftUI

@Observable
public final class SessionService: @unchecked Sendable {
    public var isSessionActive = false
    public var sessionStartTime: Date?
    public var sessionDuration: TimeInterval = 0
    public private(set) var sessions: [AppModels.Session] = []
    
    public static let shared = SessionService()
    
    private var timer: Timer?
    
    public init() {}
    
    public func startSession() async throws {
        sessionStartTime = Date()
        isSessionActive = true
        startTimer()
    }
    
    public func endSession() async throws {
        isSessionActive = false
        stopTimer()
        if let startTime = sessionStartTime {
            let session = AppModels.Session(
                id: UUID().uuidString,
                startTime: startTime,
                endTime: Date(),
                duration: sessionDuration
            )
            sessions.append(session)
        }
        sessionStartTime = nil
        sessionDuration = 0
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.sessionStartTime else { return }
            self.sessionDuration = Date().timeIntervalSince(startTime)
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    public func getSessions() async throws -> [AppModels.Session] {
        return sessions
    }
} 