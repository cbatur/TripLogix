
import SwiftUI

struct ChangePasswordFooterView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @StateObject private var sessionViewModel = SessionViewModel()

    @Binding var isShowing: Bool
    var reloadParent: (User) -> Void
    @State var oldPassword: String = ""
    @State var newPassword: String = ""
    @State var newPasswordConfirm: String = ""

    private func readyForSubmit() -> Bool {
        return sessionViewModel.readyForPasswordChangeSubmit(password: newPassword, passwordConfirm: newPasswordConfirm)
    }

    @StateObject private var viewModel = ChangePasswordFooterViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Update Your Password")
                    .foregroundColor(.black)
                    .font(.system(size: 20, weight: .bold))
                    .kerning(0.38)
                Spacer()
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.gray)
                    .onTapGesture {
                        isShowing = false
                    }
            }

            Text("Enter your current password and your new password below to update your account.")
                .font(.system(size: 14))
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 13)
                .padding(.bottom, 16)

            if let user = sessionManager.currentUser {
                TextField("Current Password", text: $oldPassword)
                    .padding()
                    .frame(height: 44)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                    .padding(.top, 6)
                
                TextField("New Password", text: $newPassword)
                    .padding()
                    .frame(height: 44)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                    .padding(.top, 6)
                
                TextField("Verify New Password", text: $newPasswordConfirm)
                    .padding()
                    .frame(height: 44)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                    .padding(.top, 6)
                
                if let response = viewModel.actionResponse {
                    Text(response.message)
                        .font(.system(size: 18)).bold()
                        .multilineTextAlignment(.center)
                        .foregroundColor(response.success ? Color.tlGreen : .red)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 9)
                        .padding(.bottom, 16)
                }
                
                Button {
                    viewModel.processPasswordChange(
                        email: user.email,
                        oldPassword: oldPassword,
                        password: newPassword
                    )
                } label: {
                    Text("Update Password")
                        .buttonStyle(.plain)
                        .font(.system(size: 17))
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0.26, green: 0.32, blue: 1.5))
                        }
                }
                .buttonStyle(.plain)
                .foregroundColor(.white)
                .padding(.top, 14)
                .opacity(readyForSubmit() ? 1.0 : 0.3)
                .disabled(readyForSubmit() ? false : true)
            }
        }
        .padding(16)
        .background(Color.white.cornerRadius(18))
        .padding(.horizontal, 8)
        .padding(.bottom, 30)
        .onChange(of: viewModel.actionResponse) { _, response in
            if let response = response {
                if response.success {
                    sessionViewModel.logout()
                }
            }
        }
    }
}
