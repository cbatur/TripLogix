
import SwiftUI

struct EmailVerificationFooterView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @StateObject private var sessionViewModel = SessionViewModel()

    @Binding var isShowing: Bool
    @State var verificationCode: String = ""
    var reloadParent: (User) -> Void
    @FocusState private var isVerificationFocused: Bool

    @StateObject private var viewModel = EmailVerificationFooterViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            navigationView
            
            HStack {
                Text("Activate Your Account")
                    .foregroundColor(.black)
                    .font(.system(size: 22, weight: .bold))
                    .kerning(0.38)
                //Spacer()

            }
            .padding(.top, 9)

            if let user = sessionManager.currentUser {
                Text("Enter the 4 digit code sent to \(user.email). (Check spam/junk folders)")
                    .font(.system(size: 15))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 9)
                    .padding(.bottom, 16)
                
                TextField("_ _ _ _", text: $verificationCode)
                    .font(.largeTitle).bold()
                    .keyboardType(.numberPad)
                    .focused($isVerificationFocused)
                    .onChange(of: verificationCode) { _, newValue in
                        if newValue.count > 4 {
                            verificationCode = String(newValue.prefix(4))
                        }
                    }
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(height: 64)
                    .padding(.top, 6)
                
                if let resendResponse = viewModel.resendResponse {
                    Text(resendResponse.message)
                        .font(.system(size: 18)).bold()
                        .multilineTextAlignment(.center)
                        .foregroundColor(resendResponse.success ? Color.tlGreen : .red)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 9)
                        .padding(.bottom, 16)
                }
                
                if let verificationResponse = viewModel.verificationResponse {
                    Text(verificationResponse.message)
                        .font(.system(size: 18)).bold()
                        .multilineTextAlignment(.center)
                        .foregroundColor(verificationResponse.success ? Color.tlGreen : .red)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 9)
                        .padding(.bottom, 16)
                }
                
                Button {
                    viewModel.verifyAccount(email: user.email, access_code: verificationCode)
                    verificationCode = ""
                } label: {
                    Text("Submit Code")
                        .buttonStyle(.plain)
                        .font(.system(size: 23)).bold()
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0.8, green: 0.22, blue: 0.21))
                        }
                }
                .buttonStyle(.plain)
                .foregroundColor(.white)
                .padding(.top, 12)
                .opacity(viewModel.isCodeValid(verificationCode) ? 1.0 : 0.3)
                
                HStack {
                    if viewModel.resendLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1)
                            .padding()
                    } else {
                        Text("Didn't receive the code? ")
                            .foregroundColor(.gray) +
                        Text("Resend")
                            .foregroundColor(.accentColor)
                            .kerning(0.38)
                    }
                }
                .onTapGesture {
                    verificationCode = ""
                    viewModel.setVerificationCode(email: user.email)
                }
                .padding()

            }
        }
        .onAppear {
            isVerificationFocused = true
        }
        .padding(16)
        .background(Color.white.cornerRadius(18))
        .padding(.horizontal, 8)
        .padding(.bottom, 30)
        .onChange(of: viewModel.verificationResponse) { _, response in
            if let response = response {
                if response.success {
                    sessionViewModel.logout()
                }
            }
        }
    }
    
    private var navigationView: some View {
        HStack {
            Spacer()
            Image(systemName: "x.circle")
                .font(.system(size: 25))
                .foregroundColor(.gray)
                .onTapGesture {
                    isShowing = false
                }
        }
    }
}
