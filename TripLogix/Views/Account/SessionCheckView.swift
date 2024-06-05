
import SwiftUI

struct SessionCheckView: View {
    @StateObject private var viewModel = SessionViewModel()
    @EnvironmentObject var sessionManager: SessionManager
    
    var body: some View {
        VStack {
            if let currentUser = sessionManager.currentUser {
                UserHasSessionView(user: currentUser)
            } else {
                UserNeedsSessionView()
            }
        }
        .onAppear {
            if let currentUser = sessionManager.currentUser {
                viewModel.username = currentUser.username
            }
        }
    }
}

//struct UserNeedsSessionView: View {
//    @Environment(\.presentationMode) var presentationMode
//    @State private var emailLogin = ""
//    @State private var passwordLogin = ""
//
//    var body: some View {
//        
//        VStack {
//            
//            VStack {
//                HStack {
//                    Spacer()
//                    Image(systemName: "x.circle.fill")
//                        .font(.largeTitle)
//                        .foregroundColor(.gray)
//                        .onTapGesture {
//                            presentationMode.wrappedValue.dismiss()
//                        }
//                        .padding(5)
//                }
//                .padding()
//            }
//            
//            VStack {
//                HStack {
//                    Text("Create a TripLogix account".uppercased())
//                        .font(.custom("Gilroy-Bold", size: 20))
//                        .foregroundColor(Color.black)
//                        .padding(.bottom, 10)
//                    
//                    Spacer()
//                }
//                .padding(.bottom, 6)
//                
//                Text("There are many activities to enjoy in. Select your favorites from the various categories available.")
//                    .font(.custom("Gilroy-Medium", size: 18))
//                    .foregroundColor(.gray2)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                
//                HStack {
//                    Spacer()
//                    Text("Why Need an Account?")
//                        .foregroundColor(.accentColor)
//                        .font(.system(size: 15))
//                        .padding()
//                }
//                
//                Rectangle()
//                    .fill(Color.gray8)
//                    .frame(height: 1)
//                    .padding(.leading, 10)
//                    .padding(.trailing, 60)
//            }
//            .padding(.leading, 16)
//            
//            ScrollView {
//                VStack {
//                    loginContent
//                }
//            }
//
//            Spacer()
//        }
//    }
//    
//    private var loginContent: some View {
//        GeometryReader { geometry in
//            VStack {
//                Image("hero_add_flight")
//                    .resizable()
//                    .scaledToFit()
//                    .background(Color.clear)
//                    .edgesIgnoringSafeArea(.all)
//                    .padding(.leading, geometry.size.width / 4)
//                    .padding(.trailing, geometry.size.width / 4)
//                                
//                socialButtonsLogin
//            }
//            .padding(.leading, 15)
//            .padding(.trailing, 15)
//            .padding(.top, 15)
//        }
//    }
//    
//    private var socialButtonsLogin: some View {
//        VStack {
//            
//            TextField("Email", text: $emailLogin)
//                //.focused($isInputActive)
//                .font(.headline)
//                .padding()
//            //.cornerRadius(24)
//            //.padding(7)
//            .cardStyleBordered()
//            
//            TextField("Password", text: $passwordLogin)
//                //.focused($isInputActive)
//                .font(.headline)
//                .padding()
//                //.background(Color.gray.opacity(0.2))
//                //.cornerRadius(24)
//                //.padding(7)
//                .cardStyleBordered()
//            
//            
//            HStack {
////                Image("logo_facebook")
////                    .resizable()
////                    .frame(width: 24, height: 24)
//                Text("Sign In")
//            }
//            .padding(.horizontal, 15)
//            .padding(9)
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .cardStyle(.cbTurquoise)
//            
//            Divider()
//            
//            buttonLoginFacebook
//            buttonLoginGoogle
//        }
//        .padding(.leading, 35)
//        .padding(.trailing, 35)
//        .padding(.top, 20)
//    }
//
//    private var buttonLoginFacebook: some View {
//        HStack {
//            Image("logo_facebook")
//                .resizable()
//                .frame(width: 24, height: 24)
//            Text("Login with Facebook")
//        }
//        .padding(.horizontal, 15)
//        .padding(9)
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .cardStyleBordered()
//    }
//    
//    private var buttonLoginGoogle: some View {
//        HStack {
//            Image("logo_google")
//                .resizable()
//                .frame(width: 24, height: 24)
//            Text("Login with Google")
//        }
//        .padding(.horizontal, 15)
//        .padding(9)
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .cardStyleBordered()
//    }
//}
