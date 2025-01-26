import Foundation

enum AdminOpenAIRequests {}
enum AdminTLRequests {}

  
extension AdminTLRequests {
    struct DynamicRead {

        var query: String
        var path = "get_locations.php"
        
        var request: URLRequest {
            
            let path = "\(Configuration.TripLogix.baseAdminURL)\(path)"
            guard let url = URL(string: path) else { preconditionFailure("Bad URL") }

            var body = ["query": query]
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
