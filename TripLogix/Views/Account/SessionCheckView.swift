
import SwiftUI

struct SessionCheckView: View {
    @Binding var selectedView: Int
    @StateObject private var viewModel = SessionViewModel()
    @EnvironmentObject var sessionManager: SessionManager
    
    func reload() {
        if let currentUser = sessionManager.currentUser {
            viewModel.username = currentUser.username
        }
    }
    
    var body: some View {
        VStack {
            if let currentUser = sessionManager.currentUser {
                AccountInfoView(user: currentUser)
            } else {
                UserNeedsSessionView(reloadParent: reload)
            }
        }
        .onAppear {
           reload()
        }
    }
}
