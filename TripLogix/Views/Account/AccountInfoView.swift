
import SwiftUI
import PopupView
import ScrollKit

struct AccountInfoView: View {
    @State var user: User
    
    var heroBanner: Image = Image("account-hero-1")
    var body: some View {
        AccountInfoViewFeed(user: user, headerHeight: 150) {
            ZStack {
                ScrollViewHeaderImage(heroBanner)
                StripedPattern()
                    .opacity(0.2)
                ScrollViewHeaderGradient(.black.opacity(0.4), .black.opacity(0.8))
            }
        }
    }
}

struct AccountInfoViewFeed<HeaderView: View>: View {
    @State var user: User
    @StateObject private var viewModel = SessionViewModel()

    @State private var privacyPolicyLaunch: Bool = false
    @State private var termsAgreementsLaunch: Bool = false
    @State private var editNameModal: Bool = false
    @State private var launchVerificationFooter: Bool = false
    @State private var verificationCode: String = ""
    @State private var launchPasswordChangeFooter: Bool = false
    @State private var launchAccountDeletion: Bool = false
    @State private var showLoginSheet = false
    
    let headerHeight: CGFloat

    @ViewBuilder
    let headerView: () -> HeaderView

    @State
    private var headerVisibleRatio: CGFloat = 1

    @State
    private var scrollOffset: CGPoint = .zero
    
    func handleScrollOffset(_ offset: CGPoint, headerVisibleRatio: CGFloat) {
        self.scrollOffset = offset
        self.headerVisibleRatio = headerVisibleRatio
    }

    func reloadUser(_ user: User) {
        self.user = user
    }
    
    var body: some View {
        ScrollViewWithStickyHeader(
            header: header,
            headerHeight: 80,
            onScroll: handleScrollOffset
        ) {
            VStack {
                if user.emailVerified == 0 {
                    VStack {
                        Text("Username: \(user.username)")
                        Text("email: \(user.email)")
                        Text("emailVerified: \(user.emailVerified)")
                    }
                } else {
                    VStack {
                        avatarView
                        personalInfoView
                        userConsentView
                            .padding(.top, 20)
                        logoutView
                    }
                    .padding()
                }
            }
        }
        .background(Color.slBack1)
        .padding(.bottom, 1)
        .toolbarBackground(.hidden)
        .statusBarHidden(scrollOffset.y > -3)
        .toolbarColorScheme(.dark, for: .navigationBar)
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
        .onAppear {
            if user.email.isEmpty {
                viewModel.logout()
            }
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
    
    func header() -> some View {
        ZStack(alignment: .bottomLeading) {
            headerView()
            ScrollViewHeaderGradient()
            headerContent.previewHeaderContent()
        }
    }

    var headerContent: some View {
        VStack {
            HStack {
                Text("Account")
                    .font(.custom("Gilroy-Bold", size: 25))
                    .foregroundStyle(Color.gray7)
            }
        }
        .padding(.top, 30)
        .padding()
        .opacity(headerVisibleRatio)
    }
    
    private var avatarView: some View {
        VStack {
            HStack {
                DestinationIconDataView(iconData: nil, size: 65)
                    .opacity(0.7)
                VStack {
                    HStack {
                        Text("\(user.username)")
                            .font(.system(size: 23)).bold()
                            .foregroundStyle(.gray)
                        Spacer()
                    }
                                        
                    HStack {
                        Text("Free Member")
                            .foregroundStyle(.gray)
                            .font(.system(size: 16))
                        Spacer()
                    }
                }
                .padding(.leading, 9)
            }
            
            Divider()

            HStack {
                Text("Avatar ")
                    .foregroundStyle(.gray)
                    .font(.system(size: 16))
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .cardStyle(.white)
    }
    
    private var personalInfoView: some View {
        
        VStack {
            HStack {
                Text("Personal Information".uppercased())
                    .font(.caption)
                    .foregroundStyle(Color.slSofiColor)
                Spacer()
            }
        
            VStack {
                HStack {
                    Text("Name ")
                        .foregroundStyle(.black)
                        .font(.system(size: 16))
                    Spacer()
                    if user.firstname.isEmpty {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.tlGreen)
                            .font(.system(size: 25))
                    } else {
                        Text("\(user.firstname)")
                            .foregroundColor(.gray)
                            .font(.system(size: 16))
                    }
                }
                .padding(.vertical, 4)
                .onTapGesture {
                    editNameModal = true
                }
                Divider()
                
                HStack {
                    Text("Email ")
                        .foregroundStyle(.black)
                        .font(.system(size: 16))
                    Spacer()
                    Text("\(user.email)")
                        .foregroundColor(.gray)
                        .font(.system(size: 16))
                }
                .padding(.vertical, 4)
                Divider()
                
                HStack {
                    Text("Change Password ")
                        .foregroundStyle(.black)
                        .font(.system(size: 16))
                    Spacer()
                    Image(systemName: "lock")
                        .foregroundColor(.gray)
                        .font(.system(size: 16))
                }
                .padding(.vertical, 4)
                .onTapGesture {
                    launchPasswordChangeFooter = true
                }
            }
            .padding(10)
            .cardStyle(.white)
            .transition(.opacity)
        }
        .padding(.top, 20)
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
        VStack {
            
            VStack {
                HStack {
                    Text("Privacy Policy ")
                        .foregroundStyle(.black)
                        .font(.system(size: 16))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 4)
                .onTapGesture {
                    privacyPolicyLaunch = true
                }
                
                Divider()
                
                HStack {
                    Text("Terms and Agreements ")
                        .foregroundStyle(.black)
                        .font(.system(size: 16))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 4)
                .onTapGesture {
                    termsAgreementsLaunch = true
                }
                
                Divider()
                
                HStack {
                    Text("Delete Account ")
                        .foregroundStyle(.black)
                        .font(.system(size: 16))
                    Spacer()
                }
                .padding(.vertical, 4)
                .onTapGesture {
                    launchAccountDeletion = true
                }
            }
        }
        .padding(10)
        .cardStyle(.white)
        .transition(.opacity)
    }
    
    private var logoutView: some View {
        HStack {
            Spacer()
            Text("Logout")
                .foregroundColor(.cbRed)
                .onTapGesture {
                    showLoginSheet = true
                }
        }
        .padding()
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
