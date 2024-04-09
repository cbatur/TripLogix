
import Foundation
  
extension GooglePlacesRequests {
    struct SearchByPlaceId {
        var placeId: String
        
        var request: URLRequest {
            guard let googleAPIKey = decryptAPIKey(.googlePlaces) else { preconditionFailure("Bad API Key") }
            
            let path = "place/details/json?place_id=\(placeId)&key=\(googleAPIKey)"
            let urlString = "\(Configuration.GooglePlaces.baseUrl)\(path)"
            guard let url = URL(string: urlString) else { preconditionFailure("Bad URL") }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            return request
        }
    }
}
