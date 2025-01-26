import SwiftUI

struct UserCardView: View {
    @StateObject var viewModel: UserCardViewModel = UserCardViewModel()
    let user: TLUser
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                AsyncImage(url: URL(string: "user.profileImageURL")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 60)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.formatUserFullName(user))
                        .foregroundStyle(.black)
                        .font(.headline)
                    Text(user.username)
                        .font(.subheadline)
                        .foregroundColor(.black)
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundColor(user.emailVerified == "1" ? .slSofiColor : .gray)
                }
                Spacer()
            }
            
            HStack {
                Text("Login Date\n\(user.loginDate)")
                Spacer()
                Text("Created\n\(user.memberDate)")
            }
            .foregroundStyle(.gray)
            .font(.caption)
        }
        .padding()
        .cardStyle(.white)
    }
}

final class UserCardViewModel: ObservableObject {
    
    func formatUserFullName(_ user: TLUser) -> String {
        return "\(user.firstName ?? "_") \(user.lastName ?? "_")"
    }
    
}
