
import SwiftUI

struct EditNameFooterView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @Binding var isShowing: Bool
    var reloadParent: (User) -> Void

    @StateObject private var viewModel = EditNameFieldViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Add/Edit Name")
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

            Text("Your name will be visible to other users")
                .font(.system(size: 14))
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)
                .padding(.bottom, 16)

            if let user = sessionManager.currentUser {
                TextField("Name", text: Binding(
                        get: { user.firstname },
                        set: { newValue in
                            sessionManager.currentUser?.firstname = newValue
                        }
                    ))
                    .padding()
                    .frame(height: 44)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                    .padding(.top, 6)
                
                Button {
                    viewModel.updateNameField(
                        tablename: "firstName",
                        itemvalue: user.firstname,
                        userid: "\(user.id)"
                    )
                } label: {
                    Text("Save changes")
                        .buttonStyle(.plain)
                        .font(.system(size: 17))
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0.29, green: 0.38, blue: 1))
                        }
                }
                .buttonStyle(.plain)
                .foregroundColor(.white)
                .padding(.top, 12)
                .opacity(viewModel.isValid(name: user.firstname) ? 1.0 : 0.3)
            }
        }
        .padding(16)
        .background(Color.white.cornerRadius(18))
        .padding(.horizontal, 8)
        .padding(.bottom, 30)
        .onChange(of: viewModel.message) { _, message in
            if viewModel.success {
                if let user = sessionManager.currentUser {
                    reloadParent(user)
                    sessionManager.loadSession()
                }
                isShowing = false
            }
        }
    }
}
