
import Foundation
  
extension TLRequests {
    struct Login {

        var email: String
        var password: String
        var path = "user/login.php"
        
        var request: URLRequest {
            
            let path = "\(Configuration.TripLogix.baseURL)\(path)"
            guard let url = URL(string: path) else { preconditionFailure("Bad URL") }

            var body = ["email": email, "password": password]
            body["accessToken"] = Configuration.accessToken

            guard let postData = try? JSONSerialization.data(withJSONObject: body) else {
                fatalError("Invalid Body")
            }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = postData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            print(request.prettyDescription)
            return request
        }
    }
}

struct User: Codable {
    var id: Int
    var firstname: String
    var lastname: String
    var email: String
    var username: String
}

struct LoginResponse: Codable {
    var message: String
    var jwt: String?
}

struct UserResponse: Codable {
    var message: String
    var data: User?
}
