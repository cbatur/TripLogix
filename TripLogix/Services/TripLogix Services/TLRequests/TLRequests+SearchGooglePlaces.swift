
import Foundation
  
extension TLRequests {
    struct SearchGooglePlaces {

        var keyword: String
        var path = "places/search.php"
        
        var request: URLRequest {
            
            let path = "\(Configuration.TripLogix.baseUrl)\(path)"
            guard let url = URL(string: path) else { preconditionFailure("Bad URL") }

            var body = ["keyword": keyword]
            body["accessToken"] = Configuration.accessToken

            guard let postData = try? JSONSerialization.data(withJSONObject: body) else {
                fatalError("Invalid Body")
            }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = postData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            return request
        }
    }
}
