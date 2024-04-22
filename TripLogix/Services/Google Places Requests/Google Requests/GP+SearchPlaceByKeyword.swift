
import Foundation
  
extension GooglePlacesRequests {
    struct SearchByKeyword {
        var fieldMask: String
        var textQuery: String
        
        var request: URLRequest {
            guard let googleAPIKey = decryptAPIKey(.googlePlaces) else { preconditionFailure("Bad API Key") }
            
            let path = "places:searchText"
            let urlString = "\(Configuration.GooglePlaces.newBaseUrl)\(path)"
            guard let url = URL(string: urlString) else { preconditionFailure("Bad URL") }
            
            let body: [String: Any] = ["textQuery": "\(textQuery)"]
            
            guard let postData = try? JSONSerialization.data(withJSONObject: body) else {
                fatalError("Invalid Body")
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = postData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(googleAPIKey, forHTTPHeaderField: "X-Goog-Api-Key")
            request.setValue("places.id,places.formattedAddress,places.displayName", forHTTPHeaderField: "X-Goog-FieldMask")
            
            print(request.prettyDescription)
            return request
        }
    }
}
