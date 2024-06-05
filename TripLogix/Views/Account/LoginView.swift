
import SwiftUI

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
            
            // Email Field for sign-in
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
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            .padding(.horizontal, 20)
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .padding(.horizontal, 20)
            
            Button(action: {
                // Handle forgot password action
            }) {
                Text("Forgot Password?")
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            VStack(spacing: 10) {
                Button(action: {
                    // Handle Apple sign-in
                }) {
                    HStack {
                        Image(systemName: "a.square")
                        Text("Continue with Apple")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                }
                
                
                if let user = googleSignInViewModel.user {
                    Button(action: googleSignInViewModel.signOut) {
                        Text("Logout \(user)")
                    }
                } else {
                    Button(action: {
                        googleSignInViewModel.signIn()
                    }) {
                        HStack {
                            Image(systemName: "g.square")
                            Text("Continue with Google")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                    }
                }
                
                if facebookLoginViewModel.isLoggedIn {
                    Button(action: facebookLoginViewModel.logout) {
                        Text("Logout \(facebookLoginViewModel.userName ?? "User")")
                    }
                } else {
                    Button(action: {
                        facebookLoginViewModel.login()
                    }) {
                        HStack {
                            Image(systemName: "f.square")
                            Text("Continue with Facebook")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                    }
                }
            }
        }
        .padding(.top, 30)
    }
}
