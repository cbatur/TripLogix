import SwiftUI
import GoogleSignIn

class GoogleSignInViewModel: ObservableObject {
    @Published var user: GIDGoogleUser? = nil

    init() {
        // Restore previous sign-in if any
        GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
            if let error = error {
                print("Failed to restore previous sign-in: \(error.localizedDescription)")
            } else {
                self?.user = user
            }
        }
    }

    func signIn() {
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else { return }
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            if let error = error {
                print("Sign-in failed: \(error.localizedDescription)")
            } else {
                self?.user = result?.user
            }
        }
    }

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        self.user = nil
    }
}
