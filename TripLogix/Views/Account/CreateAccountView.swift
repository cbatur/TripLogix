
import SwiftUI

struct CreateAccountView: View {
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var passwordConfirm: String = ""
    @StateObject private var viewModel = SessionViewModel()
    @State private var isLogin: Bool = true
    
    private func getValidationColor() -> Color {
        if username.isEmpty || username.count < 8 {
            return .gray
        } else if viewModel.usernameCheck.success && viewModel.isValidUsername(username) {
            return .teal
        } else {
            return .red
        }
    }
    
    private func getValidationEmailColor() -> Color {
        if email.isEmpty || !viewModel.isValidEmail(email) {
            return .gray
        } else if viewModel.emailCheck.success {
            return .teal
        } else {
            return .red
        }
    }
    
    private func getValidationPasswordColor() -> Color {
        if password.isEmpty {
            return .gray
        } else if viewModel.isValidPassword(password) {
            return .teal
        } else {
            return .red
        }
    }
    
    private func getMatchPasswordColor() -> Color {
        if passwordConfirm.isEmpty {
            return .gray
        } else if viewModel.passwordsMatch(password: password, passwordConfirm: passwordConfirm) {
            return .teal
        } else {
            return .red
        }
    }
    
    private func readyForSubmit() -> Bool {
        return viewModel.readyForSubmit(
            username: username,
            email: email,
            password: password,
            passwordConfirm: passwordConfirm
        )
    }
    
    var body: some View {
        VStack {            
            VStack {
                HStack {
                    Text("Sign ")
                        .font(.custom("Gilroy-Bold", size: 25))
                        .foregroundColor(.black) +
                    Text("Up")
                        .font(.custom("Gilroy-Regular", size: 25))
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.create(
                            username: self.username,
                            email: self.email,
                            password: self.password
                        )
                    }) {
                        Image(systemName: "arrow.right.circle")
                            .font(.largeTitle).bold()
                            .foregroundColor(readyForSubmit() ? Color.tlGreen : .gray8)
                            .cornerRadius(5)
                    }
                    .disabled(!readyForSubmit())
                }
                
                HStack {
                    Text("Create your account")
                        .font(.system(size: 16))
                        .foregroundColor(.gray3)
                    Spacer()
                }
                
                Divider()
            }
            .padding()
            
            VStack {
                HStack {
                    Text(viewModel.getValidationMessage(self.username))
                        .font(.system(size: 14))
                        .foregroundColor(getValidationColor())
                    Spacer()
                }
                
                HStack {
                    TextField("Username", text: $username)
                        .keyboardType(.asciiCapable)
                        .autocapitalization(.none)
                        .onChange(of: username) { _, newValue in
                            viewModel.queryUsername = newValue
                        }
                    
                    if viewModel.usernameCheck.success && viewModel.isValidUsername(username) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.teal)
                    }
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            .padding(.horizontal, 20)
            
            VStack {
                HStack {
                    Text(viewModel.getEmailValidationMessage(self.email))
                        .font(.system(size: 14))
                        .foregroundColor(getValidationEmailColor())
                    Spacer()
                }
                
                HStack {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .onChange(of: email) { _, newValue in
                            viewModel.queryEmail = newValue
                        }
                    
                    if viewModel.emailCheck.success {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.teal)
                    }
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            .padding(.horizontal, 20)
            .isHidden(!viewModel.usernameCheck.success || !viewModel.isValidUsername(username))
            
            Group {
                VStack {
                    HStack {
                        Text(viewModel.getPasswordValidationMessage(self.password))
                            .font(.system(size: 14))
                            .foregroundColor(getValidationPasswordColor())
                        Spacer()
                    }
                    
                    HStack {
                        SecureField("Password", text: $password)
                        
                        if viewModel.isValidPassword(password) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.teal)
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .padding(.horizontal, 20)

                VStack {
                    HStack {
                        Text(viewModel.getPasswordMatchMessage(
                                password: password,
                                passwordConfirm: passwordConfirm)
                        )
                            .font(.system(size: 14))
                            .foregroundColor(getMatchPasswordColor())
                        Spacer()
                    }
                    
                    HStack {
                        SecureField("Re-enter Password", text: $passwordConfirm)
                        
                        if viewModel.passwordsMatch(
                            password: password,
                            passwordConfirm: passwordConfirm
                        ) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.teal)
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .padding(.horizontal, 20)
            }
            .isHidden(!viewModel.usernameCheck.success || !viewModel.emailCheck.success)
                
        }
        .padding(.top, 30)
    }
}
