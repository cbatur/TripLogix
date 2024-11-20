
import Foundation

class CreateAccountViewModel: ObservableObject {
    @Published var user: User?
//    @Published var password: String = ""
//    @Published var email: String = ""
    @Published var message: String = ""
//    
//    @Published var invalidLogin: Bool = false
//    @Published var isMarkedForDeletion: Bool = false
    @Published var fetchingResponse: Bool = false
//    @Published var errorMessage: String?
    
//    private var apiService = TLAPIService()
//    
//    @Published var queryUsername = ""
//    @Published var usernameCheck: DataExistsCheck = DataExistsCheck(objectToVerify: "", success: false)
//    
//    @Published var queryEmail = ""
//    @Published var emailCheck: DataExistsCheck = DataExistsCheck(objectToVerify: "", success: false)
//    
    
    func createNewAccount(username: String, email: String, password: String) async {
        fetchingResponse = true
        defer { fetchingResponse = false }
        
        do {
            let request = TLRequests.CreateAccount(
                username: username,
                email: email,
                password: password
            ).request
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Ensure the response is of the expected type
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            
            // Decode the response data
            let decoder = JSONDecoder()
            let responseObject = try decoder.decode(LoginResponse.self, from: data)
            
//            guard let content = chatGPTResponse.choices.first?.message.content else {
//                throw NSError(domain: "com.yourapp.error", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
//            }
            if let jwt = responseObject.jwt {
                await self.validateToken(jwt: jwt)
            } else {
                //self.errorMessage = $0.message
                self.fetchingResponse = false
            }
        } catch {
            //self.errorMessage = error.localizedDescription
            fetchingResponse = false
        }
    }
    
    func validateToken(jwt: String) async {
        fetchingResponse = true
        defer { fetchingResponse = false }
        
        do {
            let request = TLRequests.ValidateToken(jwt: jwt).request
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            
            // Decode the response data
            let decoder = JSONDecoder()
            let responseObject = try decoder.decode(UserResponse.self, from: data)
            
            if let user = responseObject.data {
                self.user = user
                //SessionManager.shared.createSession(for: user)
                self.message = "Login Successful"
            } else {
                self.message = "Login Failed"
            }
            
        } catch {
            //self.errorMessage = error.localizedDescription
            fetchingResponse = false
        }
    }
    
//    func createOld(username: String, email: String, password: String) {
//        self.apiService.create(username: username, email: email, password: password)
//            .catch {_ in Just(LoginResponse(message: "")) }
//            .sink(receiveCompletion: { _ in }, receiveValue: {
//                if let jwt = $0.jwt {
//                    self.validateToken(jwt: jwt)
//                } else {
//                    self.errorMessage = $0.message
//                    self.fetchingResponse = false
//                }
//            })
//            .store(in: &cancellables)
//    }
    
//    func validateTokenOld(jwt: String) {
//        isMarkedForDeletion = false
//        
//        self.apiService.validateToken(jwt: jwt)
//            .catch {
//                _ in Just(
//                    UserResponse(
//                        message: "",
//                        data: User(
//                            id: 0,
//                            firstname: "",
//                            lastname: "",
//                            email: "",
//                            username: "",
//                            emailVerified: 0,
//                            markedForDeletion: 0
//                        )
//                    )
//                )
//            }
//            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] response in
//                if let user = response.data {
//                    if user.markedForDeletion == 1 {
//                        self?.isMarkedForDeletion = true
//                        self?.message = "This account is marked for deletion. "
//                    } else {
//                        SessionManager.shared.createSession(for: user)
//                        self?.message = "Login Successful"
//                    }
//                } else {
//                    self?.message = "Login Failed"
//                }
//            })
//            .store(in: &cancellables)
//    }
    
//    func login(email: String, password: String) {
//        self.invalidLogin = false
//        self.apiService.login(email: email, password: password)
//            .catch {_ in Just(LoginResponse(message: "")) }
//            .sink(receiveCompletion: { _ in }, receiveValue: {
//                if let jwt = $0.jwt {
//                    self.validateToken(jwt: jwt)
//                } else {
//                    self.errorMessage = $0.message
//                    self.fetchingResponse = false
//                    self.invalidLogin = true
//                }
//            })
//            .store(in: &cancellables)
//    }
    
    
    
}
