
import Foundation
  
extension TLRequests {
    struct GetPopularGooglePlaces {

        var path = "googlePlace/getPopularPlaces.php"
        
        var request: URLRequest {
            
            let path = "\(Configuration.TripLogix.baseURL)\(path)"
            guard let url = URL(string: path) else { preconditionFailure("Bad URL") }

            var body = ["accessToken": Configuration.accessToken]

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
