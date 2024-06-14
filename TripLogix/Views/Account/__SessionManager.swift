import Foundation
import Combine

class SessionManager: ObservableObject {
    static let shared = SessionManager()
    
    @Published var currentUser: User?
    @Published var sessionId: UUID?
    
    private init() {
        loadSession()
    }
    
    func createSession(for user: User) {
        let sessionId = UUID()
        self.sessionId = sessionId
        self.currentUser = user
        saveSession(sessionId: sessionId, user: user)
    }
    
    func destroySession() {
        sessionId = nil
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: "sessionId")
        UserDefaults.standard.removeObject(forKey: "currentUser")
    }
    
    private func saveSession(sessionId: UUID, user: User) {
        UserDefaults.standard.set(sessionId.uuidString, forKey: "sessionId")
        if let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: "currentUser")
        }
    }
    
    func loadSession() {
        if let sessionIdString = UserDefaults.standard.string(forKey: "sessionId"),
           let sessionId = UUID(uuidString: sessionIdString),
           let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            self.sessionId = sessionId
            self.currentUser = user
        }
    }
}
