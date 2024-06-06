
import SwiftUI
import PopupView

struct UserHasSessionView: View {
    @State var user: User
    @StateObject private var viewModel = SessionViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var privacyPolicyLaunch: Bool = false
    @State private var termsAgreementsLaunch: Bool = false

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
                
                Section(header: Text("")) {
                    HStack {
                        Text("Privacy Policy ")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .onTapGesture {
                        privacyPolicyLaunch = true
                    }
                    
                    HStack {
                        Text("Terms and Agreements ")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .onTapGesture {
                        termsAgreementsLaunch = true
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
        .popup(isPresented: $privacyPolicyLaunch) {
            PrivacyPolicyView()
        } customize: {
            $0
                .type(.scroll(headerView: AnyView(scrollViewHeader())))
                .position(.bottom)
                .closeOnTap(false)
                .backgroundColor(.black.opacity(0.4))
        }
        .popup(isPresented: $termsAgreementsLaunch) {
            TermsAgreementsView()
        } customize: {
            $0
                .type(.scroll(headerView: AnyView(scrollViewHeader())))
                .position(.bottom)
                .closeOnTap(false)
                .backgroundColor(.black.opacity(0.4))
        }
    }
    
    #if os(iOS)
        func scrollViewHeader() -> some View {
            ZStack {
                Color(.white).cornerRadius(40, corners: [.topLeft, .topRight])

                Color.black
                    .opacity(0.2)
                    .frame(width: 30, height: 6)
                    .clipShape(Capsule())
                    .padding(.vertical, 20)
            }
        }
    #endif

}

struct PrivacyPolicyView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Privacy Policy")
                .font(.system(size: 24))

            Text(Constants.privacyPolicy)
                .font(.system(size: 14))
                .opacity(0.6)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .padding(.bottom, 24)
        .background(.white)
    }
}

struct TermsAgreementsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Terms and Agreements")
                .font(.system(size: 24))

            Text(Constants.termsAgreements)
                .font(.system(size: 14))
                .opacity(0.6)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .padding(.bottom, 24)
        .background(.white)
    }
}
