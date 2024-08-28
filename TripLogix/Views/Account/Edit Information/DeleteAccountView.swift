import Observation
import SwiftUI

struct DeleteAccountView: View {
    @Binding var email: String
    @State private var password: String = ""
    @EnvironmentObject var sessionManager: SessionManager
    @StateObject private var sessionViewModel = SessionViewModel()

    @Binding var isShowing: Bool
    @State var verificationCode: String = ""
    var reloadParent: (User) -> Void
    @FocusState private var isVerificationFocused: Bool

    @StateObject private var viewModel = DeleteAccountViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.actionResponse?.success != true {
                navigationView
                bannerView
                loginForm
                buttonView
            }
        }
        .onAppear {
            isVerificationFocused = true
        }
        .padding(16)
        .background(Color.white.cornerRadius(18))
        .padding(.horizontal, 8)
        .padding(.bottom, 30)
        .popup(isPresented: $viewModel.hasResponse) {
            if let response = viewModel.actionResponse {
                FloatAlertView(response: response)
            }
        } customize: {
            $0
                .type(.floater())
                .position(.top)
                .animation(.spring())
                .autohideIn(3)
        }
        .onChange(of: viewModel.actionResponse) { _, response in
            password = ""
            if let response = response {
                if response.success {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        sessionViewModel.logout()
                    }
                }
            }
        }
    }
    
    private var bannerView: some View {
        VStack {
            HStack {
                Text("Are You Sure You Want to Delete Your Account?")
                    .foregroundColor(.black)
                    .font(.system(size: 20, weight: .bold))
                    .kerning(0.38)
            }
            .padding(.top, 15)
            .padding(.bottom, 7)
            
            Text("Please confirm your password to proceed with account deletion.")
                .font(.system(size: 16))
                .foregroundStyle(.gray)
            
            VStack {
                Text("Warning: All your data will be ")
                    .font(.system(size: 17))
                    .foregroundColor(Color.warningRedColor)
                
                + Text("permanently deleted, ")
                    .font(.system(size: 17)).bold()
                    .foregroundColor(Color.warningRedColor)
                
                + Text("and this action ")
                    .font(.system(size: 17))
                    .foregroundColor(Color.warningRedColor)
                
                + Text("cannot be undone.")
                    .font(.system(size: 17)).bold()
                    .foregroundColor(Color.warningRedColor)
            }
            .padding(.vertical, 14)
        }
    }
    
    private var loginForm: some View {
        VStack {
            HStack {
                Text(email)
                Spacer()
            }
            
            SecureField("Enter your password", text: $password)
                .padding()
                .focused($isVerificationFocused)
                .background(.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 9)
                        .stroke(Color.gray8, lineWidth: 1)
                )
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 25)
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
    
    private var buttonView: some View {
        Button {
            Task {
                await viewModel.initiateAccountDeletion(email: email, password: password)
            }
        } label: {
            Text(viewModel.actionLoading ? "Progress..." : "Permanently Delete Account")
                .buttonStyle(.plain)
                .font(.system(size: 20)).bold()
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background {
                    RoundedRectangle(cornerRadius: 9)
                        .fill(Color.warningRedColor)
                }
        }
        .disabled(password.isEmpty)
        .opacity(password.isEmpty ? 0.3 : 1.0)
        .buttonStyle(.plain)
        .foregroundColor(.white)
        .padding(.top, 12)
    }
}



class DeleteAccountViewModel: ObservableObject {
    
    @Published var actionResponse: TLResponse?
    @Published var actionLoading: Bool = false
    @Published var hasResponse: Bool = false
    
    func initiateAccountDeletion(email: String, password: String) async {
        actionLoading = true
        actionResponse = nil
        hasResponse = false
        do {
            let request = TLRequests.AccountDeletion(email: email, password: password).request
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 500 else {
                throw URLError(.badServerResponse)
            }
            let tlResponse = try JSONDecoder().decode(TLResponse.self, from: data)
            self.actionResponse = tlResponse
            self.hasResponse = true
        } catch {
            self.hasResponse = true
            self.actionResponse = TLResponse(message: "Server Error - " + error.localizedDescription, success: false)
        }
        actionLoading = false
    }

    func resetResponse() {
        actionResponse = nil
    }
}

struct FloatAlertView: View {
    var response: TLResponse
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text(response.message)
                    .foregroundColor(.white)
                    .font(.system(size: 18))
            }
            
            Spacer()
            
            Image(response.success ? "checkmark.circle" : "exclamationmark.triangle.fill")
                .aspectRatio(1.0, contentMode: .fit)
        }
        .padding(16)
        .background(response.success ? .green : Color.warningRedColor)
        .shadow(color: Color(hex: "9265F8").opacity(0.5), radius: 40, x: 0, y: 12)
        .padding(.horizontal, 16)
    }
}
