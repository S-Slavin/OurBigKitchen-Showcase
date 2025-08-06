import Foundation
import Combine
import SwiftUI

class SessionService: ObservableObject {
    @Published var isSessionActive = false
    @Published var sessionStartTime: Date?
    @Published var sessionDuration: TimeInterval = 0
    @Published private(set) var sessions: [Session] = []
    
    static let shared = SessionService()
    
    private var timer: Timer?
    
    private init() {}
    
    func startSession() {
        sessionStartTime = Date()
        isSessionActive = true
        startTimer()
    }
    
    func endSession() {
        isSessionActive = false
        stopTimer()
        if let startTime = sessionStartTime {
            let session = Session(
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
    
    func getSessions() -> [Session] {
        return sessions
    }
} 