import Foundation
import FacebookLogin
import FBSDKCoreKit
import FBSDKLoginKit

class FacebookLoginViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var userName: String? = nil
    
    private let loginManager = LoginManager()
    
    func login() {
        loginManager.logIn(permissions: ["public_profile", "email"], from: nil) { result, error in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            
            guard let result = result, !result.isCancelled else {
                print("Login cancelled")
                return
            }
            
            self.fetchProfile()
        }
    }
    
    func fetchProfile() {
        GraphRequest(graphPath: "me", parameters: ["fields": "id, name"]).start { _, result, error in
            if let error = error {
                print("Failed to fetch profile: \(error.localizedDescription)")
                return
            }
            if let profileData = result as? [String: Any] {
                self.userName = profileData["name"] as? String
                self.isLoggedIn = true
            }
        }
    }
    
    func logout() {
        loginManager.logOut()
        self.isLoggedIn = false
        self.userName = nil
    }
}
