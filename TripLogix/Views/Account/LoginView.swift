import SwiftUI
import PopupView

struct ToastTopFirst: View {
    var body: some View {
        Text("Invalid Login - Check your login credentials and try again.")
            .foregroundColor(.white)
            .padding(EdgeInsets(top: 60, leading: 32, bottom: 16, trailing: 32))
            .frame(maxWidth: .infinity)
            .background(Color.red)
    }
}

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""

    @StateObject private var facebookLoginViewModel = FacebookLoginViewModel()
    @StateObject private var googleSignInViewModel = GoogleSignInViewModel()
    @StateObject private var viewModel = SessionViewModel()
    
    private func getValidationEmailColor() -> Color {
        if email.isEmpty {
            return .gray
        } else if viewModel.isValidEmail(email) {
            return .teal
        } else {
            return .red
        }
    }
    
    private func readyForLogin() -> Bool {
        return viewModel.isValidEmail(email) && viewModel.isValidPassword(password)
    }
    
    var body: some View {
        
        VStack {
            VStack {
                HStack {
                    Text("Log ")
                        .font(.custom("Gilroy-Bold", size: 25))
                        .foregroundColor(.black) +
                    Text("In")
                        .font(.custom("Gilroy-Regular", size: 25))
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.login(
                            email: self.email,
                            password: self.password
                        )
                    }) {
                        Image(systemName: "arrow.right.circle")
                            .font(.largeTitle).bold()
                            .foregroundColor(readyForLogin() ? Color.tlGreen : .gray8)
                            .cornerRadius(5)
                    }
                    .disabled(!readyForLogin())
                }
                
                HStack {
                    Text("Sign-in to an existing account")
                        .font(.system(size: 16))
                        .foregroundColor(.gray3)
                    Spacer()
                }
                
                Divider()
            }
            .padding()
            
            VStack {
                HStack {
                    Text(viewModel.getSignInEmailValidationMessage(self.email))
                        .font(.system(size: 14))
                        .foregroundColor(getValidationEmailColor())
                    Spacer()
                }
                
                HStack {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    if viewModel.isValidEmail(email) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.teal)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray8, lineWidth: 1)
            )
            .padding(.horizontal, 20)
            
            SecureField("Password", text: $password)
                .padding()
                .background(.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray8, lineWidth: 1)
                )
                .padding(.horizontal, 20)
            
            HStack {
                Spacer()
                Button(action: {
                    // Handle forgot password action
                }) {
                    Text("Forgot Password?")
                        .font(.system(size: 15))
                        .foregroundColor(.blue)
                }
            }
            .padding()
            
            Spacer()
            
            VStack {
                if let user = googleSignInViewModel.user {
                    Button(action: googleSignInViewModel.signOut) {
                        Text("Logout \(user)")
                    }
                } else {
                    buttonLoginGoogle
                        .isHidden(Configuration.googleLoginDisabled)
                }

                if facebookLoginViewModel.isLoggedIn {
                    Button(action: facebookLoginViewModel.logout) {
                        Text("Logout \(facebookLoginViewModel.userName ?? "User")")
                    }
                } else {
                    buttonLoginFacebook
                        .isHidden(Configuration.facebookLoginDisabled)
                }
            }
        }
        .padding(.top, 30)
        .popup(isPresented: $viewModel.isMarkedForDeletion) {
            FloatAlertView(response: TLResponse(message: "This account is marked for deletion.", success: false))
        } customize: {
            $0
                .type(.floater())
                .position(.top)
                .animation(.spring())
                .autohideIn(3)
        }
        .popup(isPresented: $viewModel.invalidLogin) {
            ToastTopFirst()
        } customize: {
            $0
                .type(.floater())
                .position(.top)
                .animation(.spring())
                .closeOnTapOutside(true)
                .autohideIn(3)
                .dismissCallback {
                    print("did", $0)
                }
                .willDismissCallback {
                    print("will", $0)
                }
        }
    }
    
    private var buttonLoginFacebook: some View {
        HStack {
            Image("logo_facebook")
                .resizable()
                .frame(width: 24, height: 24)
            Text("Continue with Facebook")
        }
        .padding(.horizontal, 15)
        .padding(9)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyleBordered()
        .padding()
        .onTapGesture {
            facebookLoginViewModel.login()
        }
    }
    
    private var buttonLoginGoogle: some View {
        HStack {
            Image("logo_google")
                .resizable()
                .frame(width: 24, height: 24)
            Text("Login with Google")
        }
        .padding(.horizontal, 15)
        .padding(9)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyleBordered()
        .padding()
        .onTapGesture {
            googleSignInViewModel.signIn()
        }
    }
}
