
import SwiftUI

struct SessionCheckView: View {
    @StateObject private var viewModel = SessionViewModel()
    @EnvironmentObject var sessionManager: SessionManager
    
    var body: some View {
        VStack {
            if let currentUser = sessionManager.currentUser {
                AccountInfoView(user: currentUser)
            } else {
                UserNeedsSessionView()
            }
        }
        .onAppear {
            if let currentUser = sessionManager.currentUser {
                viewModel.username = currentUser.username
            }
        }
    }
}
