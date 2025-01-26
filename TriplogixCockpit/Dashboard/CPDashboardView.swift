import SwiftUI

struct CPDashboardView: View {
    @Binding var selectedView: Int
    
    var body: some View {
        NavigationView {
            UserCardListView()
                .background(Color.slBack1)
        }
    }
}

struct TLUser: Decodable, Identifiable {
    let id: String
    let username: String
    let firstName: String?
    let lastName: String?
    let email: String
    let memberDate: String
    let loginDate: String
    let emailVerified: String
}

struct UserCardListView: View {
    @StateObject var viewModel: CPDashBoardViewModel = CPDashBoardViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(viewModel.users) { user in
                    UserCardView(user: user)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Users")
        .onAppear {
            Task {
                await viewModel.submitQuery()
            }
        }
    }
}
