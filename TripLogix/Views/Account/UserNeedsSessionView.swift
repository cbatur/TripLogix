
import SwiftUI

struct UserNeedsSessionView: View {

    @State private var isLogin: Bool = true

    var body: some View {
        VStack(spacing: 20) {
            
            if isLogin {
                LoginView()                
            } else {
                CreateAccountView()
            }

            Spacer()
            
            Divider()
            if isLogin {
                HStack {
                    Text("New to TripLogix?")
                        .font(.custom("Gilroy-Medium", size: 17))
                    Spacer()
                    Button(action: {
                        isLogin = false
                    }) {
                        Text("Sign Up")
                            .font(.custom("Gilroy-Medium", size: 15))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(9)
                            .cardStyle(.wbPinkMedium)
                    }
                }
                .padding()
                .padding(.bottom, 20)
            } else {
                HStack {
                    Text("Already have an account? ")
                        .font(.custom("Gilroy-Medium", size: 17))
                    Spacer()
                    Button(action: {
                        isLogin = true
                    }) {
                        Text("Login")
                            .font(.custom("Gilroy-Medium", size: 15))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(9)
                            .cardStyle(.tlOrange)
                    }
                }
                .padding()
                .padding(.bottom, 20)
            }
        }
    }
}
