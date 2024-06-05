
import SwiftUI

struct UserHasSessionView: View {
    @State var user: User
    @StateObject private var viewModel = SessionViewModel()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            HStack {
                Text("Account")
                    .font(.system(size: 27)).bold()
                    .padding(.leading, 33)
                Spacer()
                Image(systemName: "x.circle")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
                    .onTapGesture {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding()
            }
            
            Form {
                Section(header: Text("\(user.username)")) {
                    HStack {
                        Text("First Name: ")
                        Spacer()
                        Text("\(user.firstname)")
                    }
                    HStack {
                        Text("Last Name: ")
                        Spacer()
                        Text("\(user.lastname)")
                    }
                    HStack {
                        Text("Email: ")
                        Spacer()
                        Text("\(user.email)")
                    }
                }
                                
                HStack {
                    Spacer()
                    Text("Logout")
                        .foregroundColor(.cbRed)
                        .onTapGesture {
                            viewModel.logout()
                        }
                    Spacer()
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
}
