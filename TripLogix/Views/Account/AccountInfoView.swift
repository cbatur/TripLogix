
import SwiftUI
import PopupView

struct AccountInfoView: View {
    @State var user: User
    @StateObject private var viewModel = SessionViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var privacyPolicyLaunch: Bool = false
    @State private var termsAgreementsLaunch: Bool = false
    @State private var editNameModal: Bool = false
    @State private var launchVerificationFooter: Bool = false
    @State private var verificationCode: String = ""
    @State private var launchPasswordChangeFooter: Bool = false
    @State private var launchAccountDeletion: Bool = false
    @State private var showLoginSheet = false

    func reloadUser(_ user: User) {
        self.user = user
    }
    
    var body: some View {
        VStack {
            if user.emailVerified == 0 {
                EmptyView()
            } else {
                navigationView
                Form {
                    avatarView
                    personalInfoView
                    userConsentView
                    logoutView
                }
            }
        }
        .onAppear {
            if user.emailVerified == 0 {
                launchVerificationFooter = true
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
        .popup(isPresented: $launchVerificationFooter) {
            EmailVerificationFooterView(isShowing: $launchVerificationFooter, reloadParent: reloadUser)
        } customize: {
            $0
                .position(.bottom)
                .closeOnTap(false)
                .backgroundColor(.black.opacity(0.4))
                .isOpaque(true)
                .useKeyboardSafeArea(true)
        }
        .popup(isPresented: $launchPasswordChangeFooter) {
            ChangePasswordFooterView(isShowing: $launchPasswordChangeFooter, reloadParent: reloadUser)
        } customize: {
            $0
                .position(.bottom)
                .closeOnTap(false)
                .backgroundColor(.black.opacity(0.4))
                .isOpaque(true)
                .useKeyboardSafeArea(true)
        }
        .popup(isPresented: $launchAccountDeletion) {
            DeleteAccountView(
                email: $user.email,
                isShowing: $launchAccountDeletion,
                reloadParent: reloadUser
            )
        } customize: {
            $0
                .position(.bottom)
                .closeOnTap(false)
                .backgroundColor(.black.opacity(0.4))
                .isOpaque(true)
                .useKeyboardSafeArea(true)
        }
        .actionSheet(isPresented: $showLoginSheet) {
            ActionSheet(
                title: Text("Logout?"),
                message: Text(""),
                buttons: [
                    .default(Text("YES"), action: {
                        viewModel.logout()
                    }),
                    .cancel(Text("Cancel"))
                ]
            )
        }
    }
    
    private var navigationView: some View {
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
    }
    
    private var avatarView: some View {
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
    }
    
    private var personalInfoView: some View {
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
            }
            .onTapGesture {
                launchPasswordChangeFooter = true
            }
        }
    }
    
    private var unverifiedUserView: some View {
        //Section(header: Text("Verify account")) {
            VStack {
                HStack {
                    TextField("Verification Code", text: $verificationCode)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    Button(action: {
                        // Submit verification code
                    }) {
                        Text("Submit")
                            .font(.custom("Gilroy-Medium", size: 15))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(9)
                            .cardStyle(.teal)
                    }
                }
                .padding()
            }
            
        //}
    }
    
    private var userConsentView: some View {
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
            .onTapGesture {
                launchAccountDeletion = true
            }
        }
    }
    
    private var logoutView: some View {
        HStack {
            Spacer()
            Text("Logout")
                .foregroundColor(.cbRed)
                .onTapGesture {
                    showLoginSheet = true
                }
            Spacer()
        }
    }
    
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
