
import Foundation
  
extension TLRequests {
    struct CheckUsername {

        var username: String
        var path = "user/check-username.php"
        
        var request: URLRequest {
            
            let path = "\(Configuration.TripLogix.baseURL)\(path)"
            guard let url = URL(string: path) else { preconditionFailure("Bad URL") }

            var body = ["username": username]
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
