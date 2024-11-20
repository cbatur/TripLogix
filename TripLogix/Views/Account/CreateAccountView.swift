
import SwiftUI

struct CreateAccountView: View {
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var passwordConfirm: String = ""
    @State private var currentStep: Int = 1
    @StateObject private var viewModel = SessionViewModel()
    @StateObject private var createAccountViewModel = CreateAccountViewModel()
    let reloadParent: () -> Void
    
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
            // Step Indicator
            HStack {
                ForEach(1...3, id: \.self) { step in
                    Circle()
                        .fill(step <= currentStep ? Color.teal : Color.gray)
                        .frame(width: 10, height: 10)
                        .overlay(
                            step == currentStep ? Circle().stroke(Color.teal, lineWidth: 2) : nil
                        )
                }
            }
            .padding(.bottom, 20)
            
            // Step Views
            if currentStep == 1 {
                // Username and Email Step
                VStack {
                    HStack {
                        Text("Sign ")
                            .font(.custom("Gilroy-Bold", size: 25))
                            .foregroundColor(.black) +
                        Text("Up")
                            .font(.custom("Gilroy-Regular", size: 25))
                        
                        Spacer()
                        
                        Button(action: {
                            currentStep = 2
                        }) {
                            Image(systemName: "arrow.right.circle")
                                .font(.largeTitle).bold()
                                .foregroundColor(viewModel.usernameCheck.success && viewModel.emailCheck.success ? Color.teal : .gray)
                                .cornerRadius(5)
                        }
                        .disabled(!viewModel.usernameCheck.success || !viewModel.emailCheck.success)
                    }
                    
                    HStack {
                        Text("Create your account")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
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
                .background(.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
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
                .background(.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .padding(.horizontal, 20)
            } else if currentStep == 2 {
                // Password and Password Confirmation Step
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
                    .background(.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
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
                    .background(.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                }
                
                HStack {
                    Button(action: {
                        currentStep = 1
                    }) {
                        Text("Back")
                            .foregroundColor(.teal)
                    }
                    Spacer()
                    
                    Button(action: {
                        currentStep = 3
                    }) {
                        Text("Next")
                            .foregroundColor(
                                viewModel.readyForSubmit(
                                    username: username,
                                    email: email,
                                    password: password,
                                    passwordConfirm: passwordConfirm
                                ) ? .teal : .gray
                            )
                    }
                    //.disabled(!viewModel.readyForSubmit())
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            } else if currentStep == 3 {
                // Final Confirmation Step
                VStack {
                    Text("Review and Confirm")
                        .font(.title)
                        .padding(.bottom, 20)
                    
                    Text("Username: \(username)")
                    Text("Email: \(email)")
                    
                    Spacer()
                    
                    Button(action: {
                        Task {
                            await createAccountViewModel.createNewAccount(
                                username: username,
                                email: email,
                                password: password
                            )
                        }
                    }) {
                        Text("Create Account")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.teal)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 20)
                    
                    Button(action: {
                        currentStep = 2
                    }) {
                        Text("Back")
                            .foregroundColor(.teal)
                    }
                    .padding(.top, 10)
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.top, 30)
        .onChange(of: createAccountViewModel.user) { _, user in
            guard let user = user else { return }
            SessionManager.shared.createSession(for: user)
            reloadParent()
        }
    }
}
