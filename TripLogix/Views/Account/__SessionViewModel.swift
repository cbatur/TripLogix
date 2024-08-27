
import Foundation
import Combine

struct DataExistsCheck: Codable, Error {
    let objectToVerify: String
    let success: Bool
}

class SessionViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var email: String = ""
    @Published var message: String = ""
    
    @Published var invalidLogin: Bool = false
    @Published var isMarkedForDeletion: Bool = false
    @Published var fetchingResponse: Bool = false
    @Published var errorMessage: String?
    
    private var apiService = TLAPIService()
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var queryUsername = ""
    @Published var usernameCheck: DataExistsCheck = DataExistsCheck(objectToVerify: "", success: false)
    
    @Published var queryEmail = ""
    @Published var emailCheck: DataExistsCheck = DataExistsCheck(objectToVerify: "", success: false)

    init() {
        $queryUsername
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .flatMap { (queryString) -> AnyPublisher<DataExistsCheck, Never> in
                if queryString.count < 8 {
                    return Just(DataExistsCheck(objectToVerify: "", success: false)).eraseToAnyPublisher()
                }
                return self.checkUsernameExists(queryString)
                    .replaceError(with: DataExistsCheck(objectToVerify: "", success: false))
                    .eraseToAnyPublisher()
            }
            .assign(to: &$usernameCheck)
        
        $queryEmail
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .flatMap { (queryString) -> AnyPublisher<DataExistsCheck, Never> in
                if !self.isValidEmail(queryString) {
                    return Just(DataExistsCheck(objectToVerify: "", success: false)).eraseToAnyPublisher()
                }
                return self.checkEmailExists(queryString)
                    .replaceError(with: DataExistsCheck(objectToVerify: "", success: false))
                    .eraseToAnyPublisher()
            }
            .assign(to: &$emailCheck)
    }

    func checkEmailExists(_ email: String) -> AnyPublisher<DataExistsCheck, Never> {
        return self.apiService.checkEmailExists(email: email)
            .catch { _ in Just(DataExistsCheck(objectToVerify: "", success: false)) }
            .eraseToAnyPublisher()
    }
    
    func checkUsernameExists(_ username: String) -> AnyPublisher<DataExistsCheck, Never> {
        return self.apiService.checkUsernameExists(username: username)
            .catch { _ in Just(DataExistsCheck(objectToVerify: "", success: false)) }
            .eraseToAnyPublisher()
    }
    
    func create(username: String, email: String, password: String) {
        self.apiService.create(username: username, email: email, password: password)
            .catch {_ in Just(LoginResponse(message: "")) }
            .sink(receiveCompletion: { _ in }, receiveValue: {
                if let jwt = $0.jwt {
                    self.validateToken(jwt: jwt)
                } else {
                    self.errorMessage = $0.message
                    self.fetchingResponse = false
                }
            })
            .store(in: &cancellables)
    }
    
    func login(email: String, password: String) {
        self.invalidLogin = false
        self.apiService.login(email: email, password: password)
            .catch {_ in Just(LoginResponse(message: "")) }
            .sink(receiveCompletion: { _ in }, receiveValue: {
                if let jwt = $0.jwt {
                    self.validateToken(jwt: jwt)
                } else {
                    self.errorMessage = $0.message
                    self.fetchingResponse = false
                    self.invalidLogin = true
                }
            })
            .store(in: &cancellables)
    }
    
    func validateToken(jwt: String) {
        isMarkedForDeletion = false
        
        self.apiService.validateToken(jwt: jwt)
            .catch {
                _ in Just(
                    UserResponse(
                        message: "",
                        data: User(
                            id: 0,
                            firstname: "",
                            lastname: "",
                            email: "",
                            username: "",
                            emailVerified: 0,
                            markedForDeletion: 0
                        )
                    )
                )
            }
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] response in
                if let user = response.data {
                    if user.markedForDeletion == 1 {
                        self?.isMarkedForDeletion = true
                        self?.message = "This account is marked for deletion. "
                    } else {
                        SessionManager.shared.createSession(for: user)
                        self?.message = "Login Successful"
                    }
                } else {
                    self?.message = "Login Failed"
                }
            })
            .store(in: &cancellables)
    }
    
    func logout() {
        SessionManager.shared.destroySession()
        message = "Logged out"
    }
}

// Validations and non-API functions
extension SessionViewModel {
    
    func getValidationMessage(_ username: String) -> String {
        if username.isEmpty || username.count < 8 || !isValidUsername(username) {
            return "Pick a valid username (min 8 chars)"
        } else if self.usernameCheck.success {
            return "Username is valid"
        } else {
            return "Username is taken or invalid"
        }
    }
    
    func isValidUsername(_ username: String) -> Bool {
        let regex = "^[a-zA-Z0-9_]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: username)
    }
    
    func getEmailValidationMessage(_ email: String) -> String {
        if email.isEmpty || !isValidEmail(email) {
            return "Pick a valid email"
        } else if self.emailCheck.success {
            return "Email is valid"
        } else {
            return "Email already exists"
        }
    }
    
    func getSignInEmailValidationMessage(_ email: String) -> String {
        if email.isEmpty {
            return "Your registered email"
        } else if !isValidEmail(email) {
            return "Not a valid email"
        } else {
            return ""
        }
    }
    
    func getPasswordValidationMessage(_ password: String) -> String {
        if password.isEmpty || !isValidPassword(password) {
            return "Pick a strong password"
        } else if self.emailCheck.success {
            return "Password is strong enough"
        } else {
            return "Password should contain at least one letter and one digit"
        }
    }
    
    func getPasswordMatchMessage(password: String, passwordConfirm: String) -> String {
        if passwordConfirm.isEmpty {
            return "Pick a strong password"
        } else if password == passwordConfirm {
            return ""
        } else {
            return "Passwords do not match"
        }
    }
    
    func passwordsMatch(password: String, passwordConfirm: String) -> Bool {
        return password.count > 0 && passwordConfirm.count > 0 && password == passwordConfirm
    }

    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }
    
    func isValidPassword(_ password: String) -> Bool {
        // Minimum 8 characters, at least one uppercase letter, one lowercase letter, one number and one special character
        let regex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[!@#$%^&*(),.?\":{}|<>]).{8,}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: password)
    }
    
    func readyForSubmit(
        username: String,
        email: String,
        password: String,
        passwordConfirm: String
    ) -> Bool {
        return isValidUsername(username)
        && isValidEmail(email)
        && isValidPassword(password)
        && isValidPassword(passwordConfirm)
        && password == passwordConfirm
        && self.emailCheck.success == true
        && self.usernameCheck.success == true
    }
    
    func readyForPasswordChangeSubmit(
        oldPassword: String,
        password: String,
        passwordConfirm: String
    ) -> Bool {
        return oldPassword.count > 5
        && isValidPassword(passwordConfirm)
        && password == passwordConfirm
    }
    
    func isValidLength(name: String) -> Bool {
        return name.count > 5
    }
    
    func dismissInvalidLogin() {
        self.invalidLogin = false
    }
    
}
