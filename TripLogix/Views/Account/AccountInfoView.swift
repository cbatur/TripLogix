
import SwiftUI
import PopupView

struct AccountInfoView: View {
    @State var user: User
    @StateObject private var viewModel = SessionViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var privacyPolicyLaunch: Bool = false
    @State private var termsAgreementsLaunch: Bool = false
    @State private var editNameModal: Bool = false

    func reloadUser(_ user: User) {
        self.user = user
    }
    
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
            .padding(.top, 20)
            
            Form {
                Section(header: Text("")) {
                    HStack {
                        DestinationIconDataView(iconData: nil, size: 65)
                            .opacity(0.7)
                        VStack {
                            HStack {
                                Text("\(user.username)")
                                    .font(.system(size: 23)).bold()
                                Spacer()
                            }
                            HStack {
                                Text("Free Member")
                                Spacer()
                            }
                        }
                        .padding(.leading, 9)
                    }
                    
                    HStack {
                        Text("Avatar ")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
                
                Section(header: Text("Personal Information")) {
                    HStack {
                        Text("Name: ")
                        Spacer()
                        if user.firstname.isEmpty {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.tlGreen)
                                .font(.system(size: 25))
                        } else {
                            Text("\(user.firstname)")
                                .foregroundColor(.gray)
                        }
                    }
                    .onTapGesture {
                        editNameModal = true
                    }
                    HStack {
                        Text("Email: ")
                        Spacer()
                        Text("\(user.email)")
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("Change Password ")
                        Spacer()
                        Image(systemName: "lock")
                            .foregroundColor(.gray)
                    }                }
                
                Section(header: Text("")) {
                    HStack {
                        Text("Privacy Policy ")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .onTapGesture {
                        privacyPolicyLaunch = true
                    }
                    
                    HStack {
                        Text("Terms and Agreements ")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .onTapGesture {
                        termsAgreementsLaunch = true
                    }
                    
                    HStack {
                        Text("Delete Account ")
                        Spacer()
                        
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
        .popup(isPresented: $editNameModal) {
            EditNameFooterView(isShowing: $editNameModal, reloadParent: reloadUser)
        } customize: {
            $0
                .position(.bottom)
                .closeOnTap(false)
                .backgroundColor(.black.opacity(0.4))
                .isOpaque(true)
                .useKeyboardSafeArea(true)
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
